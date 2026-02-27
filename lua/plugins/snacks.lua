-- Snacks.nvim - A collection of useful Neovim utilities
-- Integrated with existing which-key groups and nvim architecture
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false }, -- Using existing indent configuration
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
      -- Only show error notifications by default
      style = "compact",
      top_down = true,
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      -- Custom filter to only show errors and warnings
      filter = function(notif)
        -- Handle both string and number levels
        local level = notif.level
        if type(level) == "string" then
          -- Convert string levels to numbers
          local level_map = {
            ERROR = vim.log.levels.ERROR,
            WARN = vim.log.levels.WARN,
            INFO = vim.log.levels.INFO,
            DEBUG = vim.log.levels.DEBUG,
          }
          level = level_map[level] or vim.log.levels.INFO
        end
        -- Only show ERROR and WARN level notifications
        return level and level >= vim.log.levels.WARN
      end,
    },
    picker = {
      enabled = true,
      layout = {
        -- presets options : "default" , "ivy" , "ivy-split" , "telescope" , "vscode", "select" , "sidebar"
        -- override picker layout in keymaps function as a param below
        preset = "telescope", -- defaults to this layout unless overidden
        cycle = false,
      },
      layouts = {
        select = {
          preview = false,
          layout = {
            backdrop = false,
            width = 0.6,
            min_width = 80,
            height = 0.4,
            min_height = 10,
            box = "vertical",
            border = "rounded",
            title = "{title}",
            title_pos = "center",
            { win = "input",   height = 1,          border = "bottom" },
            { win = "preview", title = "{preview}", width = 0.6,      height = 0.4, border = "top" },
            { win = "list",    border = "none" },
          }
        },
        telescope = {
          reverse = false, -- set to false for search bar to be on top
          layout = {
            box = "horizontal",
            backdrop = false,
            width = 0.8,
            height = 0.9,
            border = "none",
            {
              box = "vertical",
              { win = "input", height = 1,          border = "rounded",   title = "{title} {live} {flags}", title_pos = "center" },
              { win = "list",  title = " Results ", title_pos = "center", border = "rounded" },
            },
            {
              win = "preview",
              title = "{preview:Preview}",
              width = 0.50,
              border = "rounded",
              title_pos = "center",
            },
          },
        },
        ivy = {
          layout = {
            box = "vertical",
            backdrop = false,
            width = 0,
            height = 0.4,
            position = "bottom",
            border = "top",
            title = " {title} {live} {flags}",
            title_pos = "left",
            { win = "input", height = 1, border = "bottom" },
            {
              box = "horizontal",
              { win = "list",    border = "none" },
              { win = "preview", title = "{preview}", width = 0.5, border = "left" },
            },
          },
        },
      },
      layout = {
        -- presets options : "default" , "ivy" , "ivy-split" , "telescope" , "vscode", "select" , "sidebar"
        -- override picker layout in keymaps function as a param below
        preset = "telescope", -- defaults to this layout unless overidden
        cycle = false,
      },
      layouts = {
        select = {
          preview = false,
          layout = {
            backdrop = false,
            width = 0.6,
            min_width = 80,
            height = 0.4,
            min_height = 10,
            box = "vertical",
            border = "rounded",
            title = "{title}",
            title_pos = "center",
            { win = "input",   height = 1,          border = "bottom" },
            { win = "preview", title = "{preview}", width = 0.6,      height = 0.4, border = "top" },
            { win = "list",    border = "none" },
          }
        },
        telescope = {
          reverse = false, -- set to false for search bar to be on top
          layout = {
            box = "horizontal",
            backdrop = false,
            width = 0.8,
            height = 0.9,
            border = "none",
            {
              box = "vertical",
              { win = "input", height = 1,          border = "rounded",   title = "{title} {live} {flags}", title_pos = "center" },
              { win = "list",  title = " Results ", title_pos = "center", border = "rounded" },
            },
            {
              win = "preview",
              title = "{preview:Preview}",
              width = 0.50,
              border = "rounded",
              title_pos = "center",
            },
          },
        },
        ivy = {
          layout = {
            box = "vertical",
            backdrop = false,
            width = 0,
            height = 0.4,
            position = "bottom",
            border = "top",
            title = " {title} {live} {flags}",
            title_pos = "left",
            { win = "input", height = 1, border = "bottom" },
            {
              box = "horizontal",
              { win = "list",    border = "none" },
              { win = "preview", title = "{preview}", width = 0.5, border = "left" },
            },
          },
        },
      },
      exclude = { -- add folder names here to exclude
        ".DS_STORE",
        "node_modules",
        "*.meta",
      },
      sources = {
        files = { hidden = true },
      },
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false }, -- Using existing scroll configuration
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      notification = {
        -- wo = { wrap = true } -- Wrap notifications
      },
    },
  },

  keys = {
    -- File/Find group (<leader>f) - Core file operations
    {
      "<leader>f?",
      function()
        Snacks.picker()
      end,
      desc = "Find Files",
    },
    -- {
    --   "<D-p>",
    --   function()
    --     Snacks.picker.recent({
    --       layout = "vscode",
    --       exclude = {
    --         ".git",
    --         "*.meta",
    --       },
    --       ignored = false,
    --     })
    --   end,
    --   desc = "Smart File Picker (git-aware)",
    -- },
    {
      "<D-p>",
      function()
        require("telescope").extensions.smart_open.smart_open {
          cwd_only = true,
          filename_first = false,
        }
      end,
      desc = "Smart File Picker (git-aware)",
    },

    {
      "<leader>fc",
      function()
        Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "Find Config File",
    },
    {
      "<D-P>",
      function()
        Snacks.picker.projects()
      end,
      desc = "Projects",
    },
    {
      "<leader>fb",
      function()
        Snacks.picker.buffers({
          win = {
            input = {
              keys = {
                ["dd"] = "bufdelete",
                ["<c-d>"] = { "bufdelete", mode = { "n", "i" } },
              },
            },
            list = {
              keys = {
                ["dd"] = "bufdelete",
              },
            },
          },
          on_show = function(picker)
            -- force normal mode right after opening
            vim.schedule(function()
              vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
                "n",
                false
              )
            end)
          end,
        })
      end,
      desc = "Open Buffers",
    },
    {
      "<leader>bd",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Buffer",
    },
    {
      "<D-S-f>",
      function()
        Snacks.picker.grep_word({
          on_show = function(picker)
            -- force normal mode right after opening
            vim.schedule(function()
              vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
                "n",
                false
              )
            end)
          end,
        })
      end,
      desc = "Grep Text",
      mode = { "x" },
    },
    {
      "<D-S-f>",
      function()
        Snacks.picker.grep()
      end,
      desc = "Visual selection or word",
      mode = { "n" },
    },
    {
      "<leader>sb",
      function()
        Snacks.picker.lines()
      end,
      desc = "Buffer Lines",
    },
    {
      "<leader>s/",
      function()
        Snacks.picker.search_history()
      end,
      desc = "Search History",
    },
    {
      "<leader>s\"",
      function()
        Snacks.picker.registers()
      end,
      desc = "Registers",
    },
    { "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal" },
    { "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal" },
    {
      "<leader>sa",
      function()
        Snacks.picker.autocmds()
      end,
      desc = "Autocmds",
    },
    {
      "<leader>sc",
      function()
        Snacks.picker.commands()
      end,
      desc = "Commands",
    },
    -- {
    --   "<leader>sd",
    --   function()
    --     Snacks.picker.diagnostics()
    --   end,
    --   desc = "Diagnostics",
    -- },
    -- {
    --   "<leader>sD",
    --   function()
    --     Snacks.picker.diagnostics_buffer()
    --   end,
    --   desc = "Buffer Diagnostics",
    -- },
    {
      "<leader>sh",
      function()
        Snacks.picker.help()
      end,
      desc = "Help Pages",
    },
    {
      "<leader>sH",
      function()
        Snacks.picker.highlights()
      end,
      desc = "Highlights",
    },
    {
      "<leader>sj",
      function()
        Snacks.picker.jumps()
      end,
      desc = "Jumps",
    },
    {
      "<leader>sk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Keymaps",
    },
    {
      "<leader>sl",
      function()
        Snacks.picker.loclist()
      end,
      desc = "Location List",
    },
    {
      "<leader>sm",
      function()
        Snacks.picker.marks()
      end,
      desc = "Marks",
    },
    {
      "<leader>sM",
      function()
        Snacks.picker.man()
      end,
      desc = "Man Pages",
    },
    {
      "<leader>sp",
      function()
        Snacks.picker.lazy()
      end,
      desc = "Search for Plugin Spec",
    },
    {
      "<leader>sq",
      function()
        Snacks.picker.qflist()
      end,
      desc = "Quickfix List",
    },
    {
      "<leader>sR",
      function()
        Snacks.picker.resume()
      end,
      desc = "Resume",
    },
    {
      "<leader>su",
      function()
        Snacks.picker.undo()
      end,
      desc = "Undo History",
    },

    -- Git/Goto group (<leader>g) - Git operations
    -- {
    --   "<leader>gb",
    --   function()
    --     Snacks.picker.git_branches()
    --   end,
    --   desc = "Git Branches",
    -- },
    {
      "<leader>gl",
      function()
        Snacks.lazygit.log()
        Snacks.lazygit.log()
      end,
      desc = "Git Log",
    },
    {
      "<leader>gL",
      function()
        Snacks.picker.git_log()
        Snacks.picker.git_log()
      end,
      desc = "Git Log Line",
    },
    {
      "<leader>gS",
      function()
        Snacks.picker.git_stash()
      end,
      desc = "Git Stash",
    },
    {
      "<leader>gd",
      function()
        Snacks.picker.git_diff()
      end,
      desc = "Git Diff (Hunks)",
    },
    {
      "<leader>gB",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Git Browse",
      mode = { "n", "v" },
    },
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },

    -- LSP group (<leader>l) - LSP symbols and workspace
    {
      "<leader>ls",
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = "LSP Symbols",
    },

    -- Workspace/Tabs group (<leader>w) - Workspace operations
    {
      "<leader>ws",
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = "LSP Workspace Symbols",
    },

    -- Test/Utils group (<leader>u) - Utility toggles and tools
    {
      "<leader>uc",
      function()
        Snacks.picker.colorschemes()
      end,
      desc = "Colorschemes",
    },
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss All Notifications",
    },

    -- Navigation group (<leader>n) - Notification history
    {
      "<leader>nn",
      function()
        Snacks.picker.notifications()
      end,
      desc = "Notification History",
    },
    {
      "<leader>nh",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },

    -- Context/Code-Actions group (<leader>c) - Code operations
    {
      "<leader>cR",
      function()
        Snacks.rename.rename_file()
      end,
      desc = "Rename File",
    },

    -- Visual/View group (<leader>v) - View modes
    {
      "<leader>vz",
      function()
        Snacks.zen()
      end,
      desc = "Toggle Zen Mode",
    },
    {
      "<leader>vZ",
      function()
        Snacks.zen.zoom()
      end,
      desc = "Toggle Zoom",
    },
    -- Scratch operations (using consistent prefix)
    {
      "<leader>.",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>S",
      function()
        Snacks.scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },

    -- Global shortcuts for common operations
    {
      "<leader>/",
      function()
        Snacks.picker.grep()
      end,
      desc = "Grep",
    },
    {
      "<leader>:",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Command History",
    },
    {
      "<C-s>",
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = "Grep Open Buffers",
    },
    {
      "gy",
      function()
        Snacks.picker.lsp_type_definitions()
      end,
      desc = "Goto T[y]pe Definition",
    },

    -- Words navigation (using bracket keys for consistency)
    {
      "]]",
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = "Next Reference",
      mode = { "n", "t" },
    },
    {
      "[[",
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = "Prev Reference",
      mode = { "n", "t" },
    },

    -- Info/Implementations group (<leader>i) - Neovim news
    {
      "<leader>iN",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    },
  },
}
