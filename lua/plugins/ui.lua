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
							[1] = { icon = "󰈔", name = "File" },           -- File: Document icon
							[2] = { icon = "󰏖", name = "Module" },         -- Module: Package/box icon
							[3] = { icon = "󰌗", name = "Namespace" },      -- Namespace: Folder tree icon
							[4] = { icon = "󰏗", name = "Package" },        -- Package: Package icon
							[5] = { icon = "󰠱", name = "Class" },          -- Class: Class icon (distinct from namespace)
							[6] = { icon = "󰊕", name = "Method" },         -- Method: Function icon with different style
							[7] = { icon = "󰜢", name = "Property" },       -- Property: Property icon
							[8] = { icon = "󰓹", name = "Field" },          -- Field: Field/variable icon
							[9] = { icon = "󰆧", name = "Constructor" },    -- Constructor: Constructor icon
							[10] = { icon = "󰕘", name = "Enum" },          -- Enum: Enum icon
							[11] = { icon = "󰜰", name = "Interface" },     -- Interface: Interface icon
							[12] = { icon = "󰡱", name = "Function" },      -- Function: Lambda/function icon
							[13] = { icon = "󰀫", name = "Variable" },      -- Variable: Variable icon
							[14] = { icon = "󰏿", name = "Constant" },      -- Constant: Constant icon
							[15] = { icon = "󰀬", name = "String" },        -- String: String icon
							[16] = { icon = "󰎠", name = "Number" },        -- Number: Hash/number icon
							[17] = { icon = "󰨙", name = "Boolean" },       -- Boolean: Boolean icon
							[18] = { icon = "󰅪", name = "Array" },         -- Array: Array/list icon
							[19] = { icon = "󰅩", name = "Object" },        -- Object: Object/map icon
							[20] = { icon = "󰌋", name = "Key" },           -- Key: Key icon
							[21] = { icon = "󰟢", name = "Null" },          -- Null: Null/empty icon
							[22] = { icon = "󰕘", name = "EnumMember" },    -- EnumMember: Enum member icon
							[23] = { icon = "󰙅", name = "Struct" },        -- Struct: Struct icon (different from class)
							[24] = { icon = "󰉁", name = "Event" },         -- Event: Event/lightning icon
							[25] = { icon = "󰆕", name = "Operator" },      -- Operator: Operator icon
							[26] = { icon = "󰊄", name = "TypeParameter" }, -- TypeParameter: Generic type icon
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

						-- Function to create entry with proper display format and preview support
						local function make_symbol_entry(entry)
							-- Get the current buffer name for preview
							local bufnr = vim.api.nvim_get_current_buf()
							local filename = vim.api.nvim_buf_get_name(bufnr)

							return {
								value = entry,
								display = string.format("%s%s %s", entry.indent, entry.icon, entry.name),
								ordinal = entry.name .. " " .. entry.type_name,
								symbol = entry.symbol,
								kind = entry.kind,
								type_name = entry.type_name,
								filename = filename,
								lnum = entry.line + 1,
								col = 1,
								bufnr = bufnr,
								-- Add these fields for proper preview navigation
								path = filename,
								row = entry.line + 1,
								start = entry.line + 1,
							}
						end

						-- Create advanced picker with working preview
						pickers
							.new({}, {
								prompt_title = "󰘦 Document Symbols (Document Order)",
								finder = finders.new_table({
									results = symbols,
									entry_maker = make_symbol_entry,
								}),
								sorter = conf.generic_sorter({}),
								previewer = conf.grep_previewer({}), -- Use grep_previewer for line-aware preview
								attach_mappings = function(prompt_bufnr, map)
									-- Enhanced toggle between hierarchical and flat view
									map("i", "<C-h>", function()
										local current_picker = action_state.get_current_picker(prompt_bufnr)

										-- Toggle between hierarchical and flat view
										local flat_symbols = vim.deepcopy(symbols)
										for _, sym in ipairs(flat_symbols) do
											sym.indent = ""  -- Remove indentation for flat view
										end

										current_picker:refresh(finders.new_table({
											results = flat_symbols,
											entry_maker = make_symbol_entry,
										}), { reset_prompt = false })
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
				desc = "Document Symbols (Hierarchical)",
			},
			{
				"<D-S-o>", -- Cmd+Shift+O for filtering
				function()
					-- Create symbol type filter picker
					local function symbol_type_filter_picker()
						local finders = require("telescope.finders")
						local pickers = require("telescope.pickers")
						local conf = require("telescope.config").values
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						-- LSP Symbol kinds mapping
						local symbol_icons = {
							[1] = { icon = "󰈔", name = "File" },           -- File: Document icon
							[2] = { icon = "󰏖", name = "Module" },         -- Module: Package/box icon
							[3] = { icon = "󰌗", name = "Namespace" },      -- Namespace: Folder tree icon
							[4] = { icon = "󰏗", name = "Package" },        -- Package: Package icon
							[5] = { icon = "󰠱", name = "Class" },          -- Class: Class icon (distinct from namespace)
							[6] = { icon = "󰊕", name = "Method" },         -- Method: Function icon with different style
							[7] = { icon = "󰜢", name = "Property" },       -- Property: Property icon
							[8] = { icon = "󰓹", name = "Field" },          -- Field: Field/variable icon
							[9] = { icon = "󰆧", name = "Constructor" },    -- Constructor: Constructor icon
							[10] = { icon = "󰕘", name = "Enum" },          -- Enum: Enum icon
							[11] = { icon = "󰜰", name = "Interface" },     -- Interface: Interface icon
							[12] = { icon = "󰡱", name = "Function" },      -- Function: Lambda/function icon
							[13] = { icon = "󰀫", name = "Variable" },      -- Variable: Variable icon
							[14] = { icon = "󰏿", name = "Constant" },      -- Constant: Constant icon
							[15] = { icon = "󰀬", name = "String" },        -- String: String icon
							[16] = { icon = "󰎠", name = "Number" },        -- Number: Hash/number icon
							[17] = { icon = "󰨙", name = "Boolean" },       -- Boolean: Boolean icon
							[18] = { icon = "󰅪", name = "Array" },         -- Array: Array/list icon
							[19] = { icon = "󰅩", name = "Object" },        -- Object: Object/map icon
							[20] = { icon = "󰌋", name = "Key" },           -- Key: Key icon
							[21] = { icon = "󰟢", name = "Null" },          -- Null: Null/empty icon
							[22] = { icon = "󰕘", name = "EnumMember" },    -- EnumMember: Enum member icon
							[23] = { icon = "󰙅", name = "Struct" },        -- Struct: Struct icon (different from class)
							[24] = { icon = "󰉁", name = "Event" },         -- Event: Event/lightning icon
							[25] = { icon = "󰆕", name = "Operator" },      -- Operator: Operator icon
							[26] = { icon = "󰊄", name = "TypeParameter" }, -- TypeParameter: Generic type icon
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

						-- Process symbols maintaining document order
						local symbols = {}
						local function process_symbols(syms, level)
							level = level or 0

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

							for _, symbol in ipairs(sorted_syms) do
								local kind = symbol.kind or symbol.symbolKind or 1
								local icon_info = symbol_icons[kind] or { icon = "", name = "Unknown" }

								local line = 0
								if symbol.location and symbol.location.range then
									line = symbol.location.range.start.line
								elseif symbol.selectionRange then
									line = symbol.selectionRange.start.line
								elseif symbol.range then
									line = symbol.range.start.line
								end

								table.insert(symbols, {
									symbol = symbol,
									kind = kind,
									icon = icon_info.icon,
									type_name = icon_info.name,
									name = symbol.name,
									indent = string.rep("  ", level),
									line = line,
								})

								if symbol.children and #symbol.children > 0 then
									process_symbols(symbol.children, level + 1)
								end
							end
						end

						-- Process all symbols
						for client_id, response in pairs(results_lsp) do
							if response.result then
								process_symbols(response.result)
							end
						end

						if vim.tbl_isempty(symbols) then
							vim.notify("No symbols found in current buffer", vim.log.levels.WARN)
							return
						end

						-- Calculate symbol type counts
						local type_counts = {}
						for _, sym in ipairs(symbols) do
							type_counts[sym.type_name] = (type_counts[sym.type_name] or 0) + 1
						end

						-- Create filter options
						local type_options = {{ name = "All", count = #symbols, icon = "󰒺" }}
						local ordered_types = {
							{name = "Class", icon = "󰠱"},        -- Class: Class icon
							{name = "Interface", icon = "󰜰"},   -- Interface: Interface icon
							{name = "Enum", icon = "󰕘"},        -- Enum: Enum icon
							{name = "Function", icon = "󰡱"},    -- Function: Lambda/function icon
							{name = "Method", icon = "󰊕"},      -- Method: Function icon with different style
							{name = "Constructor", icon = "󰆧"}, -- Constructor: Constructor icon
							{name = "Property", icon = "󰜢"},    -- Property: Property icon
							{name = "Field", icon = "󰓹"},       -- Field: Field/variable icon
							{name = "Variable", icon = "󰀫"},    -- Variable: Variable icon
							{name = "Constant", icon = "󰏿"},    -- Constant: Constant icon
							{name = "Module", icon = "󰏖"},      -- Module: Package/box icon
							{name = "Namespace", icon = "󰌗"},   -- Namespace: Folder tree icon
							{name = "Struct", icon = "󰙅"},      -- Struct: Struct icon
							{name = "Event", icon = "󰉁"},       -- Event: Event/lightning icon
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

						-- Function to create symbol picker with filtered results
						local function create_filtered_picker(filter_type)
							local filtered_symbols = symbols
							if filter_type ~= "All" then
								filtered_symbols = vim.tbl_filter(function(sym)
									return sym.type_name == filter_type
								end, symbols)
							end

							local function make_symbol_entry(entry)
								-- Get the current buffer name for preview
								local bufnr = vim.api.nvim_get_current_buf()
								local filename = vim.api.nvim_buf_get_name(bufnr)

								return {
									value = entry,
									display = string.format("%s%s %s", entry.indent, entry.icon, entry.name),
									ordinal = entry.name .. " " .. entry.type_name,
									symbol = entry.symbol,
									kind = entry.kind,
									type_name = entry.type_name,
									filename = filename,
									lnum = entry.line + 1,
									col = 1,
									bufnr = bufnr,
									-- Add these fields for proper preview navigation
									path = filename,
									row = entry.line + 1,
									start = entry.line + 1,
								}
							end

							pickers.new({}, {
								prompt_title = "󰘦 Filtered Symbols - " .. filter_type .. " (" .. #filtered_symbols .. ")",
								finder = finders.new_table({
									results = filtered_symbols,
									entry_maker = make_symbol_entry,
								}),
								sorter = conf.generic_sorter({}),
								previewer = conf.grep_previewer({}), -- Use grep_previewer for line-aware preview
								attach_mappings = function(prompt_bufnr, map)
									actions.select_default:replace(function()
										local selection = action_state.get_selected_entry()
										actions.close(prompt_bufnr)

										if selection and selection.symbol then
											local symbol = selection.symbol
											local range = symbol.location and symbol.location.range
														   or symbol.selectionRange
														   or symbol.range

											if range then
												local line = range.start.line + 1
												local col = range.start.character

												vim.api.nvim_win_set_cursor(0, { line, col })
												vim.cmd("normal! zz")

												-- Visual feedback
												if vim.fn.has('nvim-0.9') == 1 then
													vim.cmd("normal! ^")
													local ns_id = vim.api.nvim_create_namespace("symbol_jump")
													vim.api.nvim_buf_add_highlight(0, ns_id, "Search", line - 1, 0, -1)
													vim.defer_fn(function()
														vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
													end, 150)
												end

												vim.notify(string.format("Jumped to %s: %s (line %d)",
													selection.type_name, selection.value.name, line),
													vim.log.levels.INFO)
											end
										end
									end)
									return true
								end,
							}):find()
						end

						-- Show type filter picker
						pickers.new({}, {
							prompt_title = "󰈺 Filter by Symbol Type",
							finder = finders.new_table({
								results = type_options,
								entry_maker = function(entry)
									return {
										value = entry,
										display = string.format("%s %s (%d)", entry.icon, entry.name, entry.count),
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
										create_filtered_picker(selection.value.name)
									end
								end)
								return true
							end,
						}):find()
					end

					symbol_type_filter_picker()
				end,
				desc = "Filter Document Symbols by Type",
			},
			{
				"<D-S-w>", -- Cmd+Shift+W for workspace symbols
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
