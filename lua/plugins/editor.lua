return {
	-- OIL
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			CustomOilBar = function()
				local path = vim.fn.expand("%")
				path = path:gsub("oil://", "")

				return "  " .. vim.fn.fnamemodify(path, ":.")
			end

			require("oil").setup({
				columns = {
					"icon",
					"permissions",
					"size",
					"mtime",
				},
				keymaps = {
					["<C-h>"] = false,
					["<C-l>"] = false,
					["<C-k>"] = false,
					["<C-j>"] = false,
					["<M-h>"] = "actions.select_split",

					-- Backspace key (Delete on Mac) to navigate to parent directory
					["<BS>"] = "actions.parent",

					-- Add binding to go back to previous buffer when in oil
					["<C-o>"] = "actions.close",
				},
				win_options = {
					winbar = "%{v:lua.CustomOilBar()}",
				},
				view_options = {
					show_hidden = true, -- Show dotfiles like .gitignore, unless listed below

					is_always_hidden = function(name, _)
						-- List of files or folders to always hide
						local hidden_names = {
							".DS_Store",
							"dev-tools.locks",
							"dune.lock",
							"_build",
							"node_modules",
							"target",
							".git",
						}

						-- Hide anything exactly matching these names
						if vim.tbl_contains(hidden_names, name) then
							return true
						end

						-- Optional: hide files with certain suffixes (like lockfiles)
						local suffixes_to_hide = {
							".lock",
							".tmp",
						}
						for _, suffix in ipairs(suffixes_to_hide) do
							if name:sub(-#suffix) == suffix then
								return true
							end
						end

						-- Optional: hide files/folders with a prefix (like `.`)
						local prefixes_to_hide = {
							".cache",
						}
						for _, prefix in ipairs(prefixes_to_hide) do
							if name:sub(1, #prefix) == prefix then
								return true
							end
						end

						return false
					end,
				},
			})

			-- Open parent directory in current window
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

			-- Open parent directory in floating window
			vim.keymap.set("n", "<space>-", require("oil").toggle_float)
		end,
	},
	-- File explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			local nvimtree = require("nvim-tree")

			-- recommended settings from nvim-tree documentation
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1

			nvimtree.setup({
				view = {
					width = 40,
					relativenumber = false,
					number = false,
					signcolumn = "no",
					side = "right",
				},
				-- Enhanced icons with Catppuccin-style aesthetics
				renderer = {
					add_trailing = false,
					group_empty = true,
					highlight_git = "icon",
					full_name = false,
					highlight_opened_files = "icon",
					highlight_modified = "none",
					highlight_clipboard = "none",
					root_folder_modifier = ":t",
					indent_width = 1,
					indent_markers = {
						enable = false,
					},
					icons = {
						webdev_colors = true,
						git_placement = "after",
						modified_placement = "after",
						padding = "",
						symlink_arrow = "→",
						show = {
							file = true,
							folder = false,
							folder_arrow = true,
							git = true,
							modified = false,
							diagnostics = false,
							bookmarks = false,
						},
						glyphs = {
							default = "󰈔",
							symlink = "󰌷",
							bookmark = "󰆤",
							modified = "●",
							hidden = "󰜌",
							folder = {
								arrow_closed = "󰅂", -- Catppuccin chevron right
								arrow_open = "󰅀",   -- Catppuccin chevron down
								default = "󰉋",      -- Folder icon
								open = "󰝰",         -- Open folder
								empty = "󰉖",        -- Empty folder
								empty_open = "󰷏",   -- Empty open folder
								symlink = "󰉒",      -- Symlinked folder
								symlink_open = "󰉒", -- Open symlinked folder
							},
							git = {
								unstaged = "✗",
								staged = "✓",
								unmerged = "≠",
								renamed = "→",
								untracked = "?",
								deleted = "✖",
								ignored = "◌",
							},
						},
					},
				},
				-- disable window_picker for
				-- explorer to work well with
				-- window splits
				actions = {
					open_file = {
						window_picker = {
							enable = false,
						},
					},
				},
				filters = {
					custom = { ".DS_Store" },
				},
				git = {
					ignore = false,
				},
				live_filter = {
					prefix = "[FILTER]: ",
					always_show_folders = false,
				},
				-- Custom window options for smaller font
				on_attach = function(bufnr)
					-- Set smaller font size for nvim-tree window (30% smaller)
					vim.api.nvim_create_autocmd("BufWinEnter", {
						buffer = bufnr,
						callback = function()
							local win = vim.fn.bufwinid(bufnr)
							if win ~= -1 then
								-- Get current global font size
								local current_font = vim.o.guifont
								if current_font and current_font ~= "" then
									-- Extract size from font string (e.g., "Source Code Pro:h14" -> 14)
									local size = current_font:match(":h(%d+)")
									if size then
										local new_size = math.floor(tonumber(size) * 0.7) -- 30% smaller
										local new_font = current_font:gsub(":h%d+", ":h" .. new_size)
										vim.api.nvim_win_call(win, function()
											vim.opt_local.guifont = new_font
										end)
									end
								end
							end
						end,
					})

					local api = require("nvim-tree.api")

					local function opts(desc)
						return {
							desc = "nvim-tree: " .. desc,
							buffer = bufnr,
							noremap = true,
							silent = true,
							nowait = true,
						}
					end

					-- Apply default mappings except for Tab
					-- BEGIN_DEFAULT_ON_ATTACH
					vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
					vim.keymap.set("n", "<C-e>", api.node.open.replace_tree_buffer, opts("Open: In Place"))
					vim.keymap.set("n", "<C-k>", api.node.show_info_popup, opts("Info"))
					vim.keymap.set("n", "<C-r>", api.fs.rename_sub, opts("Rename: Omit Filename"))
					vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
					vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts("Open: Vertical Split"))
					vim.keymap.set("n", "<C-x>", api.node.open.horizontal, opts("Open: Horizontal Split"))
					vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))

					-- Custom Enter behavior: Open file and close nvim-tree
					vim.keymap.set("n", "<CR>", function()
						local node = api.tree.get_node_under_cursor()
						if node and node.type == "file" then
							-- Open the file
							api.node.open.edit()
							-- Close nvim-tree
							api.tree.close()
						else
							-- For directories, use default behavior (expand/collapse)
							api.node.open.edit()
						end
					end, opts("Open file and close tree"))

					-- vim.keymap.set("n", "<Tab>",          api.node.open.preview,              opts("Open Preview")) -- Disabled to use global Tab mapping
					vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
					vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
					vim.keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))
					vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("Up"))
					vim.keymap.set("n", "a", api.fs.create, opts("Create File Or Directory"))
					vim.keymap.set("n", "bd", api.marks.bulk.delete, opts("Delete Bookmarked"))
					vim.keymap.set("n", "bt", api.marks.bulk.trash, opts("Trash Bookmarked"))
					vim.keymap.set("n", "bmv", api.marks.bulk.move, opts("Move Bookmarked"))
					vim.keymap.set("n", "B", api.tree.toggle_no_buffer_filter, opts("Toggle Filter: No Buffer"))
					vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
					vim.keymap.set("n", "C", api.tree.toggle_git_clean_filter, opts("Toggle Filter: Git Clean"))
					-- Git navigation mappings with [ and ] were causing navigation delays
					-- Original: vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
					-- Original: vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("Next Git"))
					vim.keymap.set("n", "<leader>gc", api.node.navigate.git.prev, opts("Prev Git"))
					vim.keymap.set("n", "<leader>gC", api.node.navigate.git.next, opts("Next Git"))
					vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
					vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
					vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
					vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
					-- Diagnostic navigation mappings with [ and ] were causing navigation delays
					-- Original: vim.keymap.set("n", "]e", api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
					-- Original: vim.keymap.set("n", "[e", api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
					vim.keymap.set("n", "<leader>de", api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
					vim.keymap.set("n", "<leader>dE", api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
					vim.keymap.set("n", "F", api.live_filter.clear, opts("Live Filter: Clear"))
					vim.keymap.set("n", "f", api.live_filter.start, opts("Live Filter: Start"))
					vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
					vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
					vim.keymap.set("n", "ge", api.fs.copy.basename, opts("Copy Basename"))
					vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Filter: Dotfiles"))
					vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
					vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
					vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))
					vim.keymap.set("n", "L", api.node.open.toggle_group_empty, opts("Toggle Group Empty"))
					vim.keymap.set("n", "M", api.tree.toggle_no_bookmark_filter, opts("Toggle Filter: No Bookmark"))
					vim.keymap.set("n", "m", api.marks.toggle, opts("Toggle Bookmark"))

					-- Custom 'o' behavior: Open file, keep tree open and focused on tree
					vim.keymap.set("n", "o", function()
						local node = api.tree.get_node_under_cursor()
						if node and node.type == "file" then
							-- Open the file but don't change focus
							api.node.open.edit()
							-- Keep focus on nvim-tree by explicitly focusing it
							vim.defer_fn(function()
								-- Find nvim-tree window and focus it
								for _, win in ipairs(vim.api.nvim_list_wins()) do
									local buf = vim.api.nvim_win_get_buf(win)
									local buf_name = vim.api.nvim_buf_get_name(buf)
									if buf_name:match("NvimTree_") then
										vim.api.nvim_set_current_win(win)
										break
									end
								end
							end, 10)
						else
							-- For directories, use default behavior
							api.node.open.edit()
						end
					end, opts("Open file, keep tree open and focused"))

					-- Custom 'O' behavior: Open file, keep tree open but focus main buffer
					vim.keymap.set("n", "O", function()
						local node = api.tree.get_node_under_cursor()
						if node and node.type == "file" then
							-- Open the file and let focus go to the opened file (default behavior)
							api.node.open.edit()
						else
							-- For directories, use no_window_picker behavior
							api.node.open.no_window_picker()
						end
					end, opts("Open file, keep tree open, focus main buffer"))
					vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
					vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
					vim.keymap.set("n", "q", api.tree.close, opts("Close"))
					vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
					vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
					vim.keymap.set("n", "s", api.node.run.system, opts("Run System"))
					vim.keymap.set("n", "S", api.tree.search_node, opts("Search"))
					vim.keymap.set("n", "u", api.fs.rename_full, opts("Rename: Full Path"))
					vim.keymap.set("n", "U", api.tree.toggle_custom_filter, opts("Toggle Filter: Hidden"))
					vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse"))
					vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
					vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))
					vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("Copy Relative Path"))
					vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
					vim.keymap.set("n", "<2-RightMouse>", api.tree.change_root_to_node, opts("CD"))
					-- END_DEFAULT_ON_ATTACH

					-- Custom mapping: Use `/` for live filter instead of global search
					vim.keymap.set("n", "/", api.live_filter.start, opts("Live Filter: Start"))
					-- Custom mapping: Use `//` for clearing live filter
					vim.keymap.set("n", "//", api.live_filter.clear, opts("Live Filter: Clear"))
				end,
			})

			-- set keymaps
			local keymap = vim.keymap -- for conciseness

			keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
			keymap.set(
				"n",
				"<leader>ef",
				"<cmd>NvimTreeFindFileToggle<CR>",
				{ desc = "Toggle file explorer on current file" }
			) -- toggle file explorer on current file
			keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
			keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
		end,
	},

	-- Fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
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
						preview_width = 0.5,
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
							["<C-j>"] = actions.move_selection_next, -- move to next result
							["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
							["<C-t>"] = trouble_telescope.open,
							["<Esc>"] = actions.close, -- Single Esc to close telescope
						},
						n = {
							["<Esc>"] = actions.close, -- Single Esc to close telescope in normal mode
							["q"] = actions.close, -- q to close telescope in normal mode
						},
					},
				},
				extensions = {
					frecency = {
						show_scores = true,
						show_unindexed = true,
						ignore_patterns = { "*.git/*", "*/tmp/*" },
						disable_devicons = false,
						workspaces = {
							["conf"] = vim.fn.expand("~/.config"),
							["data"] = vim.fn.expand("~/.local/share"),
							["project"] = vim.fn.expand("~/Projects"),
							["nvim"] = vim.fn.expand("~/.config/nvim"),
						},
					},
				},
			})

			telescope.load_extension("fzf")
			telescope.load_extension("frecency")

			-- Load csharpls-extended telescope extension if available
			local has_csharpls_extended = pcall(require, "csharpls_extended")
			if has_csharpls_extended then
				telescope.load_extension("csharpls_definition")
			end

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
								vim.api.nvim_buf_call(self.state.bufnr, function()
									pcall(vim.api.nvim_win_set_cursor, self.state.winid, { entry.lnum, (entry.col or 1) - 1 })

									-- Clear any existing highlights
									vim.api.nvim_buf_clear_namespace(self.state.bufnr, -1, 0, -1)

									-- Function to apply highlighting
									local function apply_highlighting()
										-- Get the symbol name under cursor for LSP references
										local symbol_name = ""

										-- Try to get the current word/symbol at the reference location
										if entry.text then
											-- Extract the word around the column position
											local line_text = vim.api.nvim_buf_get_lines(self.state.bufnr, entry.lnum - 1, entry.lnum, false)[1] or ""
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
											local line_text = vim.api.nvim_buf_get_lines(self.state.bufnr, entry.lnum - 1, entry.lnum, false)[1] or ""
											local escaped_symbol = vim.pesc(symbol_name)

											-- Find all occurrences of the symbol in the line
											local start_pos = 1
											while true do
												local start_col, end_col = string.find(line_text, escaped_symbol, start_pos)
												if not start_col then break end

												vim.api.nvim_buf_add_highlight(
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
									apply_highlighting()

									-- Also schedule it to run after telescope is fully loaded
									vim.schedule(function()
										if vim.api.nvim_buf_is_valid(self.state.bufnr) then
											apply_highlighting()
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

				local config = vim.tbl_extend("force", opts, {
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
								vim.api.nvim_buf_call(self.state.bufnr, function()
									pcall(vim.api.nvim_win_set_cursor, self.state.winid, { entry.lnum, (entry.col or 1) - 1 })

									-- Clear any existing highlights
									vim.api.nvim_buf_clear_namespace(self.state.bufnr, -1, 0, -1)

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
											local line_text = vim.api.nvim_buf_get_lines(self.state.bufnr, entry.lnum - 1, entry.lnum, false)[1] or ""
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
											local line_text = vim.api.nvim_buf_get_lines(self.state.bufnr, entry.lnum - 1, entry.lnum, false)[1] or ""
											local escaped_query = vim.pesc(search_query)
											local start_col = string.find(line_text:lower(), escaped_query:lower())
											if start_col then
												vim.api.nvim_buf_add_highlight(
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
									apply_highlighting()

									-- Also schedule it to run after telescope is fully loaded
									vim.schedule(function()
										if vim.api.nvim_buf_is_valid(self.state.bufnr) then
											apply_highlighting()
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
			_G.telescope_lsp_references_with_dynamic_title = lsp_references_with_dynamic_title
			_G.telescope_live_grep_with_dynamic_title = live_grep_with_dynamic_title
			_G.telescope_oldfiles_with_dynamic_title = oldfiles_with_dynamic_title

			-- Custom function to show all files with priority for recently opened ones
			local function find_files_with_priority()
				require("telescope").extensions.frecency.frecency({
					workspace = "CWD",
					path_display = { "smart" },
					previewer = true,
					layout_strategy = "horizontal",
					layout_config = {
						width = 0.98,
						height = 0.8,
						preview_width = 0.5,
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

			keymap.set("n", "<leader>ff", telescope_with_esc(builtin.find_files), { desc = "Fuzzy find files in cwd" })
            keymap.set("n", "<D-S-p>", telescope_with_esc(builtin.find_files), { desc = "Fuzzy find files in cwd" })
			keymap.set("n", "<D-p>", function()
				-- Get current working directory
				local cwd = vim.fn.getcwd()

				-- Try to find git root first, fallback to cwd
				local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel")[1]
				local project_root = (vim.v.shell_error == 0 and git_root) or cwd

				_G.telescope_oldfiles_with_dynamic_title({
					cwd = project_root,
					initial_mode = "normal",
					-- Filter to only show files within the current project
					attach_mappings = function(prompt_bufnr, map_func)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						-- Override the default selection to ensure we stay within project
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							if selection then
								local file_path = selection.path or selection.value
								-- Only open if file is within project root
								if vim.startswith(file_path, project_root) then
									actions.close(prompt_bufnr)
									vim.cmd("edit " .. vim.fn.fnameescape(file_path))
								else
									vim.notify("File is outside current project", vim.log.levels.WARN)
								end
							end
						end)

						map_func("i", "<Esc>", actions.close)
						map_func("n", "<Esc>", actions.close)
						map_func("n", "q", actions.close)
						return true
					end,
				})
			end, { desc = "Fuzzy find recent files in project" })

			keymap.set("n", "<leader>fp", function()
				find_files_with_priority()
			end, { desc = "Find files with priority for recent" })
			keymap.set("n", "<leader>fs", telescope_with_esc(builtin.live_grep), { desc = "Find string in cwd" })
			keymap.set(
				"n",
				"<leader>fC",
				telescope_with_esc(builtin.grep_string),
				{ desc = "Find string under cursor in cwd" }
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

			-- Custom telescope picker for bookmark annotations only
			keymap.set("n", "<leader>fa", function()
				local builtin = require("telescope.builtin")
				local pickers = require("telescope.pickers")
				local finders = require("telescope.finders")
				local conf = require("telescope.config").values
				local actions = require("telescope.actions")
				local action_state = require("telescope.actions.state")

				-- Get bookmark annotations from the bookmarks plugin
				local bookmarks_ok, bookmarks = pcall(require, "bookmarks")
				if not bookmarks_ok then
					vim.notify("Bookmarks plugin not available", vim.log.levels.ERROR)
					return
				end

				local bookmark_list = bookmarks.bookmark_list()
				local annotated_bookmarks = {}

				if bookmark_list and type(bookmark_list) == "table" then
					for _, bookmark in ipairs(bookmark_list) do
						-- Only include bookmarks that have annotations
						if bookmark.annotation and bookmark.annotation ~= "" then
							-- Filter by current working directory
							local relative_path = vim.fn.fnamemodify(bookmark.filename, ":.")
							if vim.startswith(bookmark.filename, vim.fn.getcwd()) then
								table.insert(annotated_bookmarks, {
									filename = bookmark.filename,
									lnum = bookmark.line,
									col = 1,
									text = bookmark.annotation,
									display = string.format("%s:%d - %s", relative_path, bookmark.line, bookmark.annotation),
								})
							end
						end
					end
				end

				if #annotated_bookmarks == 0 then
					vim.notify("No bookmark annotations found in current project", vim.log.levels.INFO)
					return
				end

				-- Create telescope picker using the same configuration as other pickers
				pickers.new({}, {
					prompt_title = "♥ Find Bookmark Annotations",
					finder = finders.new_table({
						results = annotated_bookmarks,
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
							if selection then
								vim.cmd("edit " .. vim.fn.fnameescape(selection.filename))
								vim.api.nvim_win_set_cursor(0, {selection.lnum, selection.col})
							end
						end)
						-- Add proper Esc handling
						local map_func = vim.keymap.set
						map_func("i", "<Esc>", function() actions.close(prompt_bufnr) end, { buffer = true })
						map_func("n", "<Esc>", function() actions.close(prompt_bufnr) end, { buffer = true })
						map_func("n", "q", function() actions.close(prompt_bufnr) end, { buffer = true })
						return true
					end,
				}):find()
			end, { desc = "Find bookmark annotations" })

			-- Additional Telescope mappings (converted from FZF)
			keymap.set("n", "<leader>fh", telescope_with_esc(builtin.help_tags), { desc = "Find help tags" })
			keymap.set("n", "<leader>fj", telescope_with_esc(builtin.jumplist, {initial_mode = "normal"}), { desc = "Find jumps" })
			keymap.set("n", "<leader>fm", telescope_with_esc(builtin.marks ,{initial_mode = "normal"}), { desc = "Find marks" })
			keymap.set("n", "<leader>fb", function()
				-- Create a reusable function for buffer deletion
				local function create_buffer_picker()
					builtin.buffers({
						initial_mode = "normal",
						attach_mappings = function(prompt_bufnr, map_func)
							local actions = require("telescope.actions")
							local action_state = require("telescope.actions.state")

							-- Function to delete buffer with smart handling
							local function delete_buffer()
								local selection = action_state.get_selected_entry()
								if not selection then
									return
								end

								-- Get all listed buffers
								local all_buffers = vim.tbl_filter(function(buf)
									return vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted')
								end, vim.api.nvim_list_bufs())

								-- Don't delete if it's the only buffer left
								if #all_buffers <= 1 then
									vim.notify("Cannot delete the last buffer", vim.log.levels.WARN)
									return
								end

								local bufnr = selection.bufnr
								local bufname = vim.api.nvim_buf_get_name(bufnr)

								-- Check if buffer is modified
								if vim.api.nvim_buf_get_option(bufnr, 'modified') then
									-- Show confirmation dialog for modified buffer
									local filename = vim.fn.fnamemodify(bufname, ':t')
									if filename == '' then
										filename = '[No Name]'
									end

									local choice = vim.fn.confirm(
										string.format('Buffer "%s" has unsaved changes. Save before closing?', filename),
										'&Save\n&Discard\n&Cancel',
										1
									)

									if choice == 1 then -- Save
										-- Check if buffer has a filename
										if bufname == '' then
											-- For unnamed buffers, prompt for a filename
											vim.api.nvim_buf_call(bufnr, function()
												local save_name = vim.fn.input('Save as: ', '', 'file')
												if save_name ~= '' then
													vim.cmd('write ' .. vim.fn.fnameescape(save_name))
												else
													-- User cancelled save, abort deletion
													return
												end
											end)
										else
											-- Named buffer, save normally
											vim.api.nvim_buf_call(bufnr, function()
												vim.cmd('write')
											end)
										end
									elseif choice == 3 then -- Cancel
										return
									end
									-- choice == 2 means Discard, continue with deletion
								end

								-- Delete the buffer
								vim.api.nvim_buf_delete(bufnr, { force = true })

								-- Check how many buffers are left after deletion
								local remaining_buffers = vim.tbl_filter(function(buf)
									return vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted')
								end, vim.api.nvim_list_bufs())

								-- If only one buffer left, close telescope entirely
								if #remaining_buffers <= 1 then
									actions.close(prompt_bufnr)
									return
								end

								-- Otherwise, close and reopen buffer picker
								actions.close(prompt_bufnr)
								vim.schedule(create_buffer_picker)
							end

							-- Map x to delete buffer in normal mode
							map_func("n", "x", delete_buffer)

							-- Standard telescope mappings
							map_func("i", "<Esc>", actions.close)
							map_func("n", "<Esc>", actions.close)
							map_func("n", "q", actions.close)

							return true
						end,
					})
				end

				-- Start the buffer picker
				create_buffer_picker()
			end, { desc = "Find buffers" })
			keymap.set(
				"n",
				"<leader>fw",
				function()
					require("telescope.builtin").current_buffer_fuzzy_find({
						previewer = false,
						attach_mappings = function(prompt_bufnr, map_func)
							local actions = require("telescope.actions")
							map_func("i", "<Esc>", actions.close)
							map_func("n", "<Esc>", actions.close)
							map_func("n", "q", actions.close)
							return true
						end,
					})
				end,
				{ desc = "Find in current buffer (no preview)" }
			)
			keymap.set(
				"v",
				"<leader>fw",
				function()
					-- Get the selected text using vim.fn.getline and cursor positions
					local selected_text = ""

					-- Get current visual selection boundaries using vim.fn.getpos
					local start_pos = vim.fn.getpos("v")  -- Start of visual selection
					local end_pos = vim.fn.getpos(".")    -- Current cursor position (end of selection)

					local start_line = start_pos[2]
					local start_col = start_pos[3]
					local end_line = end_pos[2]
					local end_col = end_pos[3]

					-- Ensure start is before end
					if start_line > end_line or (start_line == end_line and start_col > end_col) then
						start_line, end_line = end_line, start_line
						start_col, end_col = end_col, start_col
					end

					-- Get the selected text
					if start_line == end_line then
						-- Single line selection
						local line = vim.fn.getline(start_line)
						selected_text = string.sub(line, start_col, end_col)
					else
						-- Multi-line selection
						local lines = {}
						for i = start_line, end_line do
							local line = vim.fn.getline(i)
							if i == start_line then
								line = string.sub(line, start_col)
							elseif i == end_line then
								line = string.sub(line, 1, end_col)
							end
							table.insert(lines, line)
						end
						selected_text = table.concat(lines, " ")
					end

					-- Clean up the selected text (remove extra whitespace)
					selected_text = selected_text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

					-- Escape the visual mode
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

					-- Use vim.schedule to ensure we're out of visual mode before opening telescope
					vim.schedule(function()
						require("telescope.builtin").current_buffer_fuzzy_find({
							previewer = true,
							default_text = selected_text,
							initial_mode = "normal",
							attach_mappings = function(prompt_bufnr, map_func)
								local actions = require("telescope.actions")
								map_func("i", "<Esc>", actions.close)
								map_func("n", "<Esc>", actions.close)
								map_func("n", "q", actions.close)
								return true
							end,
						})
					end)
				end,
				{ desc = "Find selected text in current buffer (no preview)" }
			)
			keymap.set("n", "<leader>fc", telescope_with_esc(builtin.command_history), { desc = "Find command history" })

			-- LSP symbols with telescope
			keymap.set("n", "<leader>fs", telescope_with_esc(builtin.lsp_document_symbols), { desc = "Find document symbols" })
			keymap.set("n", "<leader>fS", telescope_with_esc(builtin.lsp_workspace_symbols), { desc = "Find workspace symbols" })
			keymap.set("n", "<leader>fi", telescope_with_esc(builtin.lsp_implementations), { desc = "Find implementations" })
			keymap.set("n", "<leader>fr", telescope_with_esc(builtin.lsp_references), { desc = "Find references" })

			-- Enable line numbers in telescope preview windows
			vim.api.nvim_create_autocmd("User", {
				pattern = "TelescopePreviewerLoaded",
				callback = function()
					vim.opt_local.number = true
				end,
			})
		end,
	},

	-- Flash (EasyMotion replacement)
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"<leader>k",
				function()
					require("flash").jump()
				end,
				desc = "Flash Jump",
			},
			{
				"<leader>j",
				function()
					require("flash").jump({ search = { forward = true, wrap = false, multi_window = false } })
				end,
				desc = "Flash Forward",
			},
		},
	},

	-- Harpoon for quick file navigation
	{
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Surround text
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		opts = {},
	},

	-- Terminal integration with management system
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("toggleterm").setup({
				size = 20,
				hide_numbers = true,
				shade_filetypes = {},
				shade_terminals = true,
				shading_factor = 2,
				start_in_insert = true,
				insert_mappings = true,
				persist_size = true,
				direction = "float",
				close_on_exit = true,
				shell = vim.o.shell,
				auto_scroll = false, -- Disable auto-scroll to allow manual cursor control
				float_opts = {
					border = "curved",
					winblend = 0,
					highlights = {
						border = "Normal",
						background = "Normal",
					},
					width = math.floor(vim.o.columns * 0.85),
					height = math.floor(vim.o.lines * 0.85),
				},
			})

			-- Initialize terminal management system
			require("config.terminals").setup({
				terminal_size = 20,
				direction = "float",
				float_opts = {
					border = "curved",
					winblend = 0,
					width = math.floor(vim.o.columns * 0.85),
					height = math.floor(vim.o.lines * 0.85),
				},
			})
		end,
	},

	-- Trouble (diagnostics, references, etc.)
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
		opts = {
			focus = true,
		},
		cmd = "Trouble",
		keys = {
			{ "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
			{
				"<leader>xd",
				"<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
				desc = "Open trouble document diagnostics",
			},
			{ "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", desc = "Open trouble quickfix list" },
			{ "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Open trouble location list" },
			{ "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "Open todos in trouble" },
		},
	},
}
