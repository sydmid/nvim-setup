return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      ---@diagnostic disable-next-line: missing-fields
      { "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      ---@diagnostic disable-next-line: missing-fields
      { "j-hui/fidget.nvim", opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      "hrsh7th/cmp-nvim-lsp",
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
      "glepnir/lspsaga.nvim",
    },
    opts = {
      setup = {
        clangd = function(_, opts)
          local clangd_ext_opts = {}
          require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))
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

      -- Setup Diagnostic Severity Visibility Management
      require("core.lsp.diagnostic_visibility").setup()

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
}
