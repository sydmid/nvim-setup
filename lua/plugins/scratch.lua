return {
	-- Scratch.nvim - Create temporary playground files effortlessly
	{
		"LintaoAmons/scratch.nvim",
		event = "VeryLazy",
		config = function()
			-- Ensure scratch directory exists
			local scratch_dir = vim.fn.expand("~/.local/share/nvim/scratch")
			vim.fn.mkdir(scratch_dir, "p")

			require("scratch").setup({
				scratch_file_dir = scratch_dir, -- Directory for scratch files
				window_cmd = "edit", -- Default command to open scratch files
				use_telescope = true, -- Enable telescope integration
				filetypes = { "lua", "js", "py", "md", "txt" }, -- Default filetypes for new scratch files
			})

			-- Enhanced Telescope wrapper for scratch functionality
			local function scratch_telescope_picker()
				local pickers = require("telescope.pickers")
				local finders = require("telescope.finders")
				local conf = require("telescope.config").values
				local actions = require("telescope.actions")
				local action_state = require("telescope.actions.state")

				-- Define scratch commands with beautiful icons and descriptions
				local scratch_commands = {
					{
						name = "󰈔 Create New Scratch File",
						desc = "Create a new scratch file with auto-generated name",
						cmd = "Scratch",
						icon = "󰈔",
					},
					{
						name = "󰏫 Create Named Scratch File",
						desc = "Create a new scratch file with custom name and extension",
						cmd = "ScratchWithName",
						icon = "󰏫",
					},
					{
						name = "󰈞 Open Existing Scratch File",
						desc = "Browse and open existing scratch files",
						cmd = "ScratchOpen",
						icon = "󰈞",
					},
					{
						name = "󰍉 Search Scratch Files Content",
						desc = "Fuzzy search through scratch file contents",
						cmd = "ScratchOpenFzf",
						icon = "󰍉",
					},
					{
						name = "󰆴 Open Scratch Directory",
						desc = "Open scratch files directory in file explorer",
						cmd = function()
							local scratch_dir = vim.fn.expand("~/.local/share/nvim/scratch")
							-- Create directory if it doesn't exist
							vim.fn.mkdir(scratch_dir, "p")
							-- Open in oil or nvim-tree
							if pcall(require, "oil") then
								require("oil").open(scratch_dir)
							else
								vim.cmd("edit " .. scratch_dir)
							end
						end,
						icon = "󰆴",
					},
					{
						name = "󰃨 Quick Notes",
						desc = "Create a quick markdown notes file",
						cmd = function()
							local date = os.date("%Y-%m-%d")
							local time = os.date("%H-%M")
							local filename = string.format("notes-%s-%s.md", date, time)
							local scratch_dir = vim.fn.expand("~/.local/share/nvim/scratch")
							vim.fn.mkdir(scratch_dir, "p")
							local filepath = scratch_dir .. "/" .. filename
							vim.cmd("edit " .. filepath)
							-- Add a basic markdown template
							vim.api.nvim_buf_set_lines(0, 0, -1, false, {
								"# Quick Notes - " .. os.date("%Y-%m-%d %H:%M"),
								"",
								"## Overview",
								"",
								"## Tasks",
								"- [ ] ",
								"",
								"## Ideas",
								"",
								"## Links",
								"",
							})
							-- Position cursor at the first task
							vim.api.nvim_win_set_cursor(0, { 6, 6 })
						end,
						icon = "󰃨",
					},
					{
						name = "󰗀 Code Playground",
						desc = "Create a new coding playground file",
						cmd = function()
							-- Show filetype selection first
							local filetypes = {
								{ name = "JavaScript (.js)", ext = "js", template = "console.log('Hello, JavaScript!');" },
								{ name = "TypeScript (.ts)", ext = "ts", template = "console.log('Hello, TypeScript!');" },
								{ name = "Python (.py)", ext = "py", template = "print('Hello, Python!')" },
								{ name = "Lua (.lua)", ext = "lua", template = "print('Hello, Lua!')" },
								{ name = "Rust (.rs)", ext = "rs", template = "fn main() {\n    println!(\"Hello, Rust!\");\n}" },
								{ name = "Go (.go)", ext = "go", template = "package main\n\nimport \"fmt\"\n\nfunc main() {\n    fmt.Println(\"Hello, Go!\")\n}" },
								{ name = "C# (.cs)", ext = "cs", template = "using System;\n\nclass Program\n{\n    static void Main()\n    {\n        Console.WriteLine(\"Hello, C#!\");\n    }\n}" },
								{ name = "Shell (.sh)", ext = "sh", template = "#!/bin/bash\necho \"Hello, Shell!\"" },
							}

							pickers.new({}, {
								prompt_title = "󰗀 Select Programming Language",
								finder = finders.new_table({
									results = filetypes,
									entry_maker = function(entry)
										return {
											value = entry,
											display = entry.name,
											ordinal = entry.name,
										}
									end,
								}),
								sorter = conf.generic_sorter({}),
								attach_mappings = function(prompt_bufnr, map)
									actions.select_default:replace(function()
										local selection = action_state.get_selected_entry()
										actions.close(prompt_bufnr)
										if selection then
											local ft = selection.value
											local date = os.date("%Y-%m-%d")
											local time = os.date("%H-%M")
											local filename = string.format("playground-%s-%s.%s", date, time, ft.ext)
											local scratch_dir = vim.fn.expand("~/.local/share/nvim/scratch")
											vim.fn.mkdir(scratch_dir, "p")
											local filepath = scratch_dir .. "/" .. filename
											vim.cmd("edit " .. filepath)
											-- Add template code
											if ft.template then
												local lines = vim.split(ft.template, "\n")
												vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
											end
											-- Set cursor at the end of the template
											local line_count = vim.api.nvim_buf_line_count(0)
											vim.api.nvim_win_set_cursor(0, { line_count, 0 })
										end
									end)
									return true
								end,
							}):find()
						end,
						icon = "󰗀",
					},
				}

				-- Create the main picker
				pickers.new({}, {
					prompt_title = "󱓞 Scratch Files Manager",
					finder = finders.new_table({
						results = scratch_commands,
						entry_maker = function(entry)
							return {
								value = entry,
								display = entry.name,
								ordinal = entry.name .. " " .. entry.desc,
							}
						end,
					}),
					sorter = conf.generic_sorter({}),
					previewer = require("telescope.previewers").new_buffer_previewer({
						title = "Command Info",
						define_preview = function(self, entry)
							local lines = {
								"Command: " .. (type(entry.value.cmd) == "string" and entry.value.cmd or "Custom Function"),
								"",
								"Description:",
								entry.value.desc,
								"",
								"Icon: " .. entry.value.icon,
							}
							vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
							vim.bo[self.state.bufnr].filetype = "markdown"
						end,
					}),
					attach_mappings = function(prompt_bufnr, map)
						-- Standard Esc and q mappings for consistent behavior
						map("i", "<Esc>", actions.close)
						map("n", "<Esc>", actions.close)
						map("n", "q", actions.close)

						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								local command = selection.value.cmd
								if type(command) == "string" then
									-- Execute vim command
									vim.cmd(command)
								elseif type(command) == "function" then
									-- Execute lua function
									command()
								end
							end
						end)
						return true
					end,
				}):find()
			end

			-- Set up the main keymap
			vim.keymap.set("n", "<leader>sc", scratch_telescope_picker, {
				desc = "Open Scratch Files Manager",
				silent = true,
			})

			-- Additional convenient keymaps for direct access
			vim.keymap.set("n", "<leader>sn", "<cmd>Scratch<cr>", {
				desc = "Create new scratch file",
				silent = true,
			})

			vim.keymap.set("n", "<leader>so", "<cmd>ScratchOpen<cr>", {
				desc = "Open existing scratch file",
				silent = true,
			})

			vim.keymap.set("n", "<leader>sf", "<cmd>ScratchOpenFzf<cr>", {
				desc = "Search scratch files content",
				silent = true,
			})
		end,
	},
}
