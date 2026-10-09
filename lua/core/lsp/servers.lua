local M = {}

local server_names = {
  "ts_ls",
  "html",
  "cssls",
  "tailwindcss",
  "svelte",
  "lua_ls",
  "graphql",
  "emmet_ls",
  "prismals",
  "pyright",
  "ruff",
  "eslint",
  "bashls",
  "gopls",
  "rust_analyzer",
  "taplo",
  "clangd",
  "roslyn",
}

local function setup_lua(lspconfig, capabilities)
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        completion = { callSnippet = "Replace" },
      },
    },
  })
end

local function setup_bash(lspconfig, capabilities)
  lspconfig.bashls.setup({
    capabilities = capabilities,
    filetypes = { "sh", "bash", "zsh" },
    init_options = { filetypes = { "sh", "bash", "zsh" } },
    settings = { bashIde = { shellcheckPath = "" } },
  })
end

local function setup_python(lspconfig, capabilities)
  if not capabilities.textDocument then
    capabilities.textDocument = {}
  end
  if not capabilities.textDocument.semanticTokens then
    capabilities.textDocument.semanticTokens = {}
  end
  capabilities.textDocument.semanticTokens.multilineTokenSupport = true

  lspconfig.pyright.setup({
    capabilities = capabilities,
    settings = {
      pyright = {
        disableOrganizeImports = true,
        disableTaggedHints = false,
      },
      python = {
        analysis = {
          typeCheckingMode = "strict",
          autoImportCompletions = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
          autoSearchPaths = true,
          stubPath = "typings",
          extraPaths = {},
          diagnosticSeverityOverrides = {
            reportMissingTypeStubs = "none",
            reportUnknownParameterType = "none",
            reportUnknownArgumentType = "none",
            reportUnknownLambdaType = "none",
            reportUnknownVariableType = "none",
            reportUnknownMemberType = "none",
            reportMissingParameterType = "none",
          },
        },
      },
    },
  })
end

local function setup_ruff(lspconfig, capabilities)
  lspconfig.ruff.setup({
    capabilities = capabilities,
    init_options = { settings = { args = { "--config=pyproject.toml" } } },
    on_attach = function(client)
      client.server_capabilities.hoverProvider = false
    end,
  })
end

local function setup_rust(lspconfig, capabilities)
  if not capabilities.textDocument then
    capabilities.textDocument = {}
  end
  if not capabilities.textDocument.semanticTokens then
    capabilities.textDocument.semanticTokens = {}
  end
  capabilities.textDocument.semanticTokens.multilineTokenSupport = true

  lspconfig.rust_analyzer.setup({
    capabilities = capabilities,
    filetypes = { "rust" },
    root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json"),
    settings = {
      ["rust-analyzer"] = {
        cargo = { buildScripts = { enable = true }, allTargets = true, features = "all" },
        procMacro = { enable = true },
        diagnostics = { enable = true, enableExperimental = true },
        completion = { callable = { snippets = "fill_arguments" }, postfix = { enable = true } },
        inlayHints = {
          enable = true,
          chainingHints = { enable = true },
          parameterHints = { enable = true },
          typeHints = { enable = true },
        },
        lens = { enable = true },
        check = { command = "clippy" },
      },
    },
  })
end

local function setup_toml(lspconfig, capabilities)
  lspconfig.taplo.setup({
    capabilities = capabilities,
    filetypes = { "toml" },
    root_dir = lspconfig.util.root_pattern("*.toml", ".git"),
  })
end

local function setup_go(lspconfig, capabilities)
  lspconfig.gopls.setup({
    capabilities = capabilities,
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_dir = lspconfig.util.root_pattern("go.mod", "go.work", ".git"),
    settings = {
      gopls = {
        completeUnimported = true,
        usePlaceholders = true,
        analyses = { unusedparams = true, unreachable = true, fillstruct = true },
        staticcheck = true,
        gofumpt = true,
      },
    },
  })
end

