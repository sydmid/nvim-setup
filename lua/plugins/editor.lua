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

  -- OIL
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      CustomOilBar = function()
        local path = vim.fn.expand("%")
        path = path:gsub("oil://", "")

        return "  " .. vim.fn.fnamemodify(path, ":.")
      end

      require("oil").setup({
        -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
        -- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
        default_file_explorer = true,
        -- Id is automatically added at the beginning, and name at the end
        -- See :help oil-columns
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },
        -- Buffer-local options to use for oil buffers
        buf_options = {
          buflisted = false,
          bufhidden = "hide",
        },
        -- Window-local options to use for oil buffers
        win_options = {
          wrap = false,
          signcolumn = "no",
          cursorcolumn = false,
          foldcolumn = "0",
          spell = false,
          list = false,
          conceallevel = 3,
          concealcursor = "nvic",
        },
        delete_to_trash = false,
        -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
        skip_confirm_for_simple_edits = false,
        -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
        -- (:help prompt_save_on_select_new_entry)
        prompt_save_on_select_new_entry = true,
        -- Oil will automatically delete hidden buffers after this delay
        -- You can set the delay to false to disable cleanup entirely
        cleanup_delay_ms = 2000,
        lsp_file_methods = {
          -- Enable or disable LSP file operations
          enabled = true,
          -- Time to wait for LSP file operations to complete before skipping
          timeout_ms = 1000,
          -- Set to true to autosave buffers that are updated with LSP willRenameFiles
          -- Set to "unmodified" to only save unmodified buffers
          autosave_changes = false,
        },
        -- Constrain the cursor to the editable parts of the oil buffer
        -- Set to `false` to disable, or "name" to keep it on the file names
        constrain_cursor = "editable",
        -- Set to true to watch the filesystem for changes and reload oil
        watch_for_changes = false,
        -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
        -- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
        -- Additionally, if it is a string that matches "actions.<name>",
        -- it will use the mapping at require("oil.actions").<name>
        -- Set to `false` to remove a keymap
        -- See :help oil-actions for a list of all available actions
        keymaps = {
          ["g?"] = { "actions.show_help", mode = "n" },
          ["<CR>"] = "actions.select",
          ["<C-s>"] = { "actions.select", opts = { vertical = true } },
          ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
          ["<C-t>"] = { "actions.select", opts = { tab = true } },
          ["<C-p>"] = "actions.preview",
          ["<Esc>"] = { "actions.close", mode = "n" },
          ["<C-l>"] = "actions.refresh",
          ["-"] = { "actions.parent", mode = "n" },
          ["_"] = { "actions.open_cwd", mode = "n" },
          ["`"] = { "actions.cd", mode = "n" },
          ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
          ["ss"] = { "actions.change_sort", mode = "n" },
          ["ee"] = "actions.open_external",
          ["hh"] = { "actions.toggle_hidden", mode = "n" },
          ["g\\"] = { "actions.toggle_trash", mode = "n" },
        },
        -- Set to false to disable all of the above keymaps
        use_default_keymaps = true,
        view_options = {
          -- Show files and directories that start with "."
          show_hidden = false,
          -- This function defines what is considered a "hidden" file
          is_hidden_file = function(name, bufnr)
            local m = name:match("^%.")
            return m ~= nil
          end,
          -- This function defines what will never be shown, even when `show_hidden` is set
          is_always_hidden = function(name, bufnr)
            return false
          end,
          -- Sort file names with numbers in a more intuitive order for humans.
          -- Can be "fast", true, or false. "fast" will turn it off for large directories.
          natural_order = "fast",
          -- Sort file and directory names case insensitive
          case_insensitive = false,
          sort = {
            -- sort order can be "asc" or "desc"
            -- see :help oil-columns to see which columns are sortable
            { "type", "asc" },
            { "name", "asc" },
          },
          -- Customize the highlight group for the file name
          highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
            return nil
          end,
        },
        -- Extra arguments to pass to SCP when moving/copying files over SSH
        extra_scp_args = {},
        -- EXPERIMENTAL support for performing file operations with git
        git = {
          -- Return true to automatically git add/mv/rm files
          add = function(path)
            return false
          end,
          mv = function(src_path, dest_path)
            return false
          end,
          rm = function(path)
            return false
          end,
        },
        -- Configuration for the floating window in oil.open_float
        float = {
          -- Padding around the floating window
          padding = 2,
          -- max_width and max_height can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
          max_width = 0,
          max_height = 0,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
          -- optionally override the oil buffers window title with custom function: fun(winid: integer): string
          get_win_title = nil,
          -- preview_split: Split direction: "auto", "left", "right", "above", "below".
          preview_split = "auto",
          -- This is the config that will be passed to nvim_open_win.
          -- Change values here to customize the layout
          override = function(conf)
            return conf
          end,
        },
        -- Configuration for the file preview window
        preview_win = {
          -- Whether the preview window is automatically updated when the cursor is moved
          update_on_cursor_moved = true,
          -- How to open the preview window "load"|"scratch"|"fast_scratch"
          preview_method = "fast_scratch",
          -- A function that returns true to disable preview on a file e.g. to avoid lag
          disable_preview = function(filename)
            return false
          end,
          -- Window-local options to use for preview window buffers
          win_options = {},
        },
        -- Configuration for the floating action confirmation window
        confirmation = {
          -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
          -- min_width and max_width can be a single value or a list of mixed integer/float types.
          -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
          max_width = 0.9,
          -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
          min_width = { 40, 0.4 },
          -- optionally define an integer/float for the exact width of the preview window
          width = nil,
          -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
          -- min_height and max_height can be a single value or a list of mixed integer/float types.
          -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
          max_height = 0.9,
          -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
          min_height = { 5, 0.1 },
          -- optionally define an integer/float for the exact height of the preview window
          height = nil,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
        },
        -- Configuration for the floating progress window
        progress = {
          max_width = 0.9,
          min_width = { 40, 0.4 },
          width = nil,
          max_height = { 10, 0.9 },
          min_height = { 5, 0.1 },
          height = nil,
          border = "rounded",
          minimized_border = "none",
          win_options = {
            winblend = 0,
          },
        },
        -- Configuration for the floating SSH window
        ssh = {
          border = "rounded",
        },
        -- Configuration for the floating keymaps help window
        keymaps_help = {
          border = "rounded",
        },
      })
      -- Open parent directory in current window
      vim.keymap.set("n", "<BS>", "<CMD>Oil<CR>", { desc = "Open parent directory" })
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
          indent_width = 1,
          indent_markers = {
            enable = false,
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

          -- Apply default mappings except for Tab
          -- BEGIN_DEFAULT_ON_ATTACH
          vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
          vim.keymap.set("n", "<C-e>", api.node.open.replace_tree_buffer, opts("Open: In Place"))
          vim.keymap.set("n", "<C-k>", api.node.show_info_popup, opts("Info"))
          vim.keymap.set("n", "<C-r>", api.fs.rename_sub, opts("Rename: Omit Filename"))
          vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
          vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts("Open: Vertical Split"))
          vim.keymap.set("n", "<C-x>", api.node.open.horizontal, opts("Open: Horizontal Split"))
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

          -- vim.keymap.set("n", "<Tab>",          api.node.open.preview,              opts("Open Preview")) -- Disabled to use global Tab mapping
          vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
          vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
          vim.keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))
          vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("Up"))
          vim.keymap.set("n", "B", api.tree.toggle_no_buffer_filter, opts("Toggle Filter: No Buffer"))
          vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
          vim.keymap.set("n", "C", api.tree.toggle_git_clean_filter, opts("Toggle Filter: Git Clean"))
          vim.keymap.set("n", "<leader>gc", api.node.navigate.git.prev, opts("Prev Git"))
          vim.keymap.set("n", "<leader>gC", api.node.navigate.git.next, opts("Next Git"))
          vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
          vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
          vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
          vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
          vim.keymap.set("n", "F", api.live_filter.clear, opts("Live Filter: Clear"))
          vim.keymap.set("n", "f", api.live_filter.start, opts("Live Filter: Start"))
          vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
          vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
          vim.keymap.set("n", "ge", api.fs.copy.basename, opts("Copy Basename"))
          vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Filter: Dotfiles"))
          vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
          vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
          vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))
          vim.keymap.set("n", "L", api.node.open.toggle_group_empty, opts("Toggle Group Empty"))
          vim.keymap.set("n", "M", api.tree.toggle_no_bookmark_filter, opts("Toggle Filter: No Bookmark"))

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
          vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
          vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
          vim.keymap.set("n", "q", api.tree.close, opts("Close"))
          vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
          vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
          vim.keymap.set("n", "s", api.node.run.system, opts("Run System"))
          vim.keymap.set("n", "S", api.tree.search_node, opts("Search"))
          vim.keymap.set("n", "u", api.fs.rename_full, opts("Rename: Full Path"))
          vim.keymap.set("n", "U", api.tree.toggle_custom_filter, opts("Toggle Filter: Hidden"))
          vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse"))
          vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
          vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))
          vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("Copy Relative Path"))
          vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
          vim.keymap.set("n", "<2-RightMouse>", api.tree.change_root_to_node, opts("CD"))
          -- END_DEFAULT_ON_ATTACH

          -- Custom mapping: Use `/` for live filter instead of global search
          vim.keymap.set("n", "/", api.live_filter.start, opts("Live Filter: Start"))
          -- Custom mapping: Use `//` for clearing live filter
          vim.keymap.set("n", "//", api.live_filter.clear, opts("Live Filter: Clear"))
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
          anchor = "center",  -- topleft, topcenter, topright, centerleft, center, centerright, bottomleft, bottomcenter, bottomright
          vertical_offset = 0,  -- vertical offset from anchor in lines
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
              switch = "on_close", -- immediate, on_close
              view = "paging",     -- paging, rolling
            },
            auto = {
              view = "rolling", -- paging, rolling
            },
          },
          show_on_autocmd = false, -- event to trigger cybu (eg. "BufEnter")
        },
        display_time = 500,        -- time the cybu window is displayed
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

  -- Surround text
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Terminal integration with management system
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("toggleterm").setup({
        size = 20,
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
        auto_scroll = false, -- Disable auto-scroll to allow manual cursor control
        float_opts = {
          border = "curved",
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
          width = math.floor(vim.o.columns * 0.85),
          height = math.floor(vim.o.lines * 0.85),
        },
      })

      -- Initialize terminal management system
      require("config.terminals").setup({
        terminal_size = 20,
        direction = "float",
        float_opts = {
          border = "curved",
          winblend = 0,
          width = math.floor(vim.o.columns * 0.85),
          height = math.floor(vim.o.lines * 0.85),
        },
      })
    end,
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