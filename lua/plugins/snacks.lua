-- Snacks.nvim - A collection of useful Neovim utilities
-- Integrated with existing which-key groups and nvim architecture
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = { enabled = true },
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
    {
      "<D-p>",
      function()
        Snacks.picker.files()
      end,
      desc = "Find Files",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.git_files()
      end,
      desc = "Find Git Files",
    },
    {
      "<D-P>",
      function()
        Snacks.picker.recent()
      end,
      desc = "Recent Files",
    },
    {
      "<leader>fc",
      function()
        Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "Find Config File",
    },
    {
      "<leader>fp",
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
            list = { keys = { ["dd"] = "bufdelete" } },
          },
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

    -- Bookmarks group (<leader>m) - Marks and bookmarks functionality
    {
      "<leader>mm",
      function()
        -- Smart mark toggle - uses next available local mark or toggles existing mark
        local function toggle_smart_mark()
          local marks = vim.fn.getmarklist('%')
          local used_marks = {}
          local current_line = vim.fn.line('.')
          local existing_mark_on_line = nil

          -- Get currently used local marks in this buffer and check for mark on current line
          for _, mark in ipairs(marks) do
            if mark.mark:match("^'[a-z]$") then
              local mark_char = mark.mark:sub(2)
              used_marks[mark_char] = true

              -- Check if there's already a mark on the current line
              if mark.pos and mark.pos[2] == current_line then
                existing_mark_on_line = mark_char
              end
            end
          end

          -- If there's already a mark on the current line, remove it (toggle off)
          if existing_mark_on_line then
            vim.cmd('delmarks ' .. existing_mark_on_line)
            vim.notify("🗑️ Removed mark '" .. existing_mark_on_line .. "' from line " .. current_line,
              vim.log.levels.INFO)
            return
          end

          -- Find first available mark a-z
          for i = string.byte('a'), string.byte('z') do
            local char = string.char(i)
            if not used_marks[char] then
              vim.cmd('normal! m' .. char)
              vim.notify("📌 Set mark '" .. char .. "' at line " .. current_line, vim.log.levels.INFO)
              return
            end
          end

          -- If all marks are used, reuse 'a'
          vim.cmd('normal! ma')
          vim.notify("📌 Set mark 'a' at line " .. current_line .. " (reused)", vim.log.levels.INFO)
        end
        toggle_smart_mark()
      end,
      desc = "Smart Mark Toggle",
    },
    {
      "<leader>fm",
      function()
        Snacks.picker.marks({
          global = false,
          ["local"] = true,
        })
      end,
      desc = "List All Local Marks",
    },
    {
      "<leader>fM",
      function()
        Snacks.picker.marks({
          global = true,
          ["local"] = false,
        })
      end,
      desc = "List All Global Marks",
    },
    {
      "<leader>mj",
      function()
        -- Next mark navigation
        local marks = vim.fn.getmarklist('%')
        local current_line = vim.fn.line('.')
        local next_mark = nil
        local next_line = math.huge

        for _, mark in ipairs(marks) do
          if mark.mark:match("^'[a-zA-Z]$") and mark.pos[2] > current_line and mark.pos[2] < next_line then
            next_mark = mark
            next_line = mark.pos[2]
          end
        end

        if next_mark then
          vim.cmd('normal! ' .. next_mark.mark)
          vim.notify("📍 Jumped to mark " .. next_mark.mark:sub(2), vim.log.levels.INFO)
        else
          vim.notify("📍 No marks found after current line", vim.log.levels.WARN)
        end
      end,
      desc = "Next Mark",
    },
    {
      "<leader>mk",
      function()
        -- Previous mark navigation
        local marks = vim.fn.getmarklist('%')
        local current_line = vim.fn.line('.')
        local prev_mark = nil
        local prev_line = 0

        for _, mark in ipairs(marks) do
          if mark.mark:match("^'[a-zA-Z]$") and mark.pos[2] < current_line and mark.pos[2] > prev_line then
            prev_mark = mark
            prev_line = mark.pos[2]
          end
        end

        if prev_mark then
          vim.cmd('normal! ' .. prev_mark.mark)
          vim.notify("📍 Jumped to mark " .. prev_mark.mark:sub(2), vim.log.levels.INFO)
        else
          vim.notify("📍 No marks found before current line", vim.log.levels.WARN)
        end
      end,
      desc = "Previous Mark",
    },
    {
      "<leader>mc",
      function()
        -- Clear all marks in current buffer
        vim.cmd('delmarks!')
        vim.notify("🗑️ Cleared all marks in current buffer", vim.log.levels.INFO)
      end,
      desc = "Clear Buffer Marks",
    },
    {
      "<leader>mC",
      function()
        -- Clear all global marks
        vim.cmd('delmarks A-Z')
        vim.notify("🗑️ Cleared all global marks", vim.log.levels.INFO)
      end,
      desc = "Clear Global Marks",
    },
    {
      "<leader>ma",
      function()
        -- Set global mark with input
        vim.ui.input({ prompt = "Global mark letter (A-Z): " }, function(input)
          if input and input:match("^[A-Z]$") then
            vim.cmd('normal! m' .. input)
            vim.notify("🌟 Set global mark '" .. input .. "' at " .. vim.fn.expand('%:t') .. ":" .. vim.fn.line('.'),
              vim.log.levels.INFO)
          elseif input then
            vim.notify("❌ Invalid mark. Use A-Z for global marks", vim.log.levels.ERROR)
          end
        end)
      end,
      desc = "Set Global Mark",
    },
    {
      "<leader>st",
      function()
        Snacks.picker.grep()
      end,
      desc = "Grep Text",
    },
    {
      "<leader>sw",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Visual selection or word",
      mode = { "n", "x" },
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
        Snacks.picker.command_history()
      end,
      desc = "Command History",
    },
    {
      "<leader>sC",
      function()
        Snacks.picker.commands()
      end,
      desc = "Commands",
    },
    {
      "<leader>sd",
      function()
        Snacks.picker.diagnostics()
      end,
      desc = "Diagnostics",
    },
    {
      "<leader>sD",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = "Buffer Diagnostics",
    },
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
      "<leader>ii",
      function()
        Snacks.picker.icons()
      end,
      desc = "Insert Icons",
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
    {
      "<leader>gb",
      function()
        Snacks.picker.git_branches()
      end,
      desc = "Git Branches",
    },
    {
      "<leader>gl",
      function()
        Snacks.picker.git_log()
      end,
      desc = "Git Log",
    },
    {
      "<leader>gL",
      function()
        Snacks.picker.git_log_line()
      end,
      desc = "Git Log Line",
    },
    {
      "<leader>gs",
      function()
        Snacks.picker.git_status()
      end,
      desc = "Git Status",
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
      "<leader>gf",
      function()
        Snacks.picker.git_log_file()
      end,
      desc = "Git Log File",
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
    {
      "<c-_>",
      function()
        Snacks.terminal()
      end,
      desc = "which_key_ignore",
    },

    -- Error Lens/Explorer group (<leader>e) - Explorer
    {
      "<leader>ee",
      function()
        Snacks.explorer()
      end,
      desc = "File Explorer",
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

    -- LSP navigation (global mappings following goto conventions)
    {
      "gd",
      function()
        Snacks.picker.lsp_definitions()
      end,
      desc = "Goto Definition",
    },
    {
      "gD",
      function()
        Snacks.picker.lsp_declarations()
      end,
      desc = "Goto Declaration",
    },
    {
      "gr",
      function()
        Snacks.picker.lsp_references()
      end,
      nowait = true,
      desc = "References",
    },
    {
      "gI",
      function()
        Snacks.picker.lsp_implementations()
      end,
      desc = "Goto Implementation",
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

  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create toggle mappings using Test/Utils group (<leader>u)
        -- Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        -- Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        -- Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        -- Snacks.toggle.diagnostics():map("<leader>ud")
        -- Snacks.toggle.line_number():map("<leader>ul")
        -- Snacks.toggle
        --     .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
        --     :map("<leader>uc")
        -- Snacks.toggle.treesitter():map("<leader>uT")
        -- Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        -- Snacks.toggle.inlay_hints():map("<leader>uh")
        -- Snacks.toggle.indent():map("<leader>ug")
        -- Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,

  config = function(_, opts)
    require("snacks").setup(opts)

    -- Set up custom colors for marks to match your theme
    vim.api.nvim_set_hl(0, "SnacksMarks", { fg = "#4A90E2", bold = true })           -- Blue for marks
    vim.api.nvim_set_hl(0, "SnacksMarksAnnotation", { fg = "#50C878", bold = true }) -- Green for annotated marks

    -- Custom mark commands that work with snacks
    vim.api.nvim_create_user_command("MarksList", function()
      require("snacks").picker.marks()
    end, { desc = "List all marks using snacks picker" })

    vim.api.nvim_create_user_command("MarksProject", function()
      -- Call the project marks function directly
      local snacks = require("snacks")
      local function get_project_root()
        local cwd = vim.fn.getcwd()
        local git_root = vim.fn.systemlist("git -C " ..
          vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")[1]
        return (vim.v.shell_error == 0 and git_root) or cwd
      end

      local project_root = get_project_root()
      snacks.picker.marks({
        prompt_title = "📍 Project Marks - " .. vim.fn.fnamemodify(project_root, ":t"),
      })
    end, { desc = "List project marks only" })

    vim.api.nvim_create_user_command("MarksGlobal", function()
      require("snacks").picker.marks()
    end, { desc = "List all global marks" })
  end,
}