local function setup_typescript(lspconfig, capabilities)
  local inlay_hints = {
    includeInlayParameterNameHints = "all",
    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
    includeInlayFunctionParameterTypeHints = true,
    includeInlayVariableTypeHints = true,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayFunctionLikeReturnTypeHints = true,
    includeInlayEnumMemberValueHints = true,
  }

  -- Dynamically find nvm/fnm/volta Node.js
  local function find_node_path()
    -- 1. Check if node is already in PATH (works when shell sources nvm/fnm)
    local node_in_path = vim.fn.exepath("node")
    if node_in_path ~= "" then
      return node_in_path
    end

    -- 2. Check nvm default version
    local nvm_dir = vim.fn.expand("~/.nvm")
    local nvm_default = nvm_dir .. "/alias/default"
    if vim.loop.fs_stat(nvm_default) then
      local default_version = vim.fn.readfile(nvm_default)[1]
      if default_version then
        -- Handle major version alias (e.g., "20" -> find latest v20.x.x)
        local node_path
        if default_version:match("^%d+$") then
          -- It's a major version, find latest matching version
          local versions_dir = nvm_dir .. "/versions/node"
          local handle = vim.loop.fs_scandir(versions_dir)
          if handle then
            local latest_version = nil
            while true do
              local name, typ = vim.loop.fs_scandir_next(handle)
              if not name then
                break
              end
              if typ == "directory" and name:match("^v" .. default_version .. "%.") then
                if
                  not latest_version
                  or vim.version.cmp(
                      { name:match("v(%d+)%.(%d+)%.(%d+)") },
                      { latest_version:match("v(%d+)%.(%d+)%.(%d+)") }
                    )
                    > 0
                then
                  latest_version = name
                end
              end
            end
            if latest_version then
              node_path = versions_dir .. "/" .. latest_version .. "/bin/node"
            end
          end
        else
          -- Specific version like "v20.20.2"
          node_path = nvm_dir .. "/versions/node/" .. default_version .. "/bin/node"
        end
        if node_path and vim.loop.fs_stat(node_path) then
          return node_path
        end
      end
    end

    -- 3. Check fnm default
    local fnm_dir = vim.fn.expand("~/.fnm")
    local fnm_current = fnm_dir .. "/current"
    if vim.loop.fs_stat(fnm_current) then
      local target = vim.loop.fs_readlink(fnm_current)
      if target then
        local node_path = target .. "/bin/node"
        if vim.loop.fs_stat(node_path) then
          return node_path
        end
      end
    end

    -- 4. Check volta
    local volta_dir = vim.fn.expand("~/.volta")
    local volta_node = volta_dir .. "/bin/node"
    if vim.loop.fs_stat(volta_node) then
      return volta_node
    end

    -- 5. Check Homebrew (common on macOS)
    local brew_node = "/opt/homebrew/bin/node"
    if vim.loop.fs_stat(brew_node) then
      return brew_node
    end

    local brew_node_intel = "/usr/local/bin/node"
    if vim.loop.fs_stat(brew_node_intel) then
      return brew_node_intel
    end

    return nil
  end

  local node_path = find_node_path()
  local ts_server = vim.fn.stdpath("data") .. "/mason/bin/typescript-language-server"

  local cmd = { ts_server, "--stdio" }
  if node_path then
    cmd = { node_path, ts_server, "--stdio" }
  end

  lspconfig.ts_ls.setup({
    capabilities = capabilities,
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
    settings = {
      typescript = { inlayHints = inlay_hints },
      javascript = { inlayHints = inlay_hints },
    },
    cmd = cmd,
    on_attach = function(client, bufnr)
      local keymap = vim.keymap.set
      keymap("n", "<leader>to", function()
        vim.lsp.buf.execute_command({
          command = "_typescript.organizeImports",
          arguments = { vim.api.nvim_buf_get_name(0) },
        })
      end, { buffer = bufnr, desc = "Organize imports" })
      keymap("n", "<leader>ti", function()
        vim.lsp.buf.code_action({
          filter = function(action)
            return action.title == "Add missing imports"
          end,
          apply = true,
        })
      end, { buffer = bufnr, desc = "Add missing imports" })
      keymap("n", "<leader>tf", function()
        vim.lsp.buf.code_action({
          filter = function(action)
            return action.title:match("Fix all")
          end,
          apply = true,
        })
      end, { buffer = bufnr, desc = "Fix all" })
      keymap("n", "<leader>tu", function()
        vim.lsp.buf.code_action({
          filter = function(action)
            return action.title:match("Remove unused")
          end,
          apply = true,
        })
      end, { buffer = bufnr, desc = "Remove unused" })
    end,
  })
end

local function setup_clang(lspconfig, capabilities)
  -- Merge custom capabilities with the default ones
  local clangd_capabilities = vim.tbl_deep_extend("force", capabilities or {}, { offsetEncoding = { "utf-16" } })

  lspconfig.clangd.setup({
    keys = {
      { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
    },
    root_dir = function(fname)
      return lspconfig.util.root_pattern(
        "Makefile",
        "configure.ac",
        "configure.in",
        "config.h.in",
        "meson.build",
        "meson_options.txt",
        "build.ninja"
      )(fname) or lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt")(fname) or lspconfig.util.find_git_ancestor(
        fname
      )
    end,
    capabilities = clangd_capabilities,
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
      "--fallback-style=llvm",
    },
    init_options = { usePlaceholders = true, completeUnimported = true, clangdFileStatus = true },
  })
end

local function setup_roslyn(lspconfig, capabilities)
  -- Roslyn is handled by the roslyn.nvim plugin, but we can add additional config here if needed
  -- The plugin sets up the LSP automatically via its own config
end

function M.setup(lspconfig, capabilities)
  local setup_by_name = {
    lua_ls = setup_lua,
    bashls = setup_bash,
    pyright = setup_python,
    ruff = setup_ruff,
    rust_analyzer = setup_rust,
    taplo = setup_toml,
    gopls = setup_go,
    ts_ls = setup_typescript,
    clangd = setup_clang,
    roslyn = setup_roslyn,
  }

  for _, server_name in ipairs(server_names) do
    local setup_server = setup_by_name[server_name]
    if setup_server then
      setup_server(lspconfig, capabilities)
    elseif lspconfig[server_name] then
      lspconfig[server_name].setup({ capabilities = capabilities })
    end
  end
end

return M
