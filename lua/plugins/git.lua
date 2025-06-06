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

				map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
				map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")

				map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

				map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, "Blame line")
				map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")

				map("n", "<leader>hd", function()
					-- Show diff in a single buffer using floating window instead of split
					gs.preview_hunk()
				end, "Diff this (inline)")
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, "Diff this ~")

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns select hunk")
			end,
		},
	},

	-- Neogit - Comprehensive Git interface within Neovim
	{
		"TimUntersberger/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			local neogit = require("neogit")

			neogit.setup({
				-- Disable signs in the buffer
				signs = {
					-- Default symbols for neogit buffer
					hunk = { "", "" },
					item = { "▸", "▾" },
					section = { "▸", "▾" },
				},
				-- Integrations
				integrations = {
					telescope = true,
					diffview = true,
				},
				-- Use telescope for branch/commit selection
				use_telescope = true,
				-- Auto-refresh when git state changes
				auto_refresh = true,
				-- Disable notifications for common operations
				disable_hint = false,
				-- Git command timeout
				git_timeout = 30000,
				-- Use per-project settings if .git/neogit exists
				use_per_project_settings = true,
				-- Remember window sizes between sessions
				remember_settings = true,
				-- Auto-show console for commands that produce output
				auto_show_console = true,
				-- Console timeout
				console_timeout = 2000,
				-- Auto-close console on success
				auto_close_console = true,
			})

			-- Neogit keymaps for comprehensive Git workflow
			vim.keymap.set("n", "<leader>gs", neogit.open, { desc = "Git status (Neogit)" })
			vim.keymap.set("n", "<leader>gc", function() neogit.open({ "commit" }) end, { desc = "Git commit" })
			vim.keymap.set("n", "<leader>gp", function() neogit.open({ "push" }) end, { desc = "Git push" })
			vim.keymap.set("n", "<leader>gl", function() neogit.open({ "log" }) end, { desc = "Git log" })
			vim.keymap.set("n", "<leader>gb", function() neogit.open({ "branch" }) end, { desc = "Git branch" })

			-- Enhanced Telescope Git pickers for "Holy Grail" Git workflow
			local telescope_builtin = require("telescope.builtin")

			-- Git branches picker with enhanced UI
			vim.keymap.set("n", "<leader>gB", function()
				telescope_builtin.git_branches({
					prompt_title = "󰘬 Git Branches",
					theme = "ivy",
					layout_config = { height = 0.6 },
					-- Show both local and remote branches
					show_remote_tracking_branches = true,
					-- Sort by most recently used
					sort_mru = true,
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						-- Enter to checkout branch
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								vim.cmd("Git checkout " .. selection.value)
								vim.notify("Switched to branch: " .. selection.value, vim.log.levels.INFO)
							end
						end)

						-- Ctrl+D to delete branch
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

						return true
					end,
				})
			end, { desc = "Git branches (Telescope)" })

			-- Git commits picker with enhanced functionality
			vim.keymap.set("n", "<leader>gC", function()
				telescope_builtin.git_commits({
					prompt_title = "󰜘 Git Commits",
					theme = "ivy",
					layout_config = {
						height = 0.8,
						preview_cutoff = 120,
					},
					-- Show diff in preview
					git_command = { "git", "log", "--pretty=oneline", "--abbrev-commit", "--graph" },
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						-- Enter to show commit details in diffview
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								vim.cmd("DiffviewOpen " .. selection.value .. "^!")
							end
						end)

						-- Ctrl+R to reset to this commit
						map("i", "<C-r>", function()
							local selection = action_state.get_selected_entry()
							if selection then
								vim.ui.input({
									prompt = "Reset to commit " .. selection.value .. "? (soft/hard/mixed): ",
								}, function(input)
									if input and (input == "soft" or input == "hard" or input == "mixed") then
										vim.cmd("Git reset --" .. input .. " " .. selection.value)
										vim.notify("Reset to commit: " .. selection.value, vim.log.levels.INFO)
									end
								end)
							end
						end)

						return true
					end,
				})
			end, { desc = "Git commits (Telescope)" })

			-- Git file status picker
			vim.keymap.set("n", "<leader>gS", function()
				telescope_builtin.git_status({
					prompt_title = "󰊢 Git Status",
					theme = "ivy",
					layout_config = { height = 0.6 },
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						-- Enter to open file
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								vim.cmd("edit " .. selection.value)
							end
						end)

						-- Ctrl+S to stage file
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

						-- Ctrl+U to unstage file
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

						return true
					end,
				})
			end, { desc = "Git status files (Telescope)" })

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

			-- Git file browser - Browse files in any commit/branch
			vim.keymap.set("n", "<leader>gF", function()
				-- First select a commit/branch, then browse files
				telescope_builtin.git_commits({
					prompt_title = "󰜘 Select Commit to Browse Files",
					theme = "ivy",
					layout_config = { height = 0.6 },
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								-- Browse files in that commit
								telescope_builtin.git_files({
									prompt_title = "󰈞 Files in " .. selection.value:sub(1, 8),
									theme = "ivy",
									git_command = { "git", "ls-tree", "-r", "--name-only", selection.value },
									attach_mappings = function(prompt_bufnr2, map2)
										actions.select_default:replace(function()
											local file_selection = action_state.get_selected_entry()
											actions.close(prompt_bufnr2)
											if file_selection then
												-- Show file content from that commit
												vim.cmd("Git show " .. selection.value .. ":" .. file_selection.value)
											end
										end)
										return true
									end,
								})
							end
						end)
						return true
					end,
				})
			end, { desc = "Browse Git files in commit" })

			-- Git blame for current file with telescope
			vim.keymap.set("n", "<leader>gf", function()
				local file = vim.fn.expand("%")
				if file == "" then
					vim.notify("No file in current buffer", vim.log.levels.WARN)
					return
				end

				-- Get git blame info and show in telescope
				local handle = io.popen("git blame --porcelain " .. file)
				if not handle then
					vim.notify("Failed to run git blame", vim.log.levels.ERROR)
					return
				end

				local blame_data = {}
				local current_commit = nil
				local line_num = 1

				for line in handle:lines() do
					if line:match("^%x+") then
						current_commit = line:sub(1, 8)
					elseif line:match("^author ") then
						local author = line:sub(8)
						table.insert(blame_data, {
							line = line_num,
							commit = current_commit,
							author = author,
							display = string.format("%3d │ %s │ %s", line_num, current_commit, author),
						})
						line_num = line_num + 1
					end
				end
				handle:close()

				require("telescope.pickers").new({}, {
					prompt_title = "󰙃 Git Blame: " .. vim.fn.fnamemodify(file, ":t"),
					finder = require("telescope.finders").new_table({
						results = blame_data,
						entry_maker = function(entry)
							return {
								value = entry,
								display = entry.display,
								ordinal = entry.display,
							}
						end,
					}),
					sorter = require("telescope.config").values.generic_sorter({}),
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								-- Jump to line and show commit details
								vim.cmd(selection.value.line)
								vim.cmd("DiffviewOpen " .. selection.value.commit .. "^!")
							end
						end)
						return true
					end,
				}):find()
			end, { desc = "Git blame current file (Telescope)" })

			-- Git remotes management
			vim.keymap.set("n", "<leader>gR", function()
				local handle = io.popen("git remote -v")
				if not handle then
					vim.notify("Failed to get git remotes", vim.log.levels.ERROR)
					return
				end

				local remotes = {}
				local seen = {}
				for line in handle:lines() do
					local name, url, type_info = line:match("([^%s]+)%s+([^%s]+)%s+%(([^%)]+)%)")
					if name and url and type_info and not seen[name] then
						seen[name] = true
						table.insert(remotes, {
							name = name,
							url = url,
							type = type_info,
							display = string.format("%-10s │ %s │ (%s)", name, url, type_info),
						})
					end
				end
				handle:close()

				if #remotes == 0 then
					vim.notify("No git remotes found", vim.log.levels.INFO)
					return
				end

				require("telescope.pickers").new({}, {
					prompt_title = "󰞶 Git Remotes",
					finder = require("telescope.finders").new_table({
						results = remotes,
						entry_maker = function(entry)
							return {
								value = entry,
								display = entry.display,
								ordinal = entry.name .. " " .. entry.url,
							}
						end,
					}),
					sorter = require("telescope.config").values.generic_sorter({}),
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						-- Enter to fetch from remote
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								vim.cmd("Git fetch " .. selection.value.name)
								vim.notify("Fetched from: " .. selection.value.name, vim.log.levels.INFO)
							end
						end)

						-- Ctrl+P to push to remote
						map("i", "<C-p>", function()
							local selection = action_state.get_selected_entry()
							if selection then
								actions.close(prompt_bufnr)
								vim.cmd("Git push " .. selection.value.name)
								vim.notify("Pushed to: " .. selection.value.name, vim.log.levels.INFO)
							end
						end)

						return true
					end,
				}):find()
			end, { desc = "Git remotes management" })
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
			vim.keymap.set("n", "<leader>gl", "<cmd>LazyGit<cr>", { desc = "LazyGit (duplicate mapping)" })
		end,
	},
}
