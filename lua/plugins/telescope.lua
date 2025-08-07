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

      -- Load todo-comments telescope extension if available
      local has_todo_comments = pcall(require, "todo-comments")
      if has_todo_comments then
        pcall(telescope.load_extension, "todo-comments")
      end

      -- Load csharpls-extended telescope extension if available
      local has_csharpls_extended = pcall(require, "csharpls_extended")
      if has_csharpls_extended then
        telescope.load_extension("csharpls_definition")
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

      keymap.set("n", "<leader>ft", function()
        -- Try to use todo-comments telescope extension
        local ok = pcall(function()
          telescope.extensions["todo-comments"].todo({
            attach_mappings = function(prompt_bufnr, map_func)
              local actions = require("telescope.actions")
              map_func("i", "<Esc>", actions.close)
              map_func("n", "<Esc>", actions.close)
              map_func("n", "q", actions.close)
              return true
            end,
          })
        end)

        if not ok then
          --Fallback: use live_grep with the exact keywords from your todo-comments config
          builtin.live_grep({
            prompt_title = "🔍 Find TODOs",
            -- Using the exact pattern from your todo-comments config
            default_text = "\\b(FIX|FIXME|BUG|FIXIT|ISSUE|TODO|HACK|WARN|WARNING|XXX|PERF|OPTIM|PERFORMANCE|OPTIMIZE|NOTE|INFO|TEST|TESTING|PASSED|FAILED):",
            additional_args = { "--regex" },
            attach_mappings = function(prompt_bufnr, map_func)
              local actions = require("telescope.actions")
              map_func("i", "<Esc>", actions.close)
              map_func("n", "<Esc>", actions.close)
              map_func("n", "q", actions.close)
              return true
            end,
          })
        end
      end, { desc = "Find todos" })

      keymap.set("n", "<leader>fh", telescope_with_esc(builtin.help_tags), { desc = "Find help tags" })
      keymap.set("n", "<leader>fj", telescope_with_esc(builtin.jumplist, { initial_mode = "normal" }),
        { desc = "Find jumps" })
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