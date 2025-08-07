return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-ui-select.nvim" },
      "nvim-tree/nvim-web-devicons",
      "folke/todo-comments.nvim",
      {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = { "kkharji/sqlite.lua" },
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local transform_mod = require("telescope.actions.mt").transform_mod

      local trouble = require("trouble")
      local trouble_telescope = require("trouble.sources.telescope")

      -- or create your custom action
      local custom_actions = transform_mod({
        open_trouble_qflist = function(prompt_bufnr)
          trouble.toggle("quickfix")
        end,
      })

      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.98,
            height = 0.8,
            -- preview_width = 0.5,
            prompt_position = "top"
          },
          sorting_strategy = "ascending",
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          prompt_prefix = " > ",
          selection_caret = " > ",
          path_display = { "smart" },
          dynamic_preview_title = true,
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous, -- move to prev result
              ["<C-j>"] = actions.move_selection_next,     -- move to next result
              ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
              ["<C-t>"] = trouble_telescope.open,
              ["<Esc>"] = actions.close, -- Single Esc to close telescope
            },
            n = {
              ["<Esc>"] = actions.close, -- Single Esc to close telescope in normal mode
              ["q"] = actions.close,     -- q to close telescope in normal mode
            },
          },
        },
        extensions = {
          frecency = {
            show_scores = true,
            show_unindexed = true,
            ignore_patterns = { "*.git/*", "*/tmp/*", "*/.DS_Store" },
            disable_devicons = false,
            auto_validate = false, -- Disable auto-validation to prevent cross-project contamination
            workspaces = {
              ["conf"] = vim.fn.expand("~/.config"),
              ["data"] = vim.fn.expand("~/.local/share"),
              ["project"] = vim.fn.expand("~/Projects"),
              ["nvim"] = vim.fn.expand("~/.config/nvim"),
            },
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({
              layout_config = {
                width = 0.8,
                height = 0.6,
              },
              borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
            }),
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("frecency")
      telescope.load_extension("ui-select")

      -- Load csharpls-extended telescope extension if available
      local has_csharpls_extended = pcall(require, "csharpls_extended")
      if has_csharpls_extended then
        telescope.load_extension("csharpls_definition")
      end

      -- Clear telescope cache when changing directories to prevent cross-project results
      vim.api.nvim_create_autocmd("DirChanged", {
        group = vim.api.nvim_create_augroup("TelescopeCacheClear", { clear = true }),
        callback = function()
          -- Clear telescope picker history and cache
          pcall(function()
            local state = require("telescope.state")
            -- Clear all picker history
            state.global_cache = {}
          end)
        end,
      })

      -- Additional autocmd to clear cache when entering a different git repository
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("TelescopeProjectCacheClear", { clear = true }),
        callback = function()
          local current_file = vim.fn.expand("%:p")
          if current_file ~= "" then
            local current_dir = vim.fn.fnamemodify(current_file, ":h")
            local git_root = vim.fn.systemlist("git -C " ..
              vim.fn.shellescape(current_dir) .. " rev-parse --show-toplevel 2>/dev/null")[1]

            if vim.v.shell_error == 0 and git_root then
              -- Store the last known git root in a global variable
              if _G.last_telescope_git_root ~= git_root then
                _G.last_telescope_git_root = git_root
                -- Clear cache when entering a different git repository
                pcall(function()
                  local state = require("telescope.state")
                  state.global_cache = {}
                end)
              end
            end
          end
        end,
      })

      -- Custom telescope functions with dynamic preview titles
      local function lsp_references_with_dynamic_title()
        local previewers = require("telescope.previewers")
        local builtin = require("telescope.builtin")

        builtin.lsp_references({
          initial_mode = "normal",
          path_display = { "smart" },
          entry_maker = function(entry)
            local make_entry = require("telescope.make_entry")
            local default_entry = make_entry.gen_from_quickfix({})(entry)

            -- Override the display to only show the smart path
            if default_entry then
              default_entry.display = function(ent)
                local path_display = require("telescope.utils").path_smart(ent.filename)
                return path_display .. ":" .. ent.lnum .. ":" .. ent.col
              end
            end

            return default_entry
          end,
          attach_mappings = function(prompt_bufnr, map_func)
            local actions = require("telescope.actions")
            map_func("i", "<Esc>", actions.close)
            map_func("n", "<Esc>", actions.close)
            map_func("n", "q", actions.close)
            return true
          end,
          previewer = previewers.new_buffer_previewer({
            title = "LSP References",
            dyn_title = function(_, entry)
              return vim.fn.fnamemodify(entry.filename, ":t")
            end,
            get_buffer_by_name = function(_, entry)
              return entry.filename
            end,
            define_preview = function(self, entry, status)
              previewers.buffer_previewer_maker(entry.filename, self.state.bufnr, {
                bufname = self.state.bufname,
                winid = self.state.winid,
                preview = {
                  mime_type = vim.filetype.match({ filename = entry.filename }),
                },
              })

              -- Jump to the line and highlight the referenced symbol
              if entry.lnum then
                pcall(vim.api.nvim_buf_call, self.state.bufnr, function()
                  pcall(vim.api.nvim_win_set_cursor, self.state.winid, { entry.lnum, (entry.col or 1) - 1 })

                  -- Clear any existing highlights (wrapped in pcall for safety)
                  pcall(vim.api.nvim_buf_clear_namespace, self.state.bufnr, -1, 0, -1)

                  -- Function to apply highlighting
                  local function apply_highlighting()
                    -- Get the symbol name under cursor for LSP references
                    local symbol_name = ""

                    -- Try to get the current word/symbol at the reference location
                    if entry.text then
                      -- Extract the word around the column position
                      local line_text = vim.api.nvim_buf_get_lines(self.state.bufnr, entry.lnum - 1, entry.lnum, false)
                          [1] or ""
                      if line_text and entry.col then
                        -- Find word boundaries around the column
                        local col = entry.col - 1 -- Convert to 0-based
                        local start_col = col
                        local end_col = col

                        -- Find start of word
                        while start_col > 0 and line_text:sub(start_col, start_col):match("[%w_]") do
                          start_col = start_col - 1
                        end
                        if not line_text:sub(start_col + 1, start_col + 1):match("[%w_]") then
                          start_col = start_col + 1
                        end

                        -- Find end of word
                        while end_col < #line_text and line_text:sub(end_col + 1, end_col + 1):match("[%w_]") do
                          end_col = end_col + 1
                        end

                        symbol_name = line_text:sub(start_col + 1, end_col)
                      end
                    end

                    -- Fallback: try to get symbol from LSP if we have access to it
                    if symbol_name == "" then
                      -- Get the current word under cursor in the original buffer
                      local current_word = vim.fn.expand("<cword>")
                      if current_word and current_word ~= "" then
                        symbol_name = current_word
                      end
                    end

                    -- Highlight the symbol in the preview
                    if symbol_name and symbol_name ~= "" and entry.lnum then
                      local line_text = vim.api.nvim_buf_get_lines(self.state.bufnr, entry.lnum - 1, entry.lnum, false)
                          [1] or ""
                      local escaped_symbol = vim.pesc(symbol_name)

                      -- Find all occurrences of the symbol in the line
                      local start_pos = 1
                      while true do
                        local start_col, end_col = string.find(line_text, escaped_symbol, start_pos)
                        if not start_col then break end

                        pcall(vim.api.nvim_buf_add_highlight,
                          self.state.bufnr,
                          -1,
                          "TelescopeMatching",
                          entry.lnum - 1,
                          start_col - 1,
                          end_col
                        )

                        start_pos = end_col + 1
                      end
                    end
                  end

                  -- Apply highlighting immediately
                  pcall(apply_highlighting)

                  -- Schedule highlighting to run after telescope is fully loaded, with proper error handling
                  pcall(vim.schedule, function()
                    if vim.api.nvim_buf_is_valid(self.state.bufnr) and vim.api.nvim_win_is_valid(self.state.winid) then
                      pcall(apply_highlighting)
                    end
                  end)
                end)
              end
            end
          })
        })
      end

      local function live_grep_with_dynamic_title(opts)
        local previewers = require("telescope.previewers")
        local builtin = require("telescope.builtin")

        opts = opts or {}

        -- Get current project root
        local cwd = vim.fn.getcwd()
        local git_root = vim.fn.systemlist("git -C " ..
          vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")[1]
        local project_root = (vim.v.shell_error == 0 and git_root) or cwd

        -- Clear telescope cache to prevent cross-project results
        pcall(function()
          require("telescope.builtin").resume = function() end -- Disable resume functionality temporarily
        end)

        local config = vim.tbl_extend("force", opts, {
          prompt_title = "🔍 Live Grep - " .. vim.fn.fnamemodify(project_root, ":t"),
          cwd = project_root,
          search_dirs = { project_root }, -- Explicitly limit search to project root
          path_display = { "smart" },
          entry_maker = function(entry)
            local make_entry = require("telescope.make_entry")
            local default_entry = make_entry.gen_from_vimgrep({})(entry)

            -- Override the display to only show the smart path
            if default_entry then
              default_entry.display = function(ent)
                local path_display = require("telescope.utils").path_smart(ent.filename)
                return path_display .. ":" .. ent.lnum .. ":" .. ent.col
              end
            end

            return default_entry
          end,
          previewer = previewers.new_buffer_previewer({
            title = "Live Grep",
            dyn_title = function(_, entry)
              return vim.fn.fnamemodify(entry.filename, ":t")
            end,
            get_buffer_by_name = function(_, entry)
              return entry.filename
            end,
            define_preview = function(self, entry, status)
              previewers.buffer_previewer_maker(entry.filename, self.state.bufnr, {
                bufname = self.state.bufname,
                winid = self.state.winid,
                preview = {
                  mime_type = vim.filetype.match({ filename = entry.filename }),
                },
              })

              -- Jump to the line and highlight the search term
              if entry.lnum then
                pcall(vim.api.nvim_buf_call, self.state.bufnr, function()
                  pcall(vim.api.nvim_win_set_cursor, self.state.winid, { entry.lnum, (entry.col or 1) - 1 })

                  -- Clear any existing highlights (wrapped in pcall for safety)
                  pcall(vim.api.nvim_buf_clear_namespace, self.state.bufnr, -1, 0, -1)

                  -- Function to apply highlighting
                  local function apply_highlighting()
                    -- Try to get the current search query from multiple sources
                    local search_query = opts.default_text or ""

                    if search_query == "" then
                      -- Try to get from telescope picker state
                      local picker = require("telescope.actions.state").get_current_picker()
                      if picker then
                        -- Try multiple methods to get the prompt
                        if picker._get_prompt then
                          search_query = picker:_get_prompt() or ""
                        elseif picker.prompt_bufnr then
                          local prompt_lines = vim.api.nvim_buf_get_lines(picker.prompt_bufnr, 0, 1, false)
                          if prompt_lines[1] then
                            -- Remove the prompt prefix to get just the search query
                            search_query = prompt_lines[1]:gsub("^.*> ", "")
                          end
                        end
                      end
                    end

                    -- Extract search query from the grep result text if still empty
                    if search_query == "" and entry.text then
                      -- For live_grep, the search term is what was found in the file
                      -- We can extract it from the entry, but it's better to use the actual search term
                      -- This is a fallback - try to get it from the entry's text
                      local line_text = vim.api.nvim_buf_get_lines(self.state.bufnr, entry.lnum - 1, entry.lnum, false)
                          [1] or ""
                      -- This is imperfect but better than no highlighting
                      local words = vim.split(entry.text, "%s+")
                      for _, word in ipairs(words) do
                        if #word > 2 and string.find(line_text:lower(), word:lower()) then
                          search_query = word
                          break
                        end
                      end
                    end

                    -- Highlight the search term in the preview
                    if search_query and search_query ~= "" then
                      local line_text = vim.api.nvim_buf_get_lines(self.state.bufnr, entry.lnum - 1, entry.lnum, false)
                          [1] or ""
                      local escaped_query = vim.pesc(search_query)
                      local start_col = string.find(line_text:lower(), escaped_query:lower())
                      if start_col then
                        pcall(vim.api.nvim_buf_add_highlight,
                          self.state.bufnr,
                          -1,
                          "TelescopeMatching",
                          entry.lnum - 1,
                          start_col - 1,
                          start_col - 1 + string.len(search_query)
                        )
                      end
                    end
                  end

                  -- Apply highlighting immediately
                  pcall(apply_highlighting)

                  -- Schedule highlighting to run after telescope is fully loaded, with proper error handling
                  pcall(vim.schedule, function()
                    if vim.api.nvim_buf_is_valid(self.state.bufnr) and vim.api.nvim_win_is_valid(self.state.winid) then
                      pcall(apply_highlighting)
                    end
                  end)
                end)
              end
            end
          })
        })

        builtin.live_grep(config)
      end

      local function oldfiles_with_dynamic_title(opts)
        local previewers = require("telescope.previewers")
        local builtin = require("telescope.builtin")

        opts = opts or {}

        local config = vim.tbl_extend("force", opts, {
          previewer = previewers.new_buffer_previewer({
            title = "Recent Files",
            dyn_title = function(_, entry)
              return vim.fn.fnamemodify(entry.value, ":t")
            end,
            get_buffer_by_name = function(_, entry)
              return entry.value
            end,
            define_preview = function(self, entry, status)
              previewers.buffer_previewer_maker(entry.value, self.state.bufnr, {
                bufname = self.state.bufname,
                winid = self.state.winid,
                preview = {
                  mime_type = vim.filetype.match({ filename = entry.value }),
                },
              })
            end
          })
        })

        builtin.oldfiles(config)
      end

      -- Make custom functions globally accessible
      -- _G.telescope_lsp_references_with_dynamic_title = lsp_references_with_dynamic_title
      -- _G.telescope_live_grep_with_dynamic_title = live_grep_with_dynamic_title
      -- _G.telescope_oldfiles_with_dynamic_title = oldfiles_with_dynamic_title

      -- Live grep with literal search (no regex escaping needed)
      local function live_grep_literal(opts)
        local builtin = require("telescope.builtin")
        opts = opts or {}

        -- Get current project root
        local cwd = vim.fn.getcwd()
        local git_root = vim.fn.systemlist("git -C " ..
          vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")[1]
        local project_root = (vim.v.shell_error == 0 and git_root) or cwd

        -- Clear telescope cache to prevent cross-project results
        pcall(function()
          require("telescope.builtin").resume = function() end -- Disable resume functionality temporarily
        end)

        -- Use fixed-strings flag for literal search and scope to project
        local config = vim.tbl_extend("force", opts, {
          additional_args = { "--fixed-strings" },
          path_display = { "smart" },
          prompt_title = "🔍 Live Grep (Literal Search) - " .. vim.fn.fnamemodify(project_root, ":t"),
          cwd = project_root,
          search_dirs = { project_root }, -- Explicitly limit search to project root
          attach_mappings = function(prompt_bufnr, map_func)
            local actions = require("telescope.actions")
            map_func("i", "<Esc>", actions.close)
            map_func("n", "<Esc>", actions.close)
            map_func("n", "q", actions.close)
            -- Preserve any existing attach_mappings
            if opts.attach_mappings then
              return opts.attach_mappings(prompt_bufnr, map_func)
            end
            return true
          end,
        })

        builtin.live_grep(config)
      end
      -- Separate normal and visual mode mappings for D-S-f
      local multi_ripgrep = require("helpers.multi-ripgrep")
      vim.keymap.set("n", "<D-S-f>", multi_ripgrep,
        { desc = "search word under cursor in current file", silent = true })

      vim.keymap.set("v", "<D-S-f>", function()
        -- Yank the selected text to the unnamed register
        vim.cmd("normal! y")
        -- Get the yanked text
        local selected_text = vim.fn.getreg('"')
        -- No need to escape special characters since we're using literal search
        pcall(multi_ripgrep, { default_text = selected_text, initial_mode = "normal" })
      end, { desc = "telescope find selected text in all files (literal search)", silent = true })

      -- Enhanced search function that searches for word under cursor
      local function search_word_under_cursor()
        local word = vim.fn.expand("<cword>")
        if word == "" then
          -- If no word under cursor, fall back to regular search
          vim.api.nvim_feedkeys("/", "n", false)
        else
          -- Search for the word using vim's search functionality
          -- Use \< and \> for whole word matching (vim best practice)
          local search_pattern = "\\<" .. vim.fn.escape(word, "\\") .. "\\>"
          vim.fn.setreg("/", search_pattern)
          vim.cmd("normal! n")
          -- Enable search highlighting
          vim.opt.hlsearch = true
        end
      end

      vim.keymap.set("n", "<D-f>", search_word_under_cursor,
        { desc = "search word under cursor in current file", silent = true })


      -- Create a command to manually clear telescope cache
      vim.api.nvim_create_user_command("TelescopeClearCache", function()
        pcall(function()
          local state = require("telescope.state")
          state.global_cache = {}
          -- Also clear frecency cache if available
          if require("telescope").extensions and require("telescope").extensions.frecency then
            pcall(function()
              local frecency = require("telescope").extensions.frecency
              if frecency.clear_cache then
                frecency.clear_cache()
              end
            end)
          end
          vim.notify("Telescope cache cleared", vim.log.levels.INFO)
        end)
      end, { desc = "Clear telescope cache to fix cross-project results" })

      -- Custom function to show all files with priority for recently opened ones
      local function find_files_with_priority()
        -- Get current project root
        local cwd = vim.fn.getcwd()
        local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel")[1]
        local project_root = (vim.v.shell_error == 0 and git_root) or cwd

        require("telescope").extensions.frecency.frecency({
          workspace = "CWD",
          cwd = project_root, -- Ensure frecency is scoped to current project
          path_display = { "smart" },
          previewer = true,
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.98,
            height = 0.8,
            -- preview_width = 0.5,
            prompt_position = "top"
          },
          sorting_strategy = "ascending",
          prompt_prefix = " > ",
          selection_caret = " > ",
          attach_mappings = function(prompt_bufnr, map_func)
            local actions = require("telescope.actions")
            map_func("i", "<Esc>", actions.close)
            map_func("n", "<Esc>", actions.close)
            map_func("n", "q", actions.close)
            return true
          end,
        })
      end

      -- set keymaps
      local keymap = vim.keymap -- for conciseness
      local builtin = require("telescope.builtin")

      -- Helper function to create telescope mappings with proper Esc handling
      local function telescope_with_esc(builtin_func, opts)
        opts = opts or {}
        return function()
          local telescope_opts = vim.tbl_extend("force", opts, {
            attach_mappings = function(prompt_bufnr, map_func)
              local actions = require("telescope.actions")
              map_func("i", "<Esc>", actions.close)
              map_func("n", "<Esc>", actions.close)
              map_func("n", "q", actions.close)
              -- Preserve any existing attach_mappings
              if opts.attach_mappings then
                return opts.attach_mappings(prompt_bufnr, map_func)
              end
              return true
            end,
          })
          builtin_func(telescope_opts)
        end
      end

      keymap.set("n", "<leader>fs", live_grep_literal, { desc = "Find string in cwd (literal search)" })
      keymap.set(
        "n",
        "<leader>fS",
        telescope_with_esc(builtin.live_grep),
        { desc = "Find string in cwd (regex search)" }
      )
      keymap.set("n", "<leader>ft", function()
        -- Use telescope for todo search with proper Esc handling
        local telescope_opts = {
          attach_mappings = function(prompt_bufnr, map_func)
            local actions = require("telescope.actions")
            map_func("i", "<Esc>", actions.close)
            map_func("n", "<Esc>", actions.close)
            map_func("n", "q", actions.close)
            return true
          end,
        }
        -- Try todo-comments telescope extension first, fallback to live_grep
        local ok, todo_comments = pcall(require, "todo-comments")
        if ok and todo_comments.search then
          todo_comments.search(telescope_opts)
        else
          builtin.live_grep(vim.tbl_extend("force", telescope_opts, {
            default_text = "TODO\\|FIXME\\|NOTE\\|HACK\\|WARN",
            additional_args = { "--regex" }
          }))
        end
      end, { desc = "Find todos" })

      -- Additional Telescope mappings (converted from FZF)
      keymap.set("n", "<leader>fh", telescope_with_esc(builtin.help_tags), { desc = "Find help tags" })
      keymap.set("n", "<leader>fj", telescope_with_esc(builtin.jumplist, { initial_mode = "normal" }),
        { desc = "Find jumps" })
      keymap.set("n", "<leader>fm", function() require("snacks").picker.marks() end, { desc = "Find marks (snacks)" })
      keymap.set("n", "<leader>fc", telescope_with_esc(builtin.command_history), { desc = "Find command history" })

      -- Enable line numbers in telescope preview windows
      vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        callback = function()
          vim.opt_local.number = true
        end,
      })
    end,
  },
}