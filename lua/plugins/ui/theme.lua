local background = require("core.ui.background")
local symbols = require("core.ui.symbols")

local symbol_pickers = require("core.ui.symbol_pickers")

local theme_opts = symbols.theme_opts

return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        commentStyle = { italic = true },
        functionStyle = { bold = true },
        keywordStyle = { bold = true },
        statementStyle = { bold = true },
        variant = "auto",  -- auto, main, moon, or dawn
        dark_variant = "main", -- main, moon, or dawn
        dim_inactive_windows = false,
        extend_background_behind_borders = true,

        enable = {
          terminal = true,
          legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
          migrations = true,      -- Handle deprecated options automatically
        },

        styles = {
          bold = true,
          italic = true,
          transparency = false,
        },

        groups = {
          border = "muted",
          link = "iris",
          panel = "surface",

          error = "love",
          hint = "iris",
          info = "foam",
          note = "pine",
          todo = "rose",
          warn = "gold",

          git_add = "foam",
          git_change = "rose",
          git_delete = "love",
          git_dirty = "rose",
          git_ignore = "muted",
          git_merge = "iris",
          git_rename = "pine",
          git_stage = "iris",
          git_text = "rose",
          git_untracked = "subtle",

          h1 = "iris",
          h2 = "foam",
          h3 = "rose",
          h4 = "gold",
          h5 = "pine",
          h6 = "foam",
        },

        palette = {
          -- Override the builtin palette per variant
          -- moon = {
          --     base = '#18191a',
          --     overlay = '#363738',
          -- },
        },

        -- NOTE: Highlight groups are extended (merged) by default. Disable this
        -- per group via `inherit = false`
        highlight_groups = {
          -- Comment = { fg = "foam" },
          -- StatusLine = { fg = "love", bg = "love", blend = 15 },
          -- VertSplit = { fg = "muted", bg = "muted" },
          -- Visual = { fg = "base", bg = "text", inherit = false },
        },

        before_highlight = function(group, highlight, palette)
          -- Disable all undercurls
          -- if highlight.undercurl then
          --     highlight.undercurl = false
          -- end
          --
          -- Change palette colour
          -- if highlight.fg == palette.pine then
          --     highlight.fg = palette.foam
          -- end
        end,
      })
      vim.cmd("colorscheme rose-pine")
      background.load_preference()
      background.set_mode(background.current_index)

      vim.keymap.set("n", "<leader>tb", function()
        background.open_picker()
      end, { desc = "Change Background", silent = true })
    end,
  },

  -- hlchunk.nvim - Beautiful animated indentation and chunk highlighting
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        -- Chunk highlighting with beautiful animations
        chunk = {
          enable = false,
          priority = 15,
          use_treesitter = true,
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
          },
          textobject = "ic",           -- Inner chunk textobject
          max_file_size = 1024 * 1024, -- 1MB max file size
          error_sign = true,
          -- Animation settings for smooth effects
          duration = 200, -- Animation duration in ms
          delay = 300,    -- Animation delay in ms
          exclude_filetypes = {
            aerial = true,
            dashboard = true,
            alpha = true,
            lazy = true,
            mason = true,
            trouble = true,
            oil = true,
            NvimTree = true,
            ["neo-tree"] = true,
            terminal = true,
            toggleterm = true,
            notify = true,
            noice = true,
            TelescopePrompt = true,
            TelescopeResults = true,
            TelescopePreview = true,
            help = true,
          },
        },
        -- Indent line highlighting
        indent = {
          enable = false,
          priority = 10,
          use_treesitter = false, -- Keep false for better performance
          chars = { "│" }, -- Simple vertical line character
          ahead_lines = 5, -- Preview range
          delay = 100, -- Throttle delay for smooth scrolling
          exclude_filetypes = {
            aerial = true,
            dashboard = true,
            alpha = true,
            lazy = true,
            mason = true,
            trouble = true,
            oil = true,
            NvimTree = true,
            ["neo-tree"] = true,
            terminal = true,
            toggleterm = true,
            notify = true,
            noice = true,
            TelescopePrompt = true,
            TelescopeResults = true,
            TelescopePreview = true,
            help = true,
          },
        },
        -- Disable other features as requested
        line_num = {
          enable = false,
        },
        blank = {
          enable = false,
        },
      })
    end,
  },
  -- Better UI elements with enhanced theming
}
