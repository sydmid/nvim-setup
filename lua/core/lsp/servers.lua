local M = {}

local server_names = {
  "ts_ls", "html", "cssls", "tailwindcss", "svelte", "lua_ls", "graphql",
  "emmet_ls", "prismals", "pyright", "ruff", "eslint", "bashls", "roslyn",
  "gopls", "rust_analyzer", "taplo", "clangd",
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
    on_attach = function(client, bufnr)
      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end,
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

  lspconfig.ts_ls.setup({
    capabilities = capabilities,
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
    settings = {
      typescript = { inlayHints = inlay_hints },
      javascript = { inlayHints = inlay_hints },
    },
    on_attach = function(client, bufnr)
      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end

      local keymap = vim.keymap.set
      keymap("n", "<leader>to", function()
        vim.lsp.buf.execute_command({ command = "_typescript.organizeImports", arguments = { vim.api.nvim_buf_get_name(0) } })
      end, { buffer = bufnr, desc = "Organize imports" })
      keymap("n", "<leader>ti", function()
        vim.lsp.buf.code_action({
          filter = function(action) return action.title == "Add missing imports" end,
          apply = true,
        })
      end, { buffer = bufnr, desc = "Add missing imports" })
      keymap("n", "<leader>tf", function()
        vim.lsp.buf.code_action({
          filter = function(action) return action.title:match("Fix all") end,
          apply = true,
        })
      end, { buffer = bufnr, desc = "Fix all" })
      keymap("n", "<leader>tu", function()
        vim.lsp.buf.code_action({
          filter = function(action) return action.title:match("Remove unused") end,
          apply = true,
        })
      end, { buffer = bufnr, desc = "Remove unused" })
    end,
  })
end

local function setup_clang(lspconfig)
  lspconfig.clangd.setup({
    keys = {
      { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
    },
    root_dir = function(fname)
      return lspconfig.util.root_pattern(
        "Makefile", "configure.ac", "configure.in", "config.h.in", "meson.build", "meson_options.txt", "build.ninja"
      )(fname)
        or lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt")(fname)
        or lspconfig.util.find_git_ancestor(fname)
    end,
    capabilities = { offsetEncoding = { "utf-16" } },
    cmd = {
      "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu",
      "--completion-style=detailed", "--function-arg-placeholders", "--fallback-style=llvm",
    },
    init_options = { usePlaceholders = true, completeUnimported = true, clangdFileStatus = true },
  })
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
