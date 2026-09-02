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
      local servers = require("core.lsp.servers")
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
        local tp = require("core.utils.telescope_pickers")
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
      servers.setup(lspconfig, capabilities)

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
