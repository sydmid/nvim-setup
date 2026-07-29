-- Git configuration and integrations
return {
	-- Git integration
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			current_line_blame = false,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 300,
				ignore_whitespace = true,
				virt_text_priority = 100,
			},
			current_line_blame_formatter = " <author>, <author_time:%R> - <summary>",
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
				end

				-- Navigation
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
				map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
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

				-- Toggle inline blame
				map("n", "<leader>gn", gs.toggle_current_line_blame, "Toggle line blame")

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
			-- vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status " })

			-- Git commit with enhanced workflow
			vim.keymap.set("n", "<leader>gC", function()
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

			-- Enhanced Telescope Git pickers with Fugitive backend
			local tp = require("helpers.telescope_pickers")

			-- Git branches picker with fugitive backend
			vim.keymap.set("n", "<leader>gb", function()
				-- Get current project root for scoping
				local cwd = vim.fn.getcwd()
				local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")[1]

				-- Check if we're in a git repository
				if vim.v.shell_error ~= 0 then
					vim.notify("Not in a git repository", vim.log.levels.WARN)
					return
				end

				local project_root = git_root

				tp.builtin("git_branches", {
					layout = "ivy",
					mode = "normal",
					prompt_title = "󰘬 Git Branches - " .. vim.fn.fnamemodify(project_root, ":t"),
					cwd = project_root,
					show_remote_tracking_branches = true,
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
											tp.builtin("git_branches", {
												layout = "ivy",
												mode = "normal",
												prompt_title = "󰘬 Git Branches - " .. vim.fn.fnamemodify(project_root, ":t"),
												cwd = project_root,
												show_remote_tracking_branches = true,
												sort_mru = true,
											})
										end
									end)
								else
									vim.notify("Cannot delete main/master branch", vim.log.levels.WARN)
								end
							end
						end)

						return true
					end,
				})
			end, { desc = "Git branches " })

			-- Git stashes picker
			vim.keymap.set("n", "<leader>gT", function()
				-- Check if we're in a git repository
				local cwd = vim.fn.getcwd()
				vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")
				if vim.v.shell_error ~= 0 then
					vim.notify("Not in a git repository", vim.log.levels.WARN)
					return
				end

				tp.builtin("git_stash", {
					layout = "ivy",
					mode = "normal",
					prompt_title = "󰜦 Git Stashes",
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
										tp.builtin("git_stash", {
											layout = "ivy",
											mode = "normal",
											prompt_title = "󰜦 Git Stashes",
										})
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

				-- Check if we're in a git repository
				if vim.v.shell_error ~= 0 then
					vim.notify("Not in a git repository", vim.log.levels.WARN)
					return
				end

				local project_root = git_root

				tp.builtin("git_status", {
					layout = "ivy",
					mode = "normal",
					height = 0.9,
					prompt_title = "󰊢  Changed Files - " .. vim.fn.fnamemodify(project_root, ":t"),
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
						map("n", "<C-s>", function()
							local selection = action_state.get_selected_entry()
							if selection then
								vim.cmd("Git add " .. selection.value)
								vim.notify("Staged: " .. selection.value, vim.log.levels.INFO)
								-- Refresh the picker
								actions.close(prompt_bufnr)
								tp.builtin("git_status", {
									layout = "ivy",
									mode = "normal",
									prompt_title = "󰊢  Changed Files - " .. vim.fn.fnamemodify(project_root, ":t"),
									cwd = project_root,
								})
							end
						end)

						-- Ctrl+U to unstage file using fugitive
						map("n", "<C-u>", function()
							local selection = action_state.get_selected_entry()
							if selection then
								vim.cmd("Git reset HEAD " .. selection.value)
								vim.notify("Unstaged: " .. selection.value, vim.log.levels.INFO)
								-- Refresh the picker
								actions.close(prompt_bufnr)
								tp.builtin("git_status", {
									layout = "ivy",
									mode = "normal",
									prompt_title = "󰊢  Changed Files - " .. vim.fn.fnamemodify(project_root, ":t"),
									cwd = project_root,
								})
							end
						end)

						-- Ctrl+D to diff file using fugitive
						map("n", "<C-d>", function()
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

						return true
					end,
				})
			end, { desc = "Git changed files " })

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
				-- Check if we're in a git repository
				local cwd = vim.fn.getcwd()
				vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")
				if vim.v.shell_error ~= 0 then
					vim.notify("Not in a git repository", vim.log.levels.WARN)
					return
				end

				-- First select a commit/branch, then browse files
				tp.builtin("git_commits", {
					layout = "ivy",
					mode = "normal",
					prompt_title = "󰜘 Enhanced Explorable Logs",
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								local commit_hash = selection.value:match("^(%w+)")
								-- Browse files in that commit using fugitive
								tp.builtin("git_files", {
									layout = "ivy",
									mode = "normal",
									prompt_title = "󰈞 Files in " .. commit_hash:sub(1, 8) .. " ",
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
		keys = {},
		config = function()
			-- Configure LazyGit
			vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
			vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
			vim.g.lazygit_floating_window_corner_chars = {'╭', '╮', '╰', '╯'} -- customize lazygit popup window corner characters
			vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
			vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed
		end,
	},

	-- Diffview.nvim - VS Code-like side-by-side diff, file history, and merge tool
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewFileHistory",
			"DiffviewRefresh",
		},
		keys = {
			{ "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open (vs HEAD)" },
			{ "<leader>gV", "<cmd>DiffviewOpen main<cr>", desc = "Diffview: open (vs main)" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
			{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: repo history" },
			{ "<leader>gm", "<cmd>DiffviewOpen<cr>", desc = "Diffview: merge tool" },
			{
				"<M-S-d>",
				function()
					local lib = require("diffview.lib")
					local view = lib.get_current_view()
					if view then
						vim.cmd("DiffviewClose")
					else
						vim.cmd("DiffviewOpen")
					end
				end,
				desc = "Toggle Diffview",
			},
		},
		config = function()
			local actions = require("diffview.actions")
			require("diffview").setup({
				diff_binaries = false,
				enhanced_diff_hl = true,
				use_icons = true,
				show_help_hints = true,
				watch_index = true,

				icons = {
					folder_closed = "",
					folder_open = "",
				},
				signs = {
					fold_closed = "",
					fold_open = "",
					done = "✓",
				},

				view = {
					default = {
						layout = "diff2_horizontal",
						disable_diagnostics = true,
						winbar_info = true,
					},
					merge_tool = {
						layout = "diff3_horizontal",
						disable_diagnostics = true,
						winbar_info = true,
					},
					file_history = {
						layout = "diff2_horizontal",
						disable_diagnostics = true,
						winbar_info = true,
					},
				},

				file_panel = {
					listing_style = "tree",
					tree_options = {
						flatten_dirs = true,
						folder_statuses = "only_folded",
					},
					win_config = {
						position = "left",
						width = 35,
						win_opts = {},
					},
				},

				file_history_panel = {
					log_options = {
						git = {
							single_file = {
								diff_merges = "combined",
								follow = true,
							},
							multi_file = {
								diff_merges = "first-parent",
							},
						},
					},
					win_config = {
						position = "bottom",
						height = 16,
						win_opts = {},
					},
				},

				keymaps = {
					disable_defaults = false,
					view = {
						{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
						{ "n", "<Esc>", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
						{ "n", "<leader>e", actions.focus_files, { desc = "Focus file panel" } },
						{ "n", "<leader>b", actions.toggle_files, { desc = "Toggle file panel" } },
					},
					file_panel = {
						{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
						{ "n", "<Esc>", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
						{ "n", "j", actions.next_entry, { desc = "Next file" } },
						{ "n", "k", actions.prev_entry, { desc = "Prev file" } },
						{ "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
						{ "n", "s", actions.toggle_stage_entry, { desc = "Stage/unstage file" } },
						{ "n", "S", actions.stage_all, { desc = "Stage all" } },
						{ "n", "U", actions.unstage_all, { desc = "Unstage all" } },
						{ "n", "X", actions.restore_entry, { desc = "Discard changes" } },
						{ "n", "R", actions.refresh_files, { desc = "Refresh" } },
						{ "n", "L", actions.open_commit_log, { desc = "Open commit log" } },
						{ "n", "<leader>e", actions.focus_files, { desc = "Focus file panel" } },
						{ "n", "<leader>b", actions.toggle_files, { desc = "Toggle file panel" } },
					},
					file_history_panel = {
						{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
						{ "n", "<Esc>", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
						{ "n", "j", actions.next_entry, { desc = "Next entry" } },
						{ "n", "k", actions.prev_entry, { desc = "Prev entry" } },
						{ "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
						{ "n", "!", actions.options, { desc = "Open options" } },
						{ "n", "L", actions.open_commit_log, { desc = "Open commit log" } },
						{ "n", "y", actions.copy_hash, { desc = "Copy commit hash" } },
						{ "n", "zR", actions.open_all_folds, { desc = "Open all folds" } },
						{ "n", "zM", actions.close_all_folds, { desc = "Close all folds" } },
					},
				},
			})
		end,
	},

	-- git-conflict.nvim - VS Code-style inline merge conflict resolution
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		event = "BufReadPre",
		config = function()
			require("git-conflict").setup({
				default_mappings = false,
				default_commands = true,
				disable_diagnostics = true,
				list_opener = "copen",
				highlights = {
					incoming = "DiffAdd",
					current = "DiffText",
				},
			})

			vim.keymap.set("n", "<leader>gco", "<cmd>GitConflictChooseOurs<cr>", { desc = "Conflict: accept current (ours)" })
			vim.keymap.set("n", "<leader>gct", "<cmd>GitConflictChooseTheirs<cr>", { desc = "Conflict: accept incoming (theirs)" })
			vim.keymap.set("n", "<leader>gcb", "<cmd>GitConflictChooseBoth<cr>", { desc = "Conflict: accept both" })
			vim.keymap.set("n", "<leader>gcn", "<cmd>GitConflictChooseNone<cr>", { desc = "Conflict: accept none" })
			vim.keymap.set("n", "<leader>gcl", "<cmd>GitConflictListQf<cr>", { desc = "Conflict: list all conflicts" })
			vim.keymap.set("n", "]X", "<cmd>GitConflictNextConflict<cr>", { desc = "Next git conflict" })
			vim.keymap.set("n", "[X", "<cmd>GitConflictPrevConflict<cr>", { desc = "Prev git conflict" })
		end,
	},

	-- gitlinker.nvim - Generate and copy shareable git URLs
	{
		"ruifm/gitlinker.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>gy",
				function()
					require("gitlinker").get_buf_range_url("n")
				end,
				mode = "n",
				desc = "Copy git URL to clipboard",
			},
			{
				"<leader>gy",
				function()
					require("gitlinker").get_buf_range_url("v")
				end,
				mode = "v",
				desc = "Copy git URL for selection",
			},
		},
		config = function()
			require("gitlinker").setup({
				opts = {
					action_callback = require("gitlinker.actions").copy_to_clipboard,
					print_url = true,
				},
				mappings = nil,
			})
		end,
	},
}