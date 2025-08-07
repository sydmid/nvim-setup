return {
  -- Cheatsheet plugin - searchable cheatsheet using Telescope
  {
    "doctorfree/cheatsheet.nvim",
    event = "VeryLazy",
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
      { "nvim-lua/popup.nvim" },
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      local ctactions = require("cheatsheet.telescope.actions")
      require("cheatsheet").setup({
        bundled_cheatsheets = {
          enabled = { "default", "lua", "markdown", "regex", "netrw", "unicode" },
          disabled = { "nerd-fonts" },
        },
        bundled_plugin_cheatsheets = {
          enabled = {
            "auto-session",
            "goto-preview",
            "octo.nvim",
            "telescope.nvim",
            "vim-easy-align",
            "vim-sandwich",
            "gitsigns.nvim",
          },
          disabled = { "glow.nvim" },
        },
        include_only_installed_plugins = true,
        telescope_mappings = {
          ["<CR>"] = ctactions.select_or_fill_commandline,
          ["<A-CR>"] = ctactions.select_or_execute,
          ["<C-Y>"] = ctactions.copy_cheat_value,
          ["<C-E>"] = ctactions.edit_user_cheatsheet,
        },
      })

      -- Set keymap for cheatsheet
      vim.keymap.set("n", "<leader>cc", "<cmd>Cheatsheet<CR>", {
        desc = "Open cheatsheet",
        silent = true
      })
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      local nvimtree = require("nvim-tree")

      -- recommended settings from nvim-tree documentation
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      nvimtree.setup({
        view = {
          width = 40,
          relativenumber = false,
          number = false,
          signcolumn = "no",
          side = "right",
        },
        -- Enhanced icons with Catppuccin-style aesthetics
        renderer = {
          add_trailing = false,
          group_empty = true,
          highlight_git = "icon",
          full_name = false,
          highlight_opened_files = "icon",
          highlight_modified = "none",
          highlight_clipboard = "none",
          root_folder_modifier = ":t",
          indent_width = 2,
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = "└",
              edge = "│",
              item = "│",
              bottom = "─",
              none = " ",
            },
          },
          icons = {
            webdev_colors = true,
            git_placement = "after",
            modified_placement = "after",
            padding = "",
            symlink_arrow = "→",
            show = {
              file = true,
              folder = false,
              folder_arrow = true,
              git = true,
              modified = false,
              diagnostics = false,
              bookmarks = false,
            },
            glyphs = {
              default = "󰈔",
              symlink = "󰌷",
              bookmark = "󰆤",
              modified = "●",
              hidden = "󰜌",
              folder = {
                arrow_closed = "󰅂", -- Catppuccin chevron right
                arrow_open = "󰅀", -- Catppuccin chevron down
                default = "󰉋", -- Folder icon
                open = "󰝰", -- Open folder
                empty = "󰉖", -- Empty folder
                empty_open = "󰷏", -- Empty open folder
                symlink = "󰉒", -- Symlinked folder
                symlink_open = "󰉒", -- Open symlinked folder
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "≠",
                renamed = "→",
                untracked = "?",
                deleted = "✖",
                ignored = "◌",
              },
            },
          },
        },
        -- disable window_picker for
        -- explorer to work well with
        -- window splits
        actions = {
          open_file = {
            window_picker = {
              enable = false,
            },
          },
        },
        filters = {
          custom = { ".DS_Store" },
        },
        git = {
          ignore = false,
        },
        live_filter = {
          prefix = "[FILTER]: ",
          always_show_folders = false,
        },
        -- Custom window options for smaller font
        on_attach = function(bufnr)
          -- Set smaller font size for nvim-tree window (30% smaller)
          vim.api.nvim_create_autocmd("BufWinEnter", {
            buffer = bufnr,
            callback = function()
              local win = vim.fn.bufwinid(bufnr)
              if win ~= -1 then
                -- Get current global font size
                local current_font = vim.o.guifont
                if current_font and current_font ~= "" then
                  -- Extract size from font string (e.g., "Source Code Pro:h14" -> 14)
                  local size = current_font:match(":h(%d+)")
                  if size then
                    local new_size = math.floor(tonumber(size) * 0.7) -- 30% smaller
                    local new_font = current_font:gsub(":h%d+", ":h" .. new_size)
                    vim.api.nvim_win_call(win, function()
                      vim.opt_local.guifont = new_font
                    end)
                  end
                end
              end
            end,
          })

          local api = require("nvim-tree.api")

          local function opts(desc)
            return {
              desc = "nvim-tree: " .. desc,
              buffer = bufnr,
              noremap = true,
              silent = true,
              nowait = true,
            }
          end

          vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
          -- Custom Enter behavior: Open file and close nvim-tree
          vim.keymap.set("n", "<CR>", function()
            local node = api.tree.get_node_under_cursor()
            if node and node.type == "file" then
              -- Open the file
              api.node.open.edit()
              -- Close nvim-tree
              api.tree.close()
            else
              -- For directories, use default behavior (expand/collapse)
              api.node.open.edit()
            end
          end, opts("Open file and close tree"))
          -- Custom 'o' behavior: Open file, keep tree open and focused on tree
          vim.keymap.set("n", "o", function()
            local node = api.tree.get_node_under_cursor()
            if node and node.type == "file" then
              -- Open the file
              api.node.open.edit()
              -- Keep focus on nvim-tree by explicitly focusing it
              vim.defer_fn(function()
                -- Find nvim-tree window and focus it
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  local buf = vim.api.nvim_win_get_buf(win)
                  local buf_name = vim.api.nvim_buf_get_name(buf)
                  if buf_name:match("NvimTree_") then
                    vim.api.nvim_set_current_win(win)
                    break
                  end
                end
              end, 10)
            else
              -- For directories, use default behavior
              api.node.open.edit()
            end
          end, opts("Open file, keep tree open and focused"))
          -- Custom 'O' behavior: Open file, keep tree open but focus main buffer
          vim.keymap.set("n", "O", function()
            local node = api.tree.get_node_under_cursor()
            if node and node.type == "file" then
              -- Open the file and let focus go to the opened file (default behavior)
              api.node.open.edit()
            else
              -- For directories, use no_window_picker behavior
              api.node.open.no_window_picker()
            end
          end, opts("Open file, keep tree open, focus main buffer"))
        end,
      })

      -- Set custom colors for folder arrows and hierarchy lines
      vim.api.nvim_set_hl(0, "NvimTreeFolderArrowClosed", { fg = "#9b9d9c" })
      vim.api.nvim_set_hl(0, "NvimTreeFolderArrowOpen", { fg = "#e5b674" })
      vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = "#e5b674" })
      vim.api.nvim_set_hl(0, "NvimTreeFolderName", { fg = "#9b9d9c" })
      vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = "#e5b674" })

      -- Ensure the highlights persist across colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("NvimTreeCustomColors", { clear = true }),
        callback = function()
          vim.api.nvim_set_hl(0, "NvimTreeFolderArrowClosed", { fg = "#9b9d9c" })
          vim.api.nvim_set_hl(0, "NvimTreeFolderArrowOpen", { fg = "#e5b674" })
          vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = "#e5b674" })
          vim.api.nvim_set_hl(0, "NvimTreeFolderName", { fg = "#9b9d9c" })
          vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = "#e5b674" })
        end,
      })
    end,
  },

  -- Flash (EasyMotion replacement)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>k",
        function()
          require("flash").jump()
        end,
        desc = "Flash Jump",
      },
      {
        "<leader>j",
        function()
          require("flash").jump({ search = { forward = true, wrap = false, multi_window = false } })
        end,
        desc = "Flash Forward",
      },
    },
  },

  -- Harpoon for quick file navigation
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Cybu - VSCode-like buffer switching
  {
    "ghillb/cybu.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
    config = function()
      require("cybu").setup({
        position = {
          relative_to = "win",   -- win, editor, cursor
          anchor = "center",     -- topleft, topcenter, topright, centerleft, center, centerright, bottomleft, bottomcenter, bottomright
          vertical_offset = 0,   -- vertical offset from anchor in lines
          horizontal_offset = 0, -- vertical offset from anchor in columns
          max_win_height = 5,    -- height of cybu window in lines
          max_win_width = 1.5,   -- integer for absolute in columns, float for relative to win/editor width
        },
        style = {
          path = "tail", -- absolute, relative, tail (filename only)
          path_abbreviation = "none", -- none, shortened
          border = "rounded", -- single, double, rounded, none
          separator = " ", -- string used as separator
          prefix = "…", -- string used as prefix for truncated paths
          padding = 1, -- left & right padding in columns
          hide_buffer_id = true, -- hide buffer IDs in window
          devicons = {
            enabled = true, -- enable or disable web dev icons
            colored = true, -- color devicons
            truncate = true, -- truncate wide icons
          },
          highlights = { -- see highlights via :highlight
            current_buffer = "CybuFocus",
            adjacent_buffers = "CybuAdjacent",
            background = "CybuBackground",
            border = "CybuBorder",
          },
        },
        behavior = { -- set behavior for different modes
          mode = {
            default = {
              switch = "immediate", -- immediate, on_close
              view = "rolling",     -- paging, rolling
            },
            last_used = {
              switch = "immediate", -- immediate, on_close
              view = "paging",      -- paging, rolling
            },
            auto = {
              view = "rolling", -- paging, rolling
            },
          },
          show_on_autocmd = false, -- event to trigger cybu (eg. "BufEnter")
        },
        display_time = 1000,       -- time the cybu window is displayed
        exclude = {                -- filetypes, buftypes to exclude
          "neo-tree",
          "fugitive",
          "qf",
        },
        fallback = function() end, -- arbitrary fallback function used in excluded filetypes
      })

      -- Custom highlight groups for better integration with your theme
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("CybuHighlights", { clear = true }),
        callback = function()
          -- Set highlights that work well with modern themes
          vim.api.nvim_set_hl(0, "CybuFocus", { fg = "#89b4fa", bg = "#313244", bold = true })
          vim.api.nvim_set_hl(0, "CybuAdjacent", { fg = "#cdd6f4", bg = "#1e1e2e" })
          vim.api.nvim_set_hl(0, "CybuBackground", { bg = "#1e1e2e" })
          vim.api.nvim_set_hl(0, "CybuBorder", { fg = "#89b4fa" })
        end,
      })

      -- Set initial highlights
      vim.api.nvim_set_hl(0, "CybuFocus", { fg = "#89b4fa", bg = "#313244", bold = true })
      vim.api.nvim_set_hl(0, "CybuAdjacent", { fg = "#cdd6f4", bg = "#1e1e2e" })
      vim.api.nvim_set_hl(0, "CybuBackground", { bg = "#1e1e2e" })
      vim.api.nvim_set_hl(0, "CybuBorder", { fg = "#89b4fa" })

      -- VSCode-like keybindings for buffer switching
      vim.keymap.set("n", "<C-Tab>", "<Plug>(CybuLastusedNext)", { desc = "Next buffer (VSCode-like)" })
      vim.keymap.set("n", "<C-S-Tab>", "<Plug>(CybuLastusedPrev)", { desc = "Previous buffer (VSCode-like)" })
    end,
  },

  -- Buffer manager - Enhanced buffer management with UI
  {
    "j-morano/buffer_manager.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local opts = { noremap = true, silent = true }
      local ui = require("buffer_manager.ui")

      -- Setup buffer_manager
      require("buffer_manager").setup({
        select_menu_item_commands = {
          v = {
            key = "<C-v>",
            command = "vsplit"
          },
          h = {
            key = "<C-h>",
            command = "split"
          }
        },
        focus_alternate_buffer = false,
        short_file_names = true,
        short_term_names = true,
        loop_nav = true,
      })

      -- Set keymaps for buffer_manager
      vim.keymap.set("n", "<D-2>", ui.toggle_quick_menu, opts)
      vim.keymap.set("n", "<M-h>", ui.nav_prev, opts)
      vim.keymap.set("n", "<M-l>", ui.nav_next, opts)
    end,
  },

  -- Surround text
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Trouble (diagnostics, references, etc.)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
    opts = {
      focus = true,
    },
    cmd = "Trouble",
    keys = {
      { "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
      {
        "<leader>xd",
        "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
        desc = "Open trouble document diagnostics",
      },
      { "<leader>xq", "<cmd>Trouble quickfix toggle<CR>",    desc = "Open trouble quickfix list" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<CR>",     desc = "Open trouble location list" },
      { "<leader>xt", "<cmd>Trouble todo toggle<CR>",        desc = "Open todos in trouble" },
    },
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,  -- show icons in the signs column
      sign_priority = 8, -- sign priority
      -- keywords recognized as todo comments
      keywords = {
        FIX = {
          icon = " ", -- icon used for the sign, and in search results
          color = "error", -- can be a hex color, or a named color (see below)
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      gui_style = {
        fg = "NONE",     -- The gui style to use for the fg highlight group.
        bg = "BOLD",     -- The gui style to use for the bg highlight group.
      },
      merge_keywords = true, -- when true, custom keywords will be merged with the defaults
      -- highlighting of the line containing the todo comment
      -- * before: highlights before the keyword (typically comment characters)
      -- * keyword: highlights of the keyword
      -- * after: highlights after the keyword (todo text)
      highlight = {
        multiline = true,            -- enable multine todo comments
        multiline_pattern = "^.",    -- lua pattern to match the next multiline from the start of the matched keyword
        multiline_context = 10,      -- extra lines that will be re-evaluated when changing a line
        before = "",                 -- "fg" or "bg" or empty
        keyword = "wide",            -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
        after = "fg",                -- "fg" or "bg" or empty
        pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
        comments_only = true,        -- uses treesitter to match keywords in comments only
        max_line_len = 400,          -- ignore lines longer than this
        exclude = {},                -- list of file types to exclude highlighting
      },
      -- list of named colors where we try to extract the guifg from the
      -- list of highlight groups or use the hex color if hl not found as a fallback
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
        test = { "Identifier", "#FF00FF" }
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        -- regex that will be used to match keywords.
        -- don't replace the (KEYWORDS) placeholder
        pattern = [[\b(KEYWORDS):]], -- ripgrep regex
        -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
      },
    }
  },
  -- Visual Whitespace - Show whitespace characters in visual mode like VSCode
  {
    "mcauley-penney/visual-whitespace.nvim",
    event = "ModeChanged *:[vV\22]*", -- lazy load on entering any visual mode
    config = function()
      require("visual-whitespace").setup({
        enabled = false, -- default visibility off
        highlight = { link = "Visual", default = true },
        match_types = {
          space = true,
          tab = true,
          nbsp = true,
          lead = false,  -- set to false by default as per docs
          trail = false, -- set to false by default as per docs
        },
        list_chars = {
          space = "·",
          tab = "↦", -- using the recommended character from docs
          nbsp = "␣",
          lead = "‹",
          trail = "›",
        },
        fileformat_chars = {
          unix = "↲",
          mac = "←",
          dos = "↙",
        },
        ignore = {
          filetypes = { "help", "dashboard", "alpha", "lazy", "mason", "trouble", "oil", "NvimTree" },
          buftypes = { "terminal", "nofile", "quickfix", "prompt", "acwrite" }
        },
      })
    end,
    init = function()
      -- Set custom highlight for visual whitespace (recommended in docs)
      -- This goes in init to ensure it's set before the plugin loads
      vim.api.nvim_set_hl(0, "VisualNonText", {
        fg = "#5D5F71",
        bg = "#24282d",
        italic = true
      })
    end,
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  }
}