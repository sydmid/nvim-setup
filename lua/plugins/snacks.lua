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
      "<leader>ff",
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
      "<leader>fr",
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
      "<leader><space>",
      function()
        Snacks.picker.smart()
      end,
      desc = "Smart Find Files",
    },

    -- Buffer group (<leader>b) - Buffer management
    {
      "<leader>bo",
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
        -- Smart mark toggle - uses next available local mark
        local function toggle_smart_mark()
          local marks = vim.fn.getmarklist('%')
          local used_marks = {}

          -- Get currently used local marks in this buffer
          for _, mark in ipairs(marks) do
            if mark.mark:match("^'[a-z]$") then
              used_marks[mark.mark:sub(2)] = true
            end
          end

          -- Find first available mark a-z
          for i = string.byte('a'), string.byte('z') do
            local char = string.char(i)
            if not used_marks[char] then
              vim.cmd('normal! m' .. char)
              vim.notify("📌 Set mark '" .. char .. "' at line " .. vim.fn.line('.'), vim.log.levels.INFO)
              return
            end
          end

          -- If all marks are used, reuse 'a'
          vim.cmd('normal! ma')
          vim.notify("📌 Set mark 'a' at line " .. vim.fn.line('.') .. " (reused)", vim.log.levels.INFO)
        end
        toggle_smart_mark()
      end,
      desc = "Smart Mark Toggle",
    },
    {
      "<leader>ml",
      function()
        -- Get current project root
        local function get_project_root()
          local cwd = vim.fn.getcwd()
          local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")[1]
          return (vim.v.shell_error == 0 and git_root) or cwd
        end

        local project_root = get_project_root()

        -- Get all marks and filter to current project
        local all_global_marks = vim.fn.getmarklist()
        local buffer_marks = vim.fn.getmarklist('%')

        -- Filter marks to current project
        local project_marks = {}

        -- Add global marks that point to files in current project
        for _, mark in ipairs(all_global_marks) do
          if mark.file and mark.file ~= "" then
            local full_path = vim.fn.fnamemodify(mark.file, ':p')
            if vim.startswith(full_path, project_root) then
              table.insert(project_marks, mark)
            end
          end
        end

        -- Add current buffer marks (they're always in current project)
        for _, mark in ipairs(buffer_marks) do
          table.insert(project_marks, mark)
        end

        if #project_marks == 0 then
          vim.notify("📍 No marks found in current project: " .. vim.fn.fnamemodify(project_root, ":t"), vim.log.levels.INFO)
          return
        end

        -- Create a custom telescope picker for project marks
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        local mark_entries = {}
        for _, mark in ipairs(project_marks) do
          local file_path = mark.file or vim.api.nvim_buf_get_name(0)
          local line = mark.pos and mark.pos[2] or mark.lnum or 1
          local col = mark.pos and mark.pos[3] or mark.col or 1
          local mark_name = mark.mark and mark.mark:gsub("^'", "") or "?"

          local display_path = file_path ~= "" and vim.fn.fnamemodify(file_path, ':~:.') or "[Current Buffer]"
          local display = string.format("%s  %s:%d", mark_name, display_path, line)

          table.insert(mark_entries, {
            mark = mark_name,
            filename = file_path,
            lnum = line,
            col = col,
            display = display,
          })
        end

        pickers.new({}, {
          prompt_title = "📍 Project Marks - " .. vim.fn.fnamemodify(project_root, ":t"),
          finder = finders.new_table({
            results = mark_entries,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry.display,
                ordinal = entry.display,
                filename = entry.filename,
                lnum = entry.lnum,
                col = entry.col,
              }
            end,
          }),
          sorter = conf.generic_sorter({}),
          previewer = conf.file_previewer({}),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              if selection and selection.filename then
                if selection.filename ~= "" then
                  vim.cmd("edit " .. vim.fn.fnameescape(selection.filename))
                end
                vim.api.nvim_win_set_cursor(0, {selection.lnum, selection.col - 1})
              end
            end)
            return true
          end,
        }):find()
      end,
      desc = "List Project Marks",
    },
    {
      "<leader>mb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "List Buffers",
    },
    {
      "<leader>mL",
      function()
        Snacks.picker.marks()
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
            vim.notify("🌟 Set global mark '" .. input .. "' at " .. vim.fn.expand('%:t') .. ":" .. vim.fn.line('.'), vim.log.levels.INFO)
          elseif input then
            vim.notify("❌ Invalid mark. Use A-Z for global marks", vim.log.levels.ERROR)
          end
        end)
      end,
      desc = "Set Global Mark",
    },
    {
      "<D-S-]>",
      "<leader>mj",
      desc = "Next Mark (macOS)",
      remap = true,
    },
    {
      "<D-S-[>",
      "<leader>mk",
      desc = "Previous Mark (macOS)",
      remap = true,
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
      "<leader>si",
      function()
        Snacks.picker.icons()
      end,
      desc = "Icons",
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

    -- Terminal/Tabs/Themes group (<leader>t) - Terminal
    {
      "<c-/>",
      function()
        Snacks.terminal()
      end,
      desc = "Toggle Terminal",
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
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,

  config = function(_, opts)
    require("snacks").setup(opts)

    -- Integration with existing Which-Key groups - Add specific snacks descriptions
    local wk_ok, wk = pcall(require, "which-key")
    if wk_ok then
      wk.add({
        -- Add snacks-specific descriptions to existing groups
        { "<leader>f", group = "󰈞 File/Find" },
        { "<leader>b", group = "󰓩 Buffer" },
        { "<leader>s", group = "󰯌 Session/Split/Search" },
        { "<leader>g", group = "󰊢 Git/Goto" },
        { "<leader>l", group = "󰿘 LSP" },
        { "<leader>w", group = "󰓩 Workspace/Tabs" },
        { "<leader>u", group = "󰙨 Test/Utils/Toggles" },
        { "<leader>m", group = "󰃀 Marks" },
        { "<leader>c", group = "󰒓 Context/Code-Actions" },
        { "<leader>v", group = "󰒉 Visual/View" },
        { "<leader>t", group = "󰆍 Terminal/Tabs/Themes" },
        { "<leader>e", group = "🔍 Error Lens/Explorer" },
        { "<leader>i", group = "󰋼 Info/Implementations" },
      })
    end

    -- Set up custom colors for marks to match your theme
    vim.api.nvim_set_hl(0, "SnacksMarks", { fg = "#4A90E2", bold = true }) -- Blue for marks
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
        local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")[1]
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

    vim.api.nvim_create_user_command("MarksHelp", function()
      local marks_help = {
        "Snacks Marks Usage:",
        "",
        "Global Marks (A-Z): Set with `mA`, jump with `'A`",
        "Local Marks (a-z): Set with `ma`, jump with `'a`",
        "Special Marks:",
        "  `. - Last change position",
        "  `' - Last jump position",
        "  `\" - Last exit position",
        "  `[ and `] - Start/end of last change",
        "",
        "Keybindings:",
        "  <leader>sm - Open marks picker (all marks)",
        "  <leader>mm - Quick mark toggle (auto-assigns a-z marks)",
        "  <leader>ml - List marks (current project only)",
        "  <leader>mb - List buffers (snacks buffers)",
        "  <leader>mL - List marks (all global marks)",
        "  <leader>mj - Next mark in buffer",
        "  <leader>mk - Previous mark in buffer",
        "  <leader>ma - Set global mark (A-Z)",
        "  <leader>mc - Clear marks in current buffer",
        "  <leader>mC - Clear all global marks",
        "",
        "Commands:",
        "  :MarksList - List all marks",
        "  :MarksProject - List project marks only",
        "  :MarksGlobal - List all global marks",
        "  :MarksHelp - Show this help",
        "",
        "Use snacks picker for full marks navigation!"
      }

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, marks_help)
      vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
      vim.api.nvim_buf_set_option(buf, 'modifiable', false)

      local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = 70,
        height = #marks_help + 2,
        row = (vim.o.lines - #marks_help) / 2,
        col = (vim.o.columns - 70) / 2,
        style = 'minimal',
        border = 'rounded',
        title = ' 📍 Marks Help ',
        title_pos = 'center'
      })

      vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<cr>', { silent = true })
      vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<cr>', { silent = true })
    end, { desc = "Show marks help" })

    -- Enhanced notifications for snacks operations (following your existing pattern)
    vim.api.nvim_create_autocmd("User", {
      pattern = "SnacksNotificationShown",
      callback = function(data)
        -- Optional: Log snacks notifications for debugging
        if vim.g.snacks_debug then
          vim.notify("📦 Snacks notification: " .. vim.inspect(data.data), vim.log.levels.DEBUG)
        end
      end,
    })
  end,
}
