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
					width = 45,
					relativenumber = true,
					side = "right",
				},
				-- Enhanced icons with Catppuccin-style aesthetics
				renderer = {
					indent_markers = {
						enable = true,
						inline_arrows = true,
						icons = {
							corner = "└",
							edge = "│",
							item = "│",
							bottom = "─",
							none = " ",
						},
					},
					root_folder_label = ":~:s?$?/..?",
					highlight_git = "icon",
					highlight_diagnostics = "icon",
					highlight_opened_files = "icon",
					highlight_modified = "icon",
					icons = {
						web_devicons = {
							file = {
								enable = true,
								color = true,
							},
							folder = {
								enable = false,
								color = true,
							},
						},
						git_placement = "before",
						modified_placement = "after",
						diagnostics_placement = "signcolumn",
						bookmarks_placement = "signcolumn",
						padding = " ",
						symlink_arrow = " ➛ ",
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = true,
							modified = true,
							diagnostics = true,
							bookmarks = true,
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
								unstaged = "󰄱",     -- Modified files (yellow)
								staged = "󰱒",       -- Staged files (green)
								unmerged = "󰘬",     -- Merge conflicts (red)
								renamed = "󰑕",      -- Renamed files (blue)
								untracked = "󰋖",    -- New files (green)
								deleted = "󰍴",      -- Deleted files (red)
								ignored = "󰿠",      -- Ignored files (gray)
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
				on_attach = function(bufnr)
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
					vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
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
					vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
					vim.keymap.set("n", "O", api.node.open.no_window_picker, opts("Open: No Window Picker"))
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
						horizontal = {
							width = 0.98,
							height = 0.8,
							preview_width = 0.5,
							prompt_position = "top"
						},
					},
					sorting_strategy = "ascending",
					borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
					prompt_prefix = " > ",
					selection_caret = " > ",
					path_display = { "smart" },
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous, -- move to prev result
							["<C-j>"] = actions.move_selection_next, -- move to next result
							["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
							["<C-t>"] = trouble_telescope.open,
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

			-- Custom function to show all files with priority for recently opened ones
			local function find_files_with_priority()
				require("telescope").extensions.frecency.frecency({
					workspace = "CWD",
					path_display = { "smart" },
					previewer = true,
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							width = 0.98,
							height = 0.8,
							preview_width = 0.5,
							prompt_position = "top"
						},
					},
					sorting_strategy = "ascending",
					prompt_prefix = " > ",
					selection_caret = " > ",
				})
			end

			-- set keymaps
			local keymap = vim.keymap -- for conciseness
			local builtin = require("telescope.builtin")
			keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
			keymap.set("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
			keymap.set("n", "<D-p>", builtin.find_files, { desc = "Fuzzy find files in cwd" })
			-- keymap.set("n", "<D-p>", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
			-- keymap.set("n", "<D-S-p>", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
			keymap.set("n", "<leader>fp", function()
				find_files_with_priority()
			end, { desc = "Find files with priority for recent" })
			keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
			keymap.set(
				"n",
				"<leader>fc",
				"<cmd>Telescope grep_string<cr>",
				{ desc = "Find string under cursor in cwd" }
			)
			keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })

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
						return true
					end,
				}):find()
			end, { desc = "Find bookmark annotations" })

			-- Additional Telescope mappings (converted from FZF)
			keymap.set("n", "<leader>fj", "<cmd>Telescope jumplist<cr>", { desc = "Find jumps" })
			keymap.set("n", "<leader>fm", "<cmd>Telescope marks<cr>", { desc = "Find marks" })
			keymap.set("n", "<leader>fw", "<cmd>Telescope windows<cr>", { desc = "Find windows" })
			keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help tags" })
			keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
			keymap.set(
				"n",
				"<leader>fl",
				"<cmd>Telescope current_buffer_fuzzy_find<cr>",
				{ desc = "Find in current buffer" }
			)
			keymap.set("n", "<leader>fC", "<cmd>Telescope command_history<cr>", { desc = "Find command history" })

			-- LSP symbols with telescope
			keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Find document symbols" })
			keymap.set("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", { desc = "Find workspace symbols" })
			keymap.set("n", "<leader>fi", "<cmd>Telescope lsp_implementations<cr>", { desc = "Find implementations" })
			keymap.set("n", "<leader>fr", "<cmd>Telescope lsp_references<cr>", { desc = "Find references" })

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
		keys = {
			{
				"<leader>a1",
				function()
					require("harpoon.mark").add_file()
				end,
				desc = "Add to Harpoon",
			},
			{
				"<leader>h",
				function()
					require("harpoon.ui").toggle_quick_menu()
				end,
				desc = "Harpoon Menu",
			},
			{
				"<leader>1",
				function()
					require("harpoon.ui").nav_file(1)
				end,
				desc = "Harpoon 1",
			},
			{
				"<leader>2",
				function()
					require("harpoon.ui").nav_file(2)
				end,
				desc = "Harpoon 2",
			},
			{
				"<leader>3",
				function()
					require("harpoon.ui").nav_file(3)
				end,
				desc = "Harpoon 3",
			},
			{
				"<leader>4",
				function()
					require("harpoon.ui").nav_file(4)
				end,
				desc = "Harpoon 4",
			},
			{
				"<leader>5",
				function()
					require("harpoon.ui").nav_file(5)
				end,
				desc = "Harpoon 5",
			},
			{
				"<leader>aa",
				function()
					require("harpoon.mark").add_file()
				end,
				desc = "Add to Harpoon",
			},
		},
	},

	-- Surround text
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		opts = {},
	},

	-- Terminal integration
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{ "<leader>t", ":ToggleTerm<CR>", desc = "Toggle terminal" },
		},
		opts = {
			size = 20,
			open_mapping = [[<leader>t]],
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
			float_opts = {
				border = "curved",
				winblend = 0,
				highlights = {
					border = "Normal",
					background = "Normal",
				},
			},
		},
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

				map("n", "<leader>hd", gs.diffthis, "Diff this")
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, "Diff this ~")

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
			end,
		},
	},
	-- nio is required by dap
	{ "nvim-neotest/nvim-nio" }, -- To Do Comment

	-- Bookmarks plugin moved to lua/plugins/bookmarks.lua

	{
		"folke/todo-comments.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local todo_comments = require("todo-comments")

			-- set keymaps
			local keymap = vim.keymap -- for conciseness

			-- Todo navigation with [ and ] were causing navigation delays
			-- Original: keymap.set("n", "]t", function() todo_comments.jump_next() end, { desc = "Next todo comment" })
			-- Original: keymap.set("n", "[t", function() todo_comments.jump_prev() end, { desc = "Previous todo comment" })
			keymap.set("n", "<leader>tj", function()
				todo_comments.jump_next()
			end, { desc = "Next todo comment" })

			keymap.set("n", "<leader>tk", function()
				todo_comments.jump_prev()
			end, { desc = "Previous todo comment" })

			todo_comments.setup()
		end,
	},
}
