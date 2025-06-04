local theme_opts = {
	styles = {
		type = { bold = true },
		lsp = { underline = false },
		match_paren = { underline = true },
	},
}

local function config_theme()
	local plugin = require("no-clown-fiesta")
	plugin.setup(theme_opts)
	return plugin.load()
end
return {
	-- Colorscheme
	{
		"aktersnurra/no-clown-fiesta.nvim",
		priority = 1000,
		config = config_theme,
    lazy = false
	},

	-- Status line
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local lualine = require("lualine")
			local lazy_status = require("lazy.status") -- to configure lazy pending updates count

			local colors = {
				blue = "#65D1FF",
				green = "#3EFFDC",
				violet = "#FF61EF",
				yellow = "#FFDA7B",
				red = "#FF4A4A",
				fg = "#c3ccdc",
				bg = "#112638",
				inactive_bg = "#2c3043",
			}

			local my_lualine_theme = {
				normal = {
					a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
					b = { bg = colors.bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.fg },
				},
				insert = {
					a = { bg = colors.green, fg = colors.bg, gui = "bold" },
					b = { bg = colors.bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.fg },
				},
				visual = {
					a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
					b = { bg = colors.bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.fg },
				},
				command = {
					a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
					b = { bg = colors.bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.fg },
				},
				replace = {
					a = { bg = colors.red, fg = colors.bg, gui = "bold" },
					b = { bg = colors.bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.fg },
				},
				inactive = {
					a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
					b = { bg = colors.inactive_bg, fg = colors.semilightgray },
					c = { bg = colors.inactive_bg, fg = colors.semilightgray },
				},
			}

			-- configure lualine with modified theme
			lualine.setup({
				options = {
					theme = my_lualine_theme,
				},
				sections = {
					lualine_x = {
						{
							lazy_status.updates,
							cond = lazy_status.has_updates,
							color = { fg = "#ff9e64" },
						},
						{ "encoding" },
						{ "fileformat" },
						{ "filetype" },
					},
				},
			})
		end,
	},
	-- Highlight yanked text
	{
		"machakann/vim-highlightedyank",
		event = "VeryLazy",
	},

	-- Indentation guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},

	-- Better UI elements
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
		},
	},

	-- Telescope symbols (replaces symbols-outline with beautiful telescope UI)
	-- Features:
	-- - ⌘+O: Document symbols with hierarchical ordering
	-- - ⌘+Shift+O: Workspace symbols
	-- - Ctrl+F: Filter by symbol type (Class, Method, Function, etc.)
	-- - Ctrl+H: Toggle between hierarchical and flat view
	-- - Beautiful Nerd Font icons for all symbol types
	-- - Maintains document order while preserving hierarchy
	-- - Live preview and fuzzy search
	-- - Shows symbol counts in filter menu
	{
		"nvim-telescope/telescope.nvim",
		keys = {
			{
				"<D-o>",
				function()
					local custom_symbols = require("telescope.builtin").lsp_document_symbols

					-- Create advanced symbol picker with hierarchical document order
					local function ordered_symbols_picker()
						local finders = require("telescope.finders")
						local make_entry = require("telescope.make_entry")
						local pickers = require("telescope.pickers")
						local conf = require("telescope.config").values
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						-- LSP Symbol kinds mapping with beautiful icons
						local symbol_icons = {
							[1] = { icon = "󰈙", name = "File" },
							[2] = { icon = "󰆧", name = "Module" },
							[3] = { icon = "󰌗", name = "Namespace" },
							[4] = { icon = "󰏖", name = "Package" },
							[5] = { icon = "󰌗", name = "Class" },
							[6] = { icon = "󰆧", name = "Method" },
							[7] = { icon = "󰜢", name = "Property" },
							[8] = { icon = "󰜢", name = "Field" },
							[9] = { icon = "", name = "Constructor" },
							[10] = { icon = "", name = "Enum" },
							[11] = { icon = "", name = "Interface" },
							[12] = { icon = "󰊕", name = "Function" },
							[13] = { icon = "󰀫", name = "Variable" },
							[14] = { icon = "󰏿", name = "Constant" },
							[15] = { icon = "󰀬", name = "String" },
							[16] = { icon = "󰎠", name = "Number" },
							[17] = { icon = "◩", name = "Boolean" },
							[18] = { icon = "󰅪", name = "Array" },
							[19] = { icon = "󰅩", name = "Object" },
							[20] = { icon = "󰌋", name = "Key" },
							[21] = { icon = "󰟢", name = "Null" },
							[22] = { icon = "", name = "EnumMember" },
							[23] = { icon = "󰌗", name = "Struct" },
							[24] = { icon = "", name = "Event" },
							[25] = { icon = "󰆕", name = "Operator" },
							[26] = { icon = "󰊄", name = "TypeParameter" },
						}

						-- Check if LSP is available
						local clients = vim.lsp.get_active_clients({ bufnr = 0 })
						if #clients == 0 then
							vim.notify("No active LSP clients found", vim.log.levels.WARN)
							return
						end

						-- Get LSP symbols
						local params = { textDocument = vim.lsp.util.make_text_document_params() }
						local results_lsp = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 3000)

						if not results_lsp or vim.tbl_isempty(results_lsp) then
							vim.notify("No LSP symbols found", vim.log.levels.WARN)
							return
						end

						-- Process symbols maintaining strict document order
						local symbols = {}
						local function process_symbols(syms, level, prefix_order)
							level = level or 0
							prefix_order = prefix_order or ""

							-- Sort symbols at current level by line number ONLY
							local sorted_syms = vim.deepcopy(syms)
							table.sort(sorted_syms, function(a, b)
								local line_a = 0
								local line_b = 0

								if a.location and a.location.range then
									line_a = a.location.range.start.line
								elseif a.selectionRange then
									line_a = a.selectionRange.start.line
								elseif a.range then
									line_a = a.range.start.line
								end

								if b.location and b.location.range then
									line_b = b.location.range.start.line
								elseif b.selectionRange then
									line_b = b.selectionRange.start.line
								elseif b.range then
									line_b = b.range.start.line
								end

								return line_a < line_b
							end)

							for i, symbol in ipairs(sorted_syms) do
								local kind = symbol.kind or symbol.symbolKind or 1
								local icon_info = symbol_icons[kind] or { icon = "", name = "Unknown" }

								-- Create proper indentation for hierarchy
								local indent = string.rep("  ", level)

								-- Get line number for ordering
								local line = 0
								if symbol.location and symbol.location.range then
									line = symbol.location.range.start.line
								elseif symbol.selectionRange then
									line = symbol.selectionRange.start.line
								elseif symbol.range then
									line = symbol.range.start.line
								end

								-- Create strict document order key
								local order_key = prefix_order .. string.format("%06d", line)

								table.insert(symbols, {
									symbol = symbol,
									kind = kind,
									icon = icon_info.icon,
									type_name = icon_info.name,
									name = symbol.name,
									indent = indent,
									level = level,
									line = line,
									order_key = order_key,
									document_order = #symbols + 1, -- Track insertion order
								})

								-- Process children recursively with enhanced ordering
								if symbol.children and #symbol.children > 0 then
									process_symbols(symbol.children, level + 1, order_key .. "_")
								end
							end
						end

						-- Process all symbols from all LSP clients
						for client_id, response in pairs(results_lsp) do
							if response.result then
								process_symbols(response.result)
							end
						end

						-- Ensure symbols are in strict document order
						table.sort(symbols, function(a, b)
							return a.document_order < b.document_order
						end)

						if vim.tbl_isempty(symbols) then
							vim.notify("No symbols found in current buffer", vim.log.levels.WARN)
							return
						end

						-- Function to create entry with proper display format
						local function make_symbol_entry(entry)
							return {
								value = entry,
								display = string.format("%s%s %s", entry.indent, entry.icon, entry.name),
								ordinal = entry.name .. " " .. entry.type_name,
								symbol = entry.symbol,
								kind = entry.kind,
								type_name = entry.type_name,
								filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t"),
								lnum = entry.line + 1,
								col = 1,
							}
						end

						-- Track current view state
						local current_filter = "All"
						local is_hierarchical = true

						-- Create advanced picker with enhanced filtering
						pickers
							.new({}, {
								prompt_title = "󰘦 Document Symbols (Document Order) - " .. current_filter,
								finder = finders.new_table({
									results = symbols,
									entry_maker = make_symbol_entry,
								}),
								sorter = conf.generic_sorter({}),
								previewer = conf.grep_previewer({}),
								attach_mappings = function(prompt_bufnr, map)
									-- Enhanced filter by symbol type with exclusive filtering
									map("i", "<C-f>", function()
										local current_picker = action_state.get_current_picker(prompt_bufnr)

										-- Calculate symbol type counts
										local type_counts = {}
										for _, sym in ipairs(symbols) do
											type_counts[sym.type_name] = (type_counts[sym.type_name] or 0) + 1
										end

										-- Create ordered type options with icons and counts
										local type_options = {
											{name = "All", count = #symbols, icon = "󰒺"}
										}

										local ordered_types = {
											{name = "Class", icon = "󰌗"},
											{name = "Interface", icon = ""},
											{name = "Enum", icon = ""},
											{name = "Function", icon = "󰊕"},
											{name = "Method", icon = "󰆧"},
											{name = "Constructor", icon = ""},
											{name = "Property", icon = "󰜢"},
											{name = "Field", icon = "󰜢"},
											{name = "Variable", icon = "󰀫"},
											{name = "Constant", icon = "󰏿"},
											{name = "Module", icon = "󰆧"},
											{name = "Namespace", icon = "󰌗"},
										}

										for _, type_info in ipairs(ordered_types) do
											if type_counts[type_info.name] then
												table.insert(type_options, {
													name = type_info.name,
													count = type_counts[type_info.name],
													icon = type_info.icon
												})
											end
										end

										vim.ui.select(type_options, {
											prompt = "Filter symbols by type (exclusive):",
											format_item = function(item)
												return string.format("%s %s (%d)", item.icon, item.name, item.count)
											end
										}, function(choice)
											if not choice then return end

											current_filter = choice.name

											if choice.name == "All" then
												-- Show all symbols in document order
												current_picker:refresh(finders.new_table({
													results = symbols,
													entry_maker = make_symbol_entry,
												}), { reset_prompt = false })
												current_picker:change_prompt_title("󰘦 Document Symbols (Document Order) - All")
											else
												-- Filter symbols by exact type match, maintaining document order
												local filtered = {}
												for _, sym in ipairs(symbols) do
													if sym.type_name == choice.name then
														table.insert(filtered, sym)
													end
												end

												if #filtered == 0 then
													vim.notify("No " .. choice.name .. " symbols found", vim.log.levels.INFO)
													return
												end

												current_picker:refresh(finders.new_table({
													results = filtered,
													entry_maker = make_symbol_entry,
												}), { reset_prompt = false })
												current_picker:change_prompt_title("󰘦 Document Symbols (Document Order) - " .. choice.name .. " (" .. #filtered .. ")")
											end
										end)
									end)

									-- Enhanced toggle between hierarchical and flat view
									map("i", "<C-h>", function()
										local current_picker = action_state.get_current_picker(prompt_bufnr)

										is_hierarchical = not is_hierarchical

										if is_hierarchical then
											-- Hierarchical view - keep indentation
											local results_to_show = symbols
											if current_filter ~= "All" then
												results_to_show = vim.tbl_filter(function(sym)
													return sym.type_name == current_filter
												end, symbols)
											end

											current_picker:refresh(finders.new_table({
												results = results_to_show,
												entry_maker = make_symbol_entry,
											}), { reset_prompt = false })

											local title_suffix = current_filter == "All" and "All" or current_filter .. " (" .. #results_to_show .. ")"
											current_picker:change_prompt_title("󰘦 Document Symbols (Hierarchical) - " .. title_suffix)
										else
											-- Flat view - remove indentation, pure line order
											local flat_symbols = vim.deepcopy(symbols)
											for _, sym in ipairs(flat_symbols) do
												sym.indent = ""  -- Remove indentation for flat view
											end

											-- Filter if needed
											local results_to_show = flat_symbols
											if current_filter ~= "All" then
												results_to_show = vim.tbl_filter(function(sym)
													return sym.type_name == current_filter
												end, flat_symbols)
											end

											current_picker:refresh(finders.new_table({
												results = results_to_show,
												entry_maker = make_symbol_entry,
											}), { reset_prompt = false })

											local title_suffix = current_filter == "All" and "All" or current_filter .. " (" .. #results_to_show .. ")"
											current_picker:change_prompt_title("󰘦 Document Symbols (Flat) - " .. title_suffix)
										end
									end)

									-- Enhanced default action with better visual feedback
									actions.select_default:replace(function()
										local selection = action_state.get_selected_entry()
										actions.close(prompt_bufnr)

										if selection and selection.symbol then
											local symbol = selection.symbol
											local range = symbol.location and symbol.location.range
											           or symbol.selectionRange
											           or symbol.range

											if range then
												-- Jump to symbol location with precise positioning
												local line = range.start.line + 1
												local col = range.start.character

												vim.api.nvim_win_set_cursor(0, { line, col })
												vim.cmd("normal! zz") -- Center the line

												-- Enhanced visual feedback
												if vim.fn.has('nvim-0.9') == 1 then
													-- Brief highlight of the jumped-to symbol
													vim.cmd("normal! ^")
													local ns_id = vim.api.nvim_create_namespace("symbol_jump")
													vim.api.nvim_buf_add_highlight(0, ns_id, "Search", line - 1, 0, -1)
													vim.defer_fn(function()
														vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
													end, 150)
												end

												-- Show symbol info
												vim.notify(string.format("Jumped to %s: %s (line %d)",
													selection.type_name, selection.value.name, line),
													vim.log.levels.INFO)
											end
										end
									end)

									return true
								end,
							})
							:find()
					end

					ordered_symbols_picker()
				end,
				desc = "Document Symbols (Hierarchical + Filterable)",
			},
			{
				"<D-S-o>",
				function()
					require("telescope.builtin").lsp_workspace_symbols({
						symbol_width = 50,
						symbol_type_width = 15,
						show_line = true,
						previewer = true,
					})
				end,
				desc = "Workspace Symbols (Telescope)",
			},
		},
	},

	-- Tmux Tab Navigator
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
			"TmuxNavigatorProcessList",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},

	{
		"szw/vim-maximizer",
	},

	-- Mini.icons for better which-key icon support
	{
		"echasnovski/mini.icons",
		version = false,
		config = true,
	},

	-- Show keys
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 500
		end,
		config = function()
			local wk = require("which-key")

			wk.setup({
				plugins = {
					marks = true,
					registers = true,
					presets = {
						operators = false,
						motions = false,
						text_objects = false,
						windows = false,
						nav = false,
						z = false,
						g = false,
					},
				},
				icons = {
					breadcrumb = "»",
					separator = "➜",
					group = "+",
				},
				layout = {
					height = { min = 4, max = 25 },
					width = { min = 20, max = 50 },
					spacing = 3,
					align = "left",
				},
				show_help = true,
			})

			-- Register all the key groups
			wk.add({
				-- { '<leader>b', group = 'Bookmarks' },
				{ "<leader>d", group = "Diagnostics/Debug" },
				{ "<leader>f", group = "File/Find" },
				{ "<leader>g", group = "Git/Goto" },
				{ "<leader>h", group = "Hunks/Help" },
				{ "<leader>i", group = "Info" },
				{ "<leader>m", group = "Bookmarks" },
				{ "<leader>n", group = "Navigation" },
				{ "<leader>r", group = "Rename/Refactor" },
				{ "<leader>s", group = "Split" },
				{ "<leader>t", group = "Terminal/Tabs" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>x", group = "Diagnostics" },
				{ "g", group = "Goto" },
			})
		end,
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show()
				end,
				desc = "Show keymaps",
			},
		},
	},

	-- Add nvim-notify for notification support
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		config = function()
			require("notify").setup({
				background_colour = "#000000",
				timeout = 3000,
				max_width = 80,
				level = vim.log.levels.ERROR,
			})
		end,
	},
}
