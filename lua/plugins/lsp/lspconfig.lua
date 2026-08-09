return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      ---@diagnostic disable-next-line: missing-fields
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      ---@diagnostic disable-next-line: missing-fields
      { 'j-hui/fidget.nvim',       opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
      "glepnir/lspsaga.nvim",
    },
    opts = {
        setup = {
        clangd = function(_, opts)
          local clangd_ext_opts = {}
          require('clangd_extensions').setup(vim.tbl_deep_extend('force', clangd_ext_opts or {}, { server = opts }))
          return false
        end,
      },
    },
    config = function()
      local attach = require("core.lsp.attach")
      local filetypes = require("core.lsp.filetypes")
      local signature = require("core.lsp.signature")
      local hover = require("core.lsp.hover")
      local diagnostics = require("core.lsp.diagnostics")
      local appearance = require("core.lsp.appearance")

      -- Fix position_encoding warning
      local orig_util = vim.lsp.util
      local orig_make_position_params = orig_util.make_position_params
      orig_util.make_position_params = function(winnr, encoding)
        return orig_make_position_params(winnr, encoding or "utf-8")
      end
      diagnostics.configure_defaults()

      -- ============================================================
      -- Diagnostic Severity Visibility Management
      -- <leader>xv toggles which severities appear, resets on :cd
      -- ============================================================

      -- Telescope picker: toggle diagnostic severity visibility
      local function open_diagnostic_severity_picker(initial_idx)
        local tp = require("helpers.telescope_pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        local severity_items = {
          { severity = vim.diagnostic.severity.ERROR, name = "Errors",   icon = " " },
          { severity = vim.diagnostic.severity.WARN,  name = "Warnings", icon = " " },
          { severity = vim.diagnostic.severity.INFO,  name = "Info",     icon = " " },
          { severity = vim.diagnostic.severity.HINT,  name = "Hints",    icon = " " },
        }

        local entries = {}
        for i, item in ipairs(severity_items) do
          table.insert(entries, {
            idx = i,
            severity = item.severity,
            name = item.name,
            icon = item.icon,
              active = diagnostics.severity_state[item.severity],
          })
        end

        tp.custom({
          prompt_title = "Diagnostic Visibility (Enter: toggle, Esc: close)",
          mode = "normal",
          default_selection_index = initial_idx or 1,
          finder = finders.new_table({
            results = entries,
            entry_maker = function(entry)
              local indicator = entry.active and "[x]" or "[ ]"
              return {
                value = entry,
                display = string.format("%s %s %s", indicator, entry.icon, entry.name),
                ordinal = entry.name,
              }
            end,
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              if selection then
                local sev = selection.value.severity
                local idx = selection.value.idx
                diagnostics.severity_state[sev] = not diagnostics.severity_state[sev]
                diagnostics.apply_severity_visibility()
                actions.close(prompt_bufnr)
                vim.schedule(function()
                  open_diagnostic_severity_picker(idx)
                end)
              end
            end)
            return true
          end,
        })
      end

      vim.keymap.set("n", "<leader>xv", function()
        open_diagnostic_severity_picker()
      end, { desc = "Diagnostic visibility", silent = true })

      -- Reset severity to errors-only on project change
      vim.api.nvim_create_autocmd("DirChanged", {
        group = vim.api.nvim_create_augroup("DiagnosticSeverityReset", { clear = true }),
        callback = function()
          diagnostics.reset_severity_defaults()
        end,
      })
      appearance.setup_colorscheme_hook()

      signature.setup_handlers(appearance.retro_border)
      hover.setup_handler(appearance.retro_border)

      -- Setup LSP
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- NOTE: signatureHelp capability is kept enabled for manual invocation (D-S-i).
      -- Auto-popup is already disabled by Noice (signature.auto_open.enabled = false)
      -- and by close_events in the handler config.

      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      attach.setup(appearance.retro_border)

      -- newer versions of mason-lspconfig
      -- Set up servers manually
      local servers = {
        "ts_ls", "html", "cssls", "tailwindcss", "svelte", "lua_ls", "graphql",
        "emmet_ls", "prismals", "pyright", "ruff", "eslint", "bashls", "roslyn",
        "gopls", "rust_analyzer", "taplo", "clangd"
      }

      for _, server_name in ipairs(servers) do
        if server_name == "lua_ls" then
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } },
                completion = { callSnippet = "Replace" },
              },
            },
          })
        elseif server_name == "bashls" then
          lspconfig.bashls.setup({
            capabilities = capabilities,
            filetypes = { "sh", "bash", "zsh" },
            init_options = {
              filetypes = { "sh", "bash", "zsh" },
            },
            settings = {
              bashIde = {
                shellcheckPath = "",
              },
            },
          })
        elseif server_name == "pyright" then
          lspconfig.pyright.setup({
            capabilities = capabilities,
            settings = {
              pyright = {
                -- Using Ruff's import organizer
                disableOrganizeImports = true,
                -- Disable some features that Ruff handles better
                disableTaggedHints = false,
              },
              python = {
                analysis = {
                  -- Enhanced type checking
                  typeCheckingMode = "strict",
                  -- Auto-import completions
                  autoImportCompletions = true,
                  -- Use workspace libraries
                  useLibraryCodeForTypes = true,
                  -- Diagnostic modes
                  diagnosticMode = "workspace",
                  -- Auto-search paths
                  autoSearchPaths = true,
                  -- Stub path
                  stubPath = "typings",
                  -- Extra paths for analysis
                  extraPaths = {},
                  -- Diagnostic severity overrides
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
        elseif server_name == "ruff" then
          -- Ruff LSP for ultra-fast Python linting and formatting
          lspconfig.ruff.setup({
            capabilities = capabilities,
            init_options = {
              settings = {
                -- Ruff configuration
                args = {
                  "--config=pyproject.toml", -- Use pyproject.toml if available
                },
              }
            },
            -- Organize imports capability
            on_attach = function(client, bufnr)
              -- Disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
            end,
          })
        elseif server_name == "rust_analyzer" then
          -- Professional Rust LSP configuration with rust-analyzer (fallback)
          lspconfig.rust_analyzer.setup({
            capabilities = capabilities,
            filetypes = { "rust" },
            root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json"),
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  buildScripts = { enable = true },
                  allTargets = true,
                  features = "all",
                },
                procMacro = { enable = true },
                diagnostics = { enable = true, enableExperimental = true },
                completion = {
                  callable = { snippets = "fill_arguments" },
                  postfix = { enable = true },
                },
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
        elseif server_name == "taplo" then
          -- TOML language server configuration (fallback)
          lspconfig.taplo.setup({
            capabilities = capabilities,
            filetypes = { "toml" },
            root_dir = lspconfig.util.root_pattern("*.toml", ".git"),
          })
        elseif server_name == "gopls" then
          -- Go language server configuration (fallback)
          lspconfig.gopls.setup({
            capabilities = capabilities,
            filetypes = { "go", "gomod", "gowork", "gotmpl" },
            root_dir = lspconfig.util.root_pattern("go.mod", "go.work", ".git"),
            settings = {
              gopls = {
                completeUnimported = true,
                usePlaceholders = true,
                analyses = {
                  unusedparams = true,
                  unreachable = true,
                  fillstruct = true,
                },
                staticcheck = true,
                gofumpt = true,
              },
            },
          })
        elseif server_name == "ts_ls" then
          -- TypeScript/JavaScript language server configuration (fallback)
          lspconfig.ts_ls.setup({
            capabilities = capabilities,
            filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
            root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json",
              ".git"),
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                },
              },
              javascript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                },
              },
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
                  filter = function(action)
                    return action.title ==
                        "Add missing imports"
                  end,
                  apply = true
                })
              end, { buffer = bufnr, desc = "Add missing imports" })
              keymap("n", "<leader>tf", function()
                vim.lsp.buf.code_action({
                  filter = function(action)
                    return action.title:match(
                      "Fix all")
                  end,
                  apply = true
                })
              end, { buffer = bufnr, desc = "Fix all" })
              keymap("n", "<leader>tu", function()
                vim.lsp.buf.code_action({
                  filter = function(action)
                    return action.title:match(
                      "Remove unused")
                  end,
                  apply = true
                })
              end, { buffer = bufnr, desc = "Remove unused" })
            end,
          })
        elseif server_name == "clangd" then
          lspconfig.clangd.setup({
            keys = {
              { '<leader>ch', '<cmd>ClangdSwitchSourceHeader<cr>', desc = 'Switch Source/Header (C/C++)' },
            },
            root_dir = function(fname)
              return require('lspconfig.util').root_pattern(
                    'Makefile',
                    'configure.ac',
                    'configure.in',
                    'config.h.in',
                    'meson.build',
                    'meson_options.txt',
                    'build.ninja'
                  )(fname) or
                  require('lspconfig.util').root_pattern('compile_commands.json', 'compile_flags.txt')(
                    fname) or require('lspconfig.util').find_git_ancestor(
                    fname
                  )
            end,
            capabilities = {
              offsetEncoding = { 'utf-16' },
            },
            cmd = {
              'clangd',
              '--background-index',
              '--clang-tidy',
              '--header-insertion=iwyu',
              '--completion-style=detailed',
              '--function-arg-placeholders',
              '--fallback-style=llvm',
            },
            init_options = {
              usePlaceholders = true,
              completeUnimported = true,
              clangdFileStatus = true,
            },
          })
        end
      end

      filetypes.setup()
    end,
  },
  {
    'p00f/clangd_extensions.nvim',
    dependencies = { 'mortepau/codicons.nvim' },
    lazy = true,
    config = function() end,
    opts = {
      inlay_hints = {
        inline = false,
      },
      ast = {
        --These require codicons (https://github.com/microsoft/vscode-codicons)
        role_icons = {
          type = '',
          declaration = '',
          expression = '',
          specifier = '',
          statement = '',
          ['template argument'] = '',
        },
        kind_icons = {
          Compound = '',
          Recovery = '',
          TranslationUnit = '',
          PackExpansion = '',
          TemplateTypeParm = '',
          TemplateTemplateParm = '',
          TemplateParamObject = '',
        },
      },
    },
  },
}
