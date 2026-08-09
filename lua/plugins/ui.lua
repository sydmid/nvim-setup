local background = require("core.ui.background")
local symbols = require("core.ui.symbols")

local symbol_pickers = require("core.ui.symbol_pickers")

local theme_opts = symbols.theme_opts

return {
  -- Kanagawa (only theme)
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        commentStyle = { italic = true },
        functionStyle = { bold = true },
        keywordStyle = { bold = true },
        statementStyle = { bold = true },
        background = {
          dark = "wave",
          light = "lotus",
        },
      })

      background.load_preference()
      background.set_mode(background.current_index)

      vim.keymap.set("n", "<leader>tb", function()
        background.open_picker()
      end, { desc = "Change Background", silent = true })
    end,
  },
  -- Highlight yanked text with enhanced styling
  {
    "machakann/vim-highlightedyank",
    event = "VeryLazy",
    config = function()
      -- Enhanced yank highlight with no-clown-fiesta colors
      vim.g.highlightedyank_highlight_duration = 200
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
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        signature = {
          auto_open = { enabled = false },
        }
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
      -- Enhanced command line styling
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖" },
        },
      },
      -- Enhanced messages styling
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext",
      },
    },
    config = function(_, opts)
      require("noice").setup(opts)
    end,
  },
  -- Telescope symbols (replaces symbols-outline with beautiful telescope UI)
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<D-o>",
        function()
          symbol_pickers.open_ordered_symbols_picker()
        end,
        desc = "Document Symbols (Hierarchical)",
      },
      {
        "<D-S-o>",
        function()
          symbol_pickers.open_symbol_type_filter_picker()
        end,
        desc = "Filter Document Symbols by Type",
      },
    },
  },
  -- Zellij Navigation
  {
    "swaits/zellij-nav.nvim",
    lazy = true,
    event = "VeryLazy",
    keys = {
      { "<c-h>", "<cmd>ZellijNavigateLeftTab<cr>",  { silent = true, desc = "navigate left or tab" } },
      { "<c-j>", "<cmd>ZellijNavigateDown<cr>",     { silent = true, desc = "navigate down" } },
      { "<c-k>", "<cmd>ZellijNavigateUp<cr>",       { silent = true, desc = "navigate up" } },
      { "<c-l>", "<cmd>ZellijNavigateRightTab<cr>", { silent = true, desc = "navigate right or tab" } },
    },
    opts = {},
  },
  -- Mini.icons for better which-key icon support
  {
    "echasnovski/mini.icons",
    version = false,
    config = true,
  },
  -- Show keys
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
    end,
    config = function()
      local wk = require("which-key")

      wk.setup({
        plugins = {
          marks = true,
          registers = true,
          presets = {
            operators = false,
            motions = false,
            text_objects = false,
            windows = false,
            nav = false,
            z = false,
            g = false,
          },
        },
        icons = {
          breadcrumb = "»",
          separator = "|",
          group = "+",
        },
        layout = {
          height = { min = 4, max = 25 },
          width = { min = 20, max = 50 },
          spacing = 3,
          -- align = "center",
        },
        show_help = false,
      })

      -- Register all the key groups
      wk.add({
        -- AI/Avante group with streamlined commands
        { "<leader>a",  group = "AI" },
        { "<leader>ai", desc = "Ask input" },
        { "<leader>af", desc = "Focus chat" },
        { "<leader>al", desc = "Clear chat" },
        -- Native Avante history features
        { "<leader>ah", desc = "Avante history" },
        { "[a",         desc = "Chat history selector" },
        { "]a",         desc = "Chat history selector" },
        -- Code assistance (visual mode)
        { "<leader>ae", desc = "Explain code" },
        { "<leader>at", desc = "Generate tests" },
        { "<leader>ar", desc = "Review code" },
        { "<leader>ad", desc = "Add docs" },
        { "<leader>ao", desc = "Optimize code" },
        -- Git integration
        { "<leader>ac", desc = "Commit message" },
        -- Other groups
        { "<leader>d",  group = "Debug" },
        { "<leader>e",  group = "Error Lens/Explorer" },
        { "<leader>b",  group = "Buffer" },
        { "<leader>c",  group = "Context/Code-Actions" },
        { "<leader>f",  group = "File/Find" },
        { "<leader>g",  group = "Git/Goto" },
        { "<leader>gc", group = "Conflicts" },
        { "<leader>h",  group = "Hunks/Git-Stage" },
        { "<leader>j",  group = "Jump" },
        { "<leader>k",  group = "Jump/Flash" },
        { "<leader>l",  group = "LSP" },
        { "<leader>p",  group = "Peek/Preview" },
        { "<leader>r",  group = "Rename/Refactor" },
        { "<leader>s",  group = "Snacks" },
        { "<leader>t",  group = "Toggles" },
        { "<leader>u",  group = "Test/Utils" },
        { "<leader>v",  group = "Visual/View" },
        { "<leader>x",  group = "Diagnostics/Trouble" },
        { "<leader>z",  group = "Fold" },
      })
    end,
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show()
        end,
        desc = "Show keymaps",
      },
    },
  },
  -- Add nvim-notify for notification support
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("notify").setup({
        timeout = 3000,
        max_width = 80,
        level = vim.log.levels.ERROR,
      })
    end,
  },
  -- nvim-scrollbar
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require("scrollbar").setup({
        show = true,
        show_in_active_only = false,
        set_highlights = true,
        folds = 1000,                -- handle folds, set to number to disable folds if no. of lines in buffer exceeds this
        max_lines = false,           -- disables if no. of lines in buffer exceeds this
        hide_if_all_visible = false, -- Hides everything if all lines are visible
        throttle_ms = 100,
        handle = {
          text = " ",
          blend = 30,                 -- Integer between 0 and 100. 0 for fully opaque and 100 to full transparent. Defaults to 30.
          color = nil,
          color_nr = nil,             -- cterm
          highlight = "CursorColumn",
          hide_if_all_visible = true, -- Hides handle if all lines are visible
        },
        marks = {
          Cursor = {
            text = "•",
            priority = 0,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "Normal",
          },
          Search = {
            text = { "-", "=" },
            priority = 1,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "Search",
          },
          Error = {
            text = { "-", "=" },
            priority = 2,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "DiagnosticVirtualTextError",
          },
          Warn = {
            text = { "-", "=" },
            priority = 3,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "DiagnosticVirtualTextWarn",
          },
          Info = {
            text = { "-", "=" },
            priority = 4,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "DiagnosticVirtualTextInfo",
          },
          Hint = {
            text = { "-", "=" },
            priority = 5,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "DiagnosticVirtualTextHint",
          },
          Misc = {
            text = { "-", "=" },
            priority = 6,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "Normal",
          },
          GitAdd = {
            text = "┆",
            priority = 7,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "GitSignsAdd",
          },
          GitChange = {
            text = "┆",
            priority = 7,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "GitSignsChange",
          },
          GitDelete = {
            text = "▁",
            priority = 7,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "GitSignsDelete",
          },
        },
        excluded_buftypes = {
          "terminal",
        },
        excluded_filetypes = {
          "blink-cmp-menu",
          "dropbar_menu",
          "dropbar_menu_fzf",
          "DressingInput",
          "cmp_docs",
          "cmp_menu",
          "noice",
          "prompt",
          "TelescopePrompt",
        },
        autocmd = {
          render = {
            "BufWinEnter",
            "TabEnter",
            "TermEnter",
            "WinEnter",
            "CmdwinLeave",
            "TextChanged",
            "VimResized",
            "WinScrolled",
          },
          clear = {
            "BufWinLeave",
            "TabLeave",
            "TermLeave",
            "WinLeave",
          },
        },
        handlers = {
          cursor = true,
          diagnostic = true,
          gitsigns = false, -- Requires gitsigns
          handle = true,
          search = false,   -- Requires hlslens
          ale = false,      -- Requires ALE
        },
      })
    end,
  },
  -- High-performance color highlighter
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufRead",
    config = function()
      require("colorizer").setup({
        "css",
        "html",
        "javascript",
        "typescript",
        "vue",
        "scss",
        "sass",
      }, {
        RGB = true,          -- #RGB hex codes
        RRGGBB = true,       -- #RRGGBB hex codes
        names = false,       -- Disable named colors to avoid false positives
        RRGGBBAA = false,    -- #RRGGBBAA hex codes
        rgb_fn = true,       -- CSS rgb() and rgba() functions
        hsl_fn = true,       -- CSS hsl() and hsla() functions
        css = true,          -- Enable all CSS features
        css_fn = true,       -- Enable all CSS *functions*
        mode = "background", -- Set the display mode
      })
    end,
  },
  -- Tabby.nvim - Beautiful and configurable tab line
  {
    "nanozuki/tabby.nvim",
    event = "VimEnter",
    enabled = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local theme = {
        fill = "TabLineFill",
        -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
        head = "TabLine",
        current_tab = "TabLineSel",
        tab = "TabLine",
        win = "TabLine",
        tail = "TabLine",
      }

      require("tabby.tabline").set(function(line)
        return {
          {
            { "  ", hl = theme.head },
            line.sep("", theme.head, theme.fill),
          },
          line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.tab
            return {
              line.sep("", hl, theme.fill),
              tab.is_current() and "" or "󰆣",
              tab.number(),
              tab.name(),
              tab.close_btn(""),
              line.sep("", hl, theme.fill),
              hl = hl,
              margin = " ",
            }
          end),
          line.spacer(),
          line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
            return {
              line.sep("", theme.win, theme.fill),
              win.is_current() and "" or "",
              win.buf_name(),
              line.sep("", theme.win, theme.fill),
              hl = theme.win,
              margin = " ",
            }
          end),
          {
            line.sep("", theme.tail, theme.fill),
            { "  ", hl = theme.tail },
          },
          hl = theme.fill,
        }
      end)
    end,
  },
  -- Enhanced cursorword highlighting (cursorline disabled to avoid conflicts)
  {
    "ya2s/nvim-cursorline",
    config = function()
      require('nvim-cursorline').setup({
        cursorline = {
          enable = true,
          timeout = 0,
          number = false,
        },
        cursorword = {
          enable = true,
          min_length = 3,
          hl = { underline = true },
        }
      })
    end,
  },
  -- Smooth scrolling animations for any movement
  {
    "declancm/cinnamon.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("cinnamon").setup({
        -- Enable both basic and extra keymaps for comprehensive smooth scrolling
        keymaps = {
          basic = false, -- Disabled: neoscroll.nvim handles C-u/C-d/C-f/C-b with finer control
          extra = false, -- Start/end of file/line, screen scrolling, up/down, left/right movements
        },
        options = {
          -- Animate cursor and window scrolling for any movement
          mode = "cursor",
          -- Don't require count for animation (smoother experience)
          count_only = false,
          -- Slightly faster delay for responsive feel
          delay = 4,
          max_delta = {
            -- Disable limits for line movements (always animate)
            line = false,
            -- Disable limits for column movements (always animate)
            column = false,
            -- Maximum duration for any movement (1 second)
            time = 1000,
          },
          step_size = {
            -- Smooth vertical movement (1 line per step)
            vertical = 1,
            -- Slightly larger horizontal steps for efficiency
            horizontal = 2,
          },
        },
      })

      -- Disable smooth scrolling for specific file types where it might be distracting
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "dashboard",
          "alpha",
          "lazy",
          "mason",
          "telescope",
          "TelescopePrompt",
          "TelescopeResults",
          "TelescopePreview",
          "notify",
          "noice",
          "NvimTree",
          "neo-tree",
          "oil",
          "trouble",
          "qf", -- quickfix
        },
        callback = function()
          vim.b.cinnamon_disable = true
        end,
      })
    end,
  },
  {
    "goolord/alpha-nvim",
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      local alpha = require("alpha")
      local theta = require("alpha.themes.theta")
      local dashboard = require("alpha.themes.dashboard")

      -- ── Helper: build the "Recent Projects" section ──────────────
      local function get_project_buttons()
        local session_dir = vim.fn.stdpath("data") .. "/sessions"
        local buttons = {}

        if vim.fn.isdirectory(session_dir) == 0 then
          return buttons
        end

        -- Collect session files sorted by modification time (newest first)
        local sessions = {}
        local handle = vim.loop.fs_scandir(session_dir)
        if handle then
          while true do
            local name, typ = vim.loop.fs_scandir_next(handle)
            if not name then break end
            if (typ == "file") and name:match("%.vim$") and name ~= ".vim" then
              local full = session_dir .. "/" .. name
              local stat = vim.loop.fs_stat(full)
              if stat then
                table.insert(sessions, { name = name, mtime = stat.mtime.sec })
              end
            end
          end
        end
        table.sort(sessions, function(a, b) return a.mtime > b.mtime end)

        -- Decode the URL-encoded path to a human-readable name
        local function decode(encoded)
          local decoded = encoded:gsub("%.vim$", "")
          decoded = decoded:gsub("%%(%x%x)", function(hex)
            return string.char(tonumber(hex, 16))
          end)
          return decoded
        end

        -- Use p1, p2, ... shortcuts to avoid conflict with theta's MRU numbers
        local max_projects = math.min(#sessions, 10)

        for i = 1, max_projects do
          local s = sessions[i]
          local project_path = decode(s.name)
          local display_name = vim.fn.fnamemodify(project_path, ":t")  -- last dir component
          local shortcut = "p" .. i

          -- Build restore command: cd to the decoded path, then restore the session
          local restore_cmd = string.format(
            "<cmd>cd %s | lua require('auto-session').restore_session()<CR>",
            vim.fn.fnameescape(project_path)
          )

          local btn = dashboard.button(
            shortcut,
            "  " .. display_name .. "  (" .. project_path .. ")",
            restore_cmd
          )
          btn.opts.width = 72
          table.insert(buttons, btn)
        end

        return buttons
      end

      -- ── Build the projects section ───────────────────────────────
      local projects_section = {
        type = "group",
        val = function()
          local heading = {
            type = "text",
            val = "  Recent Projects",
            opts = { hl = "SpecialComment", shrink_margin = false, position = "center" },
          }
          local project_btns = get_project_buttons()
          if #project_btns == 0 then
            return {
              heading,
              { type = "padding", val = 1 },
              { type = "text", val = "   No saved sessions yet", opts = { hl = "Comment", position = "center" } },
            }
          end
          local group = {
            heading,
            { type = "padding", val = 1 },
          }
          for _, btn in ipairs(project_btns) do
            table.insert(group, btn)
          end
          return group
        end,
      }

      -- ── Inject the projects section into theta's layout ──────────
      -- theta.config.layout is an ordered list of sections; we insert
      -- our projects section just before the last element (the footer).
      local layout = theta.config.layout
      -- Insert a padding + our section before the footer
      table.insert(layout, #layout, { type = "padding", val = 2 })
      table.insert(layout, #layout, projects_section)

      alpha.setup(theta.config)
    end,
  },
}
