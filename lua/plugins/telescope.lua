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
      { "jvgrootveld/telescope-zoxide" },
      { "smartpde/telescope-recent-files" }
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local transform_mod = require("telescope.actions.mt").transform_mod
      local z_utils = require("telescope._extensions.zoxide.utils")

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
          zoxide = {
            prompt_title = "[ Zoxide List ]",
            -- Zoxide list command with score
            list_command = "zoxide query -ls",
            mappings = {
              default = {
                action = function(selection)
                  vim.cmd.cd(selection.path)
                end,
                after_action = function(selection)
                  vim.notify("Directory changed to " .. selection.path)
                end,
              },
              ["<CR>"] = { action = z_utils.create_basic_command("edit") },
              ["<C-s>"] = { action = z_utils.create_basic_command("split") },
              ["<C-v>"] = { action = z_utils.create_basic_command("vsplit") },
              -- ["<C-e>"] = { action = z_utils.create_basic_command("edit") },
              ["<C-f>"] = {
                keepinsert = true,
                action = function(selection)
                  require("helpers.telescope_pickers").builtin("find_files", { cwd = selection.path })
                end,
              },
              ["<C-t>"] = {
                action = function(selection)
                  vim.cmd.tcd(selection.path)
                end,
              },
            }
          },
          recent_files = {
            only_cwd = true,
            ignore_patterns = {
              -- "temp", -- matches "temp" anywhere
              "%.git",        -- dot must be escaped
              "node_modules", -- matches "node_modules" anywhere
              "%.DS_STORE",   -- escape the dot
              ".*%.meta",     -- match anything ending with ".meta"
            }
          }
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("frecency")
      telescope.load_extension("ui-select")
      telescope.load_extension("zoxide")
      telescope.load_extension("recent_files")

      -- Add a mapping
      vim.keymap.set("n", "<leader>cd", telescope.extensions.zoxide.list)

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

      local tp = require("helpers.telescope_pickers")

      local function live_grep_with_dynamic_title(opts)
        local previewers = require("telescope.previewers")

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

        tp.builtin("live_grep", config)
      end

      -- set keymaps
      local keymap = vim.keymap -- for conciseness

      keymap.set("n", "<leader>ft", function()
        -- Try to use todo-comments telescope extension
        local ok = pcall(function()
          telescope.extensions["todo-comments"].todo({
            attach_mappings = tp.compose_mappings(),
          })
        end)

        if not ok then
          --Fallback: use live_grep with the exact keywords from your todo-comments config
          tp.builtin("live_grep", {
            prompt_title = "🔍 Find TODOs",
            default_text =
            "\\b(FIX|FIXME|BUG|FIXIT|ISSUE|TODO|HACK|WARN|WARNING|XXX|PERF|OPTIM|PERFORMANCE|OPTIMIZE|NOTE|INFO|TEST|TESTING|PASSED|FAILED):",
            additional_args = { "--regex" },
          })
        end
      end, { desc = "Find todos" })

      keymap.set("n", "<leader>fh", function() tp.builtin("help_tags") end, { desc = "Find help tags" })
      keymap.set("n", "<leader>fj", function() tp.builtin("jumplist", { mode = "normal" }) end, { desc = "Find jumps" })
      keymap.set("n", "<leader>fc", function() tp.builtin("command_history") end, { desc = "Find command history" })
      keymap.set("n", "<leader>cd", require("telescope").extensions.zoxide.list, { desc = "cd using zoxide" })

      -- Enable line numbers in telescope preview windows
      vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        callback = function()
          vim.opt_local.number = true
        end,
      })
    end,
  },
  {
    "danielfalk/smart-open.nvim",
    branch = "0.2.x",
    config = function()
      require("telescope").load_extension("smart_open")
    end,
    dependencies = {
      "kkharji/sqlite.lua",
      -- Only required if using match_algorithm fzf
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
      { "nvim-telescope/telescope-fzy-native.nvim" },
    },
  }
}
