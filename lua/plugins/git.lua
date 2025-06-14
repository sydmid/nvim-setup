-- Git configuration and integrations
return {
	-- Git integration
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
				end

				-- Navigation
				-- Git hunks navigation with [ and ] were causing navigation delays
				-- Original: map("n", "]h", gs.next_hunk, "Next Hunk")
				-- Original: map("n", "[h", gs.prev_hunk, "Prev Hunk")
				map("n", "<leader>hj", gs.next_hunk, "Next Hunk")
				map("n", "<leader>hk", gs.prev_hunk, "Prev Hunk")

				-- Actions
				map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
				map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Stage hunk")
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Reset hunk")

				map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")

				map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
				map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
				map("n", "<leader>hh", gs.preview_hunk, "Preview hunk")
				map("n", "<leader>gd", function()
					-- Show diff in a single buffer using floating window instead of split
					gs.preview_hunk()
				end, "Diff this (inline)")
				map("n", "<leader>gD", function()
					-- Store the original buffer number before starting diff
					local original_buf = vim.api.nvim_get_current_buf()
					local original_win = vim.api.nvim_get_current_win()

					gs.diffthis("~")

					-- Set up buffer-local mappings for Esc and q to close diff
					vim.defer_fn(function()
						-- Only set the mapping if we're still in a diff buffer
						if vim.wo.diff then
							local function close_diff()
								-- Turn off diff mode for all windows
								vim.cmd("windo diffoff")

								-- Close any temporary diff buffers and return to original
								local current_buf = vim.api.nvim_get_current_buf()
								local buffers = vim.api.nvim_list_bufs()

								-- Find and close temporary git buffers (usually unnamed or with git-related names)
								for _, buf in ipairs(buffers) do
									local buf_name = vim.api.nvim_buf_get_name(buf)
									if buf ~= original_buf and vim.api.nvim_buf_is_loaded(buf) then
										-- Check if it's a temporary buffer (no name or git-related)
										if buf_name == "" or buf_name:match("%.git/") or buf_name:match("fugitive://") then
											pcall(vim.api.nvim_buf_delete, buf, { force = true })
										end
									end
								end

								-- Ensure we're back in the original buffer and window
								if vim.api.nvim_buf_is_valid(original_buf) then
									if vim.api.nvim_win_is_valid(original_win) then
										vim.api.nvim_set_current_win(original_win)
									end
									vim.api.nvim_set_current_buf(original_buf)
								end

								-- Remove both mappings
								pcall(vim.keymap.del, "n", "<Esc>", { buffer = 0 })
								pcall(vim.keymap.del, "n", "q", { buffer = 0 })
							end

							-- Set up both Esc and q key mappings
							vim.keymap.set("n", "<Esc>", close_diff, { buffer = 0, silent = true, desc = "Close diff" })
							vim.keymap.set("n", "q", close_diff, { buffer = 0, silent = true, desc = "Close diff" })
						end
					end, 100) -- Small delay to ensure diff is set up
				end, "Diff this ~")

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns select hunk")
			end,
		},
	},

	-- Fugitive-based Git workflow - Advanced yet easy-to-use Git integration
	{
		"tpope/vim-fugitive",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- Auto-setup 'q' to quit in all fugitive buffers
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "fugitive", "git", "fugitiveblame" },
				callback = function()
					local function close_buffer()
						local success = pcall(vim.cmd, "close")
						if not success then
							pcall(vim.cmd, "bdelete")
						end
					end
					vim.keymap.set("n", "q", close_buffer, { buffer = true, silent = true })
					vim.keymap.set("n", "<Esc>", close_buffer, { buffer = true, silent = true })
				end,
			})

			-- Auto-setup 'q' and 'Esc' to quit in fugitive:// buffers
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "fugitive://*",
				callback = function()
					local function close_buffer()
						local success = pcall(vim.cmd, "close")
						if not success then
							pcall(vim.cmd, "bdelete")
						end
					end
					vim.keymap.set("n", "q", close_buffer, { buffer = true, silent = true })
					vim.keymap.set("n", "<Esc>", close_buffer, { buffer = true, silent = true })
				end,
			})

			-- Fugitive keymaps for comprehensive Git workflow
			vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status " })

			-- Git commit with enhanced workflow
			vim.keymap.set("n", "<leader>gc", function()
				-- Open git status first, then commit
				vim.cmd("Git")
				vim.defer_fn(function()
					-- If we're in the git status buffer, trigger commit
					local buf_name = vim.api.nvim_buf_get_name(0)
					if buf_name:match("%.git/index$") or vim.bo.filetype == "fugitive" then
						vim.cmd("Git commit")
					end
				end, 100)
			end, { desc = "Git commit " })

			-- Git push
			vim.keymap.set("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git push " })

			-- Git pull
			vim.keymap.set("n", "<leader>gP", "<cmd>Git pull<cr>", { desc = "Git pull " })

			-- Git log
			-- vim.keymap.set("n", "<leader>gl", "<cmd>Git log --oneline --graph --decorate --all<cr>", { desc = "Git log " })

			-- Enhanced Telescope Git pickers with Fugitive backend
			local telescope_builtin = require("telescope.builtin")

			-- Git blame in telescope-style interface
			vim.keymap.set("n", "<leader>gb", function()
				-- Get current file and line
				local current_file = vim.fn.expand("%")
				if current_file == "" then
					vim.notify("No file open for blame", vim.log.levels.WARN)
					return
				end

				-- Use fugitive's blame with better UI
				vim.cmd("Git blame")

				-- Add keymaps for the blame buffer with improved detection
				vim.defer_fn(function()
					local buf = vim.api.nvim_get_current_buf()
					local buf_name = vim.api.nvim_buf_get_name(buf)
					local filetype = vim.bo[buf].filetype

					-- Check for fugitive blame buffer by name pattern or filetype
					if buf_name:match("fugitive://") or filetype == "fugitiveblame" then
						-- Function to properly close blame buffer
						local function close_blame()
							-- Try multiple methods to close the blame buffer
							local success = pcall(vim.cmd, "close")
							if not success then
								pcall(vim.cmd, "bdelete")
							end
						end

						-- Add convenient keymaps for blame navigation
						vim.keymap.set("n", "<CR>", "<CR>", { buffer = buf, silent = true, desc = "Show commit" })
						vim.keymap.set("n", "q", close_blame, { buffer = buf, silent = true, desc = "Close blame" })
						vim.keymap.set("n", "<Esc>", close_blame, { buffer = buf, silent = true, desc = "Close blame" })
						vim.keymap.set("n", "o", function()
							-- Open commit in new split
							vim.cmd("normal! o")
						end, { buffer = buf, silent = true, desc = "Open commit in split" })
					end
				end, 150) -- Slightly longer delay to ensure buffer is fully loaded
			end, { desc = "Git blame " })

			-- Git branches picker with fugitive backend
			vim.keymap.set("n", "<leader>gB", function()
				-- Get current project root for scoping
				local cwd = vim.fn.getcwd()
				local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")[1]
				local project_root = (vim.v.shell_error == 0 and git_root) or cwd

				telescope_builtin.git_branches({
					prompt_title = "󰘬 Git Branches - " .. vim.fn.fnamemodify(project_root, ":t"),
                    initial_mode = "normal",
					theme = "ivy",
					layout_config = { height = 0.6 },
					cwd = project_root,
					-- Show both local and remote branches
					show_remote_tracking_branches = true,
					-- Sort by most recently used
					sort_mru = true,
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						-- Enter to checkout branch using fugitive
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								vim.cmd("Git checkout " .. selection.value)
								vim.notify("Switched to branch: " .. selection.value, vim.log.levels.INFO)
							end
						end)

						-- Ctrl+D to delete branch using fugitive
						map("i", "<C-d>", function()
							local selection = action_state.get_selected_entry()
							if selection then
								local branch = selection.value
								if branch ~= "main" and branch ~= "master" then
									vim.ui.input({
										prompt = "Delete branch '" .. branch .. "'? (y/N): ",
									}, function(input)
										if input and input:lower() == "y" then
											vim.cmd("Git branch -d " .. branch)
											vim.notify("Deleted branch: " .. branch, vim.log.levels.INFO)
											-- Refresh the picker
											actions.close(prompt_bufnr)
											telescope_builtin.git_branches()
										end
									end)
								else
									vim.notify("Cannot delete main/master branch", vim.log.levels.WARN)
								end
							end
						end)

						-- q or Esc to close
						map("n", "q", actions.close)
						map("i", "<Esc>", actions.close)
						map("n", "<Esc>", actions.close)

						return true
					end,
				})
			end, { desc = "Git branches " })

			-- Git stashes picker
			vim.keymap.set("n", "<leader>gT", function()
				telescope_builtin.git_stash({
					prompt_title = "󰜦 Git Stashes",
					theme = "ivy",
					layout_config = { height = 0.6 },
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						-- Enter to apply stash
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								vim.cmd("Git stash apply " .. selection.value)
								vim.notify("Applied stash: " .. selection.value, vim.log.levels.INFO)
							end
						end)

						-- Ctrl+D to drop stash
						map("i", "<C-d>", function()
							local selection = action_state.get_selected_entry()
							if selection then
								vim.ui.input({
									prompt = "Drop stash " .. selection.value .. "? (y/N): ",
								}, function(input)
									if input and input:lower() == "y" then
										vim.cmd("Git stash drop " .. selection.value)
										vim.notify("Dropped stash: " .. selection.value, vim.log.levels.INFO)
										-- Refresh the picker
										actions.close(prompt_bufnr)
										telescope_builtin.git_stash()
									end
								end)
							end
						end)

						return true
					end,
				})
			end, { desc = "Git stashes (Telescope)" })

			-- Enhanced git status files picker with fugitive backend
			vim.keymap.set("n", "<leader>gf", function()
				-- Get current project root for scoping
				local cwd = vim.fn.getcwd()
				local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")[1]
				local project_root = (vim.v.shell_error == 0 and git_root) or cwd

				telescope_builtin.git_status({
					prompt_title = "󰊢  Changed Files - " .. vim.fn.fnamemodify(project_root, ":t"),
					initial_mode = "normal",
					theme = "ivy",
					layout_config = { height = 0.6 },
					cwd = project_root,
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						-- Enter to open file using fugitive
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								vim.cmd("Gedit " .. selection.value)
							end
						end)

						-- Ctrl+S to stage file using fugitive
						map("i", "<C-s>", function()
							local selection = action_state.get_selected_entry()
							if selection then
								vim.cmd("Git add " .. selection.value)
								vim.notify("Staged: " .. selection.value, vim.log.levels.INFO)
								-- Refresh the picker
								actions.close(prompt_bufnr)
								telescope_builtin.git_status()
							end
						end)

						-- Ctrl+U to unstage file using fugitive
						map("i", "<C-u>", function()
							local selection = action_state.get_selected_entry()
							if selection then
								vim.cmd("Git reset HEAD " .. selection.value)
								vim.notify("Unstaged: " .. selection.value, vim.log.levels.INFO)
								-- Refresh the picker
								actions.close(prompt_bufnr)
								telescope_builtin.git_status()
							end
						end)

						-- Ctrl+D to diff file using fugitive
						map("i", "<C-d>", function()
							local selection = action_state.get_selected_entry()
							if selection then
								actions.close(prompt_bufnr)
								vim.cmd("Git diff " .. selection.value)
							end
						end)

						-- Tab navigation between prompt and preview
						local focus_preview = function(prompt_bufnr)
							local action_state = require("telescope.actions.state")
							local picker = action_state.get_current_picker(prompt_bufnr)
							local prompt_win = picker.prompt_win
							local previewer = picker.previewer
							local winid = previewer.state.winid
							local bufnr = previewer.state.bufnr
							vim.keymap.set("n", "<Tab>", function()
								vim.cmd(string.format("noautocmd lua vim.api.nvim_set_current_win(%s)", prompt_win))
							end, { buffer = bufnr })
							vim.cmd(string.format("noautocmd lua vim.api.nvim_set_current_win(%s)", winid))
						end

						-- Bind Tab to focus preview window
						map("n", "<Tab>", focus_preview)
						map("i", "<Tab>", focus_preview)

						-- q or Esc to close
						map("n", "q", actions.close)
						map("i", "<Esc>", actions.close)
						map("n", "<Esc>", actions.close)

						return true
					end,
				})
			end, { desc = "Git status files " })

			-- Git stashes picker
			vim.keymap.set("n", "<leader>gT", function()
				telescope_builtin.git_stash({
					prompt_title = "󰜦 Git Stashes",
					theme = "ivy",
					layout_config = { height = 0.6 },
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						-- Enter to apply stash
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								vim.cmd("Git stash apply " .. selection.value)
								vim.notify("Applied stash: " .. selection.value, vim.log.levels.INFO)
							end
						end)

						-- Ctrl+D to drop stash
						map("i", "<C-d>", function()
							local selection = action_state.get_selected_entry()
							if selection then
								vim.ui.input({
									prompt = "Drop stash " .. selection.value .. "? (y/N): ",
								}, function(input)
									if input and input:lower() == "y" then
										vim.cmd("Git stash drop " .. selection.value)
										vim.notify("Dropped stash: " .. selection.value, vim.log.levels.INFO)
										-- Refresh the picker
										actions.close(prompt_bufnr)
										telescope_builtin.git_stash()
									end
								end)
							end
						end)

						return true
					end,
				})
			end, { desc = "Git stashes (Telescope)" })

			-- Quick stash creation
			vim.keymap.set("n", "<leader>gt", function()
				vim.ui.input({
					prompt = "Stash message (optional): ",
				}, function(input)
					local cmd = "Git stash"
					if input and input ~= "" then
						cmd = cmd .. " push -m '" .. input .. "'"
					end
					vim.cmd(cmd)
					vim.notify("Created stash" .. (input and ": " .. input or ""), vim.log.levels.INFO)
				end)
			end, { desc = "Create Git stash" })

			-- Enhanced git file browser with fugitive backend
			vim.keymap.set("n", "<leader>gl", function()
				-- First select a commit/branch, then browse files
				telescope_builtin.git_commits({
					prompt_title = "󰜘 Enhanced Explorable Logs",
                    initial_mode = "normal",
					theme = "ivy",
					layout_config = { height = 0.6 },
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								local commit_hash = selection.value:match("^(%w+)")
								-- Browse files in that commit using fugitive
								telescope_builtin.git_files({
									prompt_title = "󰈞 Files in " .. commit_hash:sub(1, 8) .. " ",
									initial_mode = "normal",
									theme = "ivy",
									git_command = { "git", "ls-tree", "-r", "--name-only", commit_hash },
									attach_mappings = function(prompt_bufnr2, map2)
										actions.select_default:replace(function()
											local file_selection = action_state.get_selected_entry()
											actions.close(prompt_bufnr2)
											if file_selection then
												-- Show file content from that commit using fugitive
												vim.cmd("Git show " .. commit_hash .. ":" .. file_selection.value)
											end
										end)

										-- Ctrl+D to diff file against current version
										map2("i", "<C-d>", function()
											local file_selection = action_state.get_selected_entry()
											if file_selection then
												actions.close(prompt_bufnr2)
												vim.cmd("Git diff " .. commit_hash .. " -- " .. file_selection.value)
											end
										end)

										-- Tab navigation between prompt and preview for file browser
										local focus_preview_files = function(prompt_bufnr2)
											local action_state = require("telescope.actions.state")
											local picker = action_state.get_current_picker(prompt_bufnr2)
											local prompt_win = picker.prompt_win
											local previewer = picker.previewer
											local winid = previewer.state.winid
											local bufnr = previewer.state.bufnr
											vim.keymap.set("n", "<Tab>", function()
												vim.cmd(string.format("noautocmd lua vim.api.nvim_set_current_win(%s)", prompt_win))
											end, { buffer = bufnr })
											vim.cmd(string.format("noautocmd lua vim.api.nvim_set_current_win(%s)", winid))
										end

										-- Bind Tab to focus preview window for file browser
										map2("n", "<Tab>", focus_preview_files)
										map2("i", "<Tab>", focus_preview_files)

										-- q or Esc to close
										map2("n", "q", actions.close)
										map2("i", "<Esc>", actions.close)
										map2("n", "<Esc>", actions.close)

										return true
									end,
								})
							end
						end)

						-- Tab navigation between prompt and preview for commit log
						local focus_preview_commits = function(prompt_bufnr)
							local action_state = require("telescope.actions.state")
							local picker = action_state.get_current_picker(prompt_bufnr)
							local prompt_win = picker.prompt_win
							local previewer = picker.previewer
							local winid = previewer.state.winid
							local bufnr = previewer.state.bufnr
							vim.keymap.set("n", "<Tab>", function()
								vim.cmd(string.format("noautocmd lua vim.api.nvim_set_current_win(%s)", prompt_win))
							end, { buffer = bufnr })
							vim.cmd(string.format("noautocmd lua vim.api.nvim_set_current_win(%s)", winid))
						end

						-- Bind Tab to focus preview window for commit log
						map("n", "<Tab>", focus_preview_commits)
						map("i", "<Tab>", focus_preview_commits)

						-- q or Esc to close
						map("n", "q", actions.close)
						map("i", "<Esc>", actions.close)
						map("n", "<Esc>", actions.close)

						return true
					end,
				})
			end, { desc = "Browse Git files in commit " })

		end,
	},

	-- LazyGit integration - Full-featured Git TUI for complex operations
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
			{ "<leader>lf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit current file" },
		},
		config = function()
			-- Configure LazyGit
			vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
			vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
			vim.g.lazygit_floating_window_corner_chars = {'╭', '╮', '╰', '╯'} -- customize lazygit popup window corner characters
			vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
			vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

			-- Additional keymaps for comprehensive Git workflow
			vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Open LazyGit" })
		end,
	},
}
