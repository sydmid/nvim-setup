return {
  -- Auto completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer", -- source for text in buffer
      "hrsh7th/cmp-path", -- source for file system paths
      {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",
      },
      "saadparwaiz1/cmp_luasnip", -- for autocompletion
      "rafamadriz/friendly-snippets", -- useful snippets
      "onsails/lspkind.nvim", -- vs-code like pictograms
      "zbirenbaum/copilot-cmp", -- GitHub Copilot completions (for inline suggestions)
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        completion = {
          completeopt = "menu,menuone,preview,noselect",
          autocomplete = {
            require("cmp.types").cmp.TriggerEvent.TextChanged,
          },
        },
        snippet = { -- configure how nvim-cmp interacts with snippet engine
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<D-CR>"] = cmp.mapping.complete(), -- show completion suggestions
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.confirm({ select = true }),
          -- ["<Tab>"] = cmp.mapping.select_next_item(),
          -- ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        -- sources for autocompletion
        sources = cmp.config.sources({
          { name = "copilot", group_index = 1, priority = 100 }, -- GitHub Copilot inline suggestions
          -- Note: Avante.nvim handles chat functionality separately
          { name = "luasnip", trigger_characters = {}, option = { show_autosnippets = true } }, -- snippets
          { name = "nvim_lsp", keyword_length = 1 }, -- lsp
          { name = "buffer", keyword_length = 2 }, -- text within current buffer
          { name = "path", keyword_length = 2 }, -- file system paths
        }),

        window = {
          completion = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:Pmenu,FloatBorder:PmenuBorder,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
          }),
        },

        -- configure lspkind for vs-code like pictograms in completion menu
        formatting = {
          fields = { "kind", "abbr", "menu" },
          expandable_indicator = true,
          format = lspkind.cmp_format({
            maxwidth = 50,
            ellipsis_char = "...",
            symbol_map = {
              Copilot = "", -- AI-powered suggestions
            },
          }),
        },
        -- Custom sorting prioritization (removed Copilot, using Avante)
        -- sorting = {
        --   priority_weight = 2,
        --   comparators = {
        --     require("cmp.config.compare").offset,
        --     require("cmp.config.compare").exact,
        --     require("cmp.config.compare").score,
        --     require("cmp.config.compare").recently_used,
        --     require("cmp.config.compare").locality,
        --     require("cmp.config.compare").kind,
        --     require("cmp.config.compare").sort_text,
        --     require("cmp.config.compare").length,
        --     require("cmp.config.compare").order,
        --   },
        -- },
      })
    end,
  },
}
