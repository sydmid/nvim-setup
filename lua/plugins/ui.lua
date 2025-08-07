-- Global variables to track current background mode
_G.background_modes = {
    { bg = "#282c34", cursorline = "#303640", name = "Light" },
	{ bg = "#1f1f19", cursorline = "#333227", name = "Warm" },
	{ bg = "#0f1419", cursorline = "#1a1f29", name = "Bluish" },
	{ bg = "#121212", cursorline = "#272727", name = "Dark" }
}
_G.current_bg_index = 1

-- Function to set background mode
function _G.set_background_mode(mode_index)
	if mode_index < 1 or mode_index > #_G.background_modes then
        mode_index = 0
	end

	_G.current_bg_index = mode_index
	local mode = _G.background_modes[mode_index]

	-- Apply custom background highlights
	local bg_highlights = {
		Normal = { bg = mode.bg },
		NormalFloat = { bg = mode.bg },
		SignColumn = { bg = mode.bg },
		LineNr = { bg = mode.bg },
		CursorLine = { bg = mode.cursorline },
		CursorLineNr = { bg = mode.cursorline },
		StatusLine = { bg = mode.cursorline },
		TabLineFill = { bg = mode.bg },
		Pmenu = { bg = mode.bg },
		PmenuBorder = { bg = mode.bg },
		TelescopeNormal = { bg = mode.bg },
		TelescopeBorder = { bg = mode.bg },
		TelescopeResultsNormal = { bg = mode.bg },
		TelescopeResultsBorder = { bg = mode.bg },
		TelescopePreviewNormal = { bg = mode.bg },
		TelescopePreviewBorder = { bg = mode.bg },
		TelescopePromptNormal = { bg = mode.bg },
		TelescopePromptBorder = { bg = mode.bg },
		NoiceCmdlinePopup = { bg = mode.bg },
		NoiceCmdlinePopupBorder = { bg = mode.bg },
		NoicePopup = { bg = mode.bg },
		NoicePopupBorder = { bg = mode.bg },
		NoiceConfirm = { bg = mode.bg },
		NoiceConfirmBorder = { bg = mode.bg },
	}

	-- Apply the highlights
	for group, opts in pairs(bg_highlights) do
		local current_hl = vim.api.nvim_get_hl(0, { name = group })
		vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", current_hl, opts))
	end

	_G.save_background_preference()
	vim.notify("🎨 Background mode: " .. mode.name, vim.log.levels.INFO)
end

-- Function to cycle through background modes
function _G.toggle_background_mode()
	local next_index = (_G.current_bg_index % #_G.background_modes) + 1
	_G.set_background_mode(next_index)
end

-- Function to save background preference
function _G.save_background_preference()
	local bg_file = vim.fn.stdpath("data") .. "/background_preference.lua"
	local file = io.open(bg_file, "w")
	if file then
		file:write("return {\n")
		file:write("  mode_index = " .. _G.current_bg_index .. "\n")
		file:write("}\n")
		file:close()
	end
end

-- Function to load background preference
function _G.load_background_preference()
	local bg_file = vim.fn.stdpath("data") .. "/background_preference.lua"
	if vim.fn.filereadable(bg_file) == 1 then
		local ok, prefs = pcall(dofile, bg_file)
		if ok and prefs and prefs.mode_index then
			_G.current_bg_index = prefs.mode_index
		end
	end
end

-- Function to list all available background modes
function _G.list_background_modes()
	local mode_names = {}
	for i, mode in ipairs(_G.background_modes) do
		table.insert(mode_names, mode.name)
	end
	vim.notify("Background modes: " .. table.concat(mode_names, ", ") .. "\nCurrent: " .. _G.background_modes[_G.current_bg_index].name, vim.log.levels.INFO)
end

-- Function to create a Telescope background mode picker
function _G.telescope_background_picker()
	if not pcall(require, "telescope") then
		vim.notify("Telescope not available", vim.log.levels.WARN)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local mode_info = {}
	for i, mode in ipairs(_G.background_modes) do
		table.insert(mode_info, {
			index = i,
			name = mode.name,
			bg = mode.bg,
			cursorline = mode.cursorline,
			display = string.format("🎨 %s - BG: %s, Line: %s", mode.name, mode.bg, mode.cursorline),
			description = string.format("Background: %s, Active line: %s", mode.bg, mode.cursorline)
		})
	end

	pickers.new({}, {
		prompt_title = "🎨 Background Mode Selector (Current: " .. _G.background_modes[_G.current_bg_index].name .. ")",
		initial_mode = "normal",
		finder = finders.new_table({
			results = mode_info,
			entry_maker = function(entry)
				local display_text = entry.display
				-- Add current mode indicator
				if entry.index == _G.current_bg_index then
					display_text = "✓ " .. entry.display .. " 🎯 (CURRENT)"
				end

				return {
					value = entry.index,
					display = display_text,
					ordinal = entry.name .. " " .. entry.display,
					mode_info = entry,
					is_current = entry.index == _G.current_bg_index
				}
			end
		}),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if selection then
					_G.set_background_mode(selection.value)
				end
			end)
			return true
		end,
	}):find()
end





local theme_opts = {
	styles = {
		type = { bold = true },
		lsp = { underline = false },
		match_paren = { underline = true },
		functions = { bold = true }, -- Make functions bolder for better contrast
		keywords = { bold = true },  -- Make keywords bolder
		comments = { italic = true }, -- Make comments italic for distinction
	},
}

return {
	{
		"bluz71/vim-moonfly-colors",
		priority = 1000,
        name = "moonfly",
		config = function()
			-- Configure moonfly theme options
			vim.g.moonflyCursorColor = true
			vim.g.moonflyItalics = true
			vim.g.moonflyTransparent = false
			vim.g.moonflyUndercurls = true
			vim.g.moonflyUnderlineMatchParen = true
			vim.g.moonflyVirtualTextColor = true

			-- Load saved background preference
			_G.load_background_preference()

			-- Set the colorscheme
			vim.opt.background = "dark"
			vim.cmd.colorscheme("moonfly")

			-- Apply the current background mode
			_G.set_background_mode(_G.current_bg_index)

			-- Create autocmd to reapply background highlights when colorscheme changes
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "moonfly",
				group = vim.api.nvim_create_augroup("AyuBackground", { clear = true }),
				callback = function()
					-- Reapply current background mode
					_G.set_background_mode(_G.current_bg_index)
				end,
			})

			-- Additional autocmd to fix Telescope backgrounds specifically
			vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
				pattern = { "TelescopePrompt", "TelescopeResults", "TelescopePreview" },
				group = vim.api.nvim_create_augroup("TelescopeBackgroundFix", { clear = true }),
				callback = function()
					-- Reapply telescope highlights from current background mode
					local mode = _G.background_modes[_G.current_bg_index]
					if mode then
						vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = mode.bg })
						vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = mode.bg })
						vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = mode.bg })
						vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = mode.bg })
						vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = mode.bg })
						vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = mode.bg })
						vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = mode.bg })
						vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = mode.bg })
					end
				end,
			})

			-- Add keymaps for background mode
			vim.keymap.set("n", "<leader>bb", function()
				_G.toggle_background_mode()
			end, { desc = "🎨 Toggle background mode", silent = true })

			vim.keymap.set("n", "<leader>bs", function()
				_G.telescope_background_picker()
			end, { desc = "🎨 Select background mode", silent = true })
		end,
		lazy = false
	},

	-- Status line
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local lualine = require("lualine")
			local lazy_status = require("lazy.status") -- to configure lazy pending updates count

			-- configure lualine with auto theme that adapts to your background system
			lualine.setup({
				options = {
					theme = "auto", -- Let lualine auto-detect theme from colorscheme
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					globalstatus = true, -- Use global statusline for better alignment
				},
				sections = {
					lualine_a = {
						{
							"mode",
							fmt = function(str)
								return str:sub(1,1) -- Show only first letter (N, I, V, C, R)
							end
						}
					},
					lualine_b = {
						{
							"filename",
							path = 0, -- Show filename only (no path)
							symbols = {
								modified = "",
								readonly = "",
								unnamed = "",
							}
						},
						{
							"diff",
							colored = true,
						}
					},
					lualine_c = {
					},
					lualine_x = {
						-- {
						-- 	lazy_status.updates,
						-- 	cond = lazy_status.has_updates,
						-- },
						{
							"diagnostics",
							sources = { "nvim_lsp", "nvim_diagnostic" },
							sections = { "error", "warn", "info", "hint" },
							symbols = {
								error = " ",
								warn = " ",
								info = " ",
								hint = " "
							},
						},
						-- {
						-- 	"encoding",
						-- },
						{
							"fileformat",
							symbols = {
								unix = "LF",
								dos = "CRLF",
								mac = "CR",
							}
						},
						{
							"filetype",
							colored = true,
							icon_only = false,
						},
					},
					lualine_y = {
						{
							-- "progress",
						}
					},
					lualine_z = {
						{
							"branch",
							icon = "󰊢",
						}
					}
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {
						{
							"filename",
						}
					},
					lualine_x = {
						-- Location hidden per user request
					},
					lualine_y = {},
					lualine_z = {}
				},
			})
		end,
	},
	-- Highlight yanked text with enhanced styling
	{
		"machakann/vim-highlightedyank",
		event = "VeryLazy",
		config = function()
			-- Enhanced yank highlight with no-clown-fiesta colors
			vim.g.highlightedyank_highlight_duration = 200
		end,
	},

	-- hlchunk.nvim - Beautiful animated indentation and chunk highlighting
	{
		"shellRaining/hlchunk.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("hlchunk").setup({
				-- Chunk highlighting with beautiful animations
				chunk = {
					enable = true,
					priority = 15,
					use_treesitter = true,
					chars = {
						horizontal_line = "─",
						vertical_line = "│",
						left_top = "╭",
						left_bottom = "╰",
						right_arrow = ">",
					},
					textobject = "ic", -- Inner chunk textobject
					max_file_size = 1024 * 1024, -- 1MB max file size
					error_sign = true,
					-- Animation settings for smooth effects
					duration = 200, -- Animation duration in ms
					delay = 300,   -- Animation delay in ms
					exclude_filetypes = {
						aerial = true,
						dashboard = true,
						alpha = true,
						lazy = true,
						mason = true,
						trouble = true,
						oil = true,
						NvimTree = true,
						["neo-tree"] = true,
						terminal = true,
						toggleterm = true,
						notify = true,
						noice = true,
						TelescopePrompt = true,
						TelescopeResults = true,
						TelescopePreview = true,
						help = true,
					},
				},
				-- Indent line highlighting
				indent = {
					enable = true,
					priority = 10,
					use_treesitter = false, -- Keep false for better performance
					chars = { "│" }, -- Simple vertical line character
					ahead_lines = 5, -- Preview range
					delay = 100, -- Throttle delay for smooth scrolling
					exclude_filetypes = {
						aerial = true,
						dashboard = true,
						alpha = true,
						lazy = true,
						mason = true,
						trouble = true,
						oil = true,
						NvimTree = true,
						["neo-tree"] = true,
						terminal = true,
						toggleterm = true,
						notify = true,
						noice = true,
						TelescopePrompt = true,
						TelescopeResults = true,
						TelescopePreview = true,
						help = true,
					},
				},
				-- Disable other features as requested
				line_num = {
					enable = false,
				},
				blank = {
					enable = false,
				},
			})
		end,
	},

	-- Better UI elements with enhanced theming
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
        signature = {
          auto_open = { enabled = false },
        }
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
			-- Enhanced command line styling
			cmdline = {
				enabled = true,
				view = "cmdline_popup",
				format = {
					cmdline = { pattern = "^:", icon = "", lang = "vim" },
					search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
					search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
					filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
					lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
					help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖" },
				},
			},
			-- Enhanced messages styling
			messages = {
				enabled = true,
				view = "notify",
				view_error = "notify",
				view_warn = "notify",
				view_history = "messages",
				view_search = "virtualtext",
			},
		},
		config = function(_, opts)
			require("noice").setup(opts)
		end,
	},

	-- Telescope symbols (replaces symbols-outline with beautiful telescope UI)
	-- Features:
	-- Maintains document order while preserving hierarchy
	{
		"nvim-telescope/telescope.nvim",
		keys = {
			{
				"<D-S-o>",
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
								initial_mode = "normal",
								attach_mappings = function(prompt_bufnr, map)
									-- Add proper Esc handling
									map("i", "<Esc>", actions.close)
									map("n", "<Esc>", actions.close)
									map("n", "q", actions.close)
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
				"<D-o>",
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
								initial_mode = "normal",
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
							initial_mode = "normal",							attach_mappings = function(prompt_bufnr, map)
								-- Add proper Esc handling
								map("i", "<Esc>", actions.close)
								map("n", "<Esc>", actions.close)
								map("n", "q", actions.close)

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
					separator = "|",
					group = "+",
				},
				layout = {
					height = { min = 4, max = 25 },
					width = { min = 20, max = 50 },
					spacing = 3,
					-- align = "center",
				},
				show_help = false,
			})

			-- Register all the key groups
			wk.add({
				-- AI/Avante group with streamlined commands
				{ "<leader>a", group = "AI" },
				{ "<leader>ac", desc = "Toggle chat" },
				{ "<leader>ai", desc = "Ask input" },
				{ "<leader>af", desc = "Focus chat" },
				{ "<leader>al", desc = "Clear chat" },
				-- Native Avante history features
				{ "<leader>ah", desc = "Avante history" },
				{ "[a", desc = "Chat history selector" },
				{ "]a", desc = "Chat history selector" },
				-- Code assistance (visual mode)
				{ "<leader>ae", desc = "Explain code" },
				{ "<leader>at", desc = "Generate tests" },
				{ "<leader>ar", desc = "Review code" },
				{ "<leader>ad", desc = "Add docs" },
				{ "<leader>ao", desc = "Optimize code" },
				-- Git integration
				{ "<leader>am", desc = "Commit message" },
				-- Provider management
				{ "<leader>ap", desc = "Switch provider" },
				{ "<leader>aT", desc = "Test Ollama" },
				{ "<leader>aP", desc = "Test current provider" },

				-- Other groups
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Context/Code-Actions" },
				{ "<leader>ch", desc = "Toggle context header" },
				{ "<leader>ck", desc = "Jump to context" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>e", group = "Error Lens/Explorer" },
				{ "<leader>el", desc = "Toggle Error Lens" },
				{ "<leader>ee", desc = "Enable Error Lens" },
				{ "<leader>ed", desc = "Disable Error Lens" },
				{ "<leader>er", desc = "Refresh Error Lens" },
				{ "<leader>en", desc = "Next diagnostic (with Error Lens)" },
				{ "<leader>ep", desc = "Previous diagnostic (with Error Lens)" },
				{ "<leader>f", group = "File/Find" },
				{ "<leader>g", group = "Git/Goto" },
				{ "<leader>h", group = "Hunks/Git-Stage" },
				{ "<leader>i", group = "Info/Implementations" },
				{ "<leader>j", group = "Jump" },
				{ "<leader>k", group = "Jump/Flash" },
				{ "<leader>l", group = "LSP" },
				{ "<leader>m", group = "Marks" },
				{ "<leader>n", group = "Navigation" },
				{ "<leader>o", group = "Overseer/Tasks" },
				{ "<leader>p", group = "Peek/Preview" },
				{ "<leader>r", group = "Rename/Refactor" },
				{ "<leader>s", group = "Snacks/Split" },
				{ "<leader>t", group = "Terminal/Tabs/Themes" },
				{ "<leader>tt", desc = "Select theme" },
				{ "<leader>u", group = "Test/Utils" },
				{ "<leader>v", group = "Visual/View" },
				{ "<leader>w", group = "Workspace/Tabs" },
				{ "<leader>x", group = "Diagnostics/Trouble" },
				{ "<leader>z", group = "Fold" },
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
				timeout = 3000,
				max_width = 80,
				level = vim.log.levels.ERROR,
			})
		end,
	},

	-- Enhanced yank highlighting with theme colors
	{
		"machakann/vim-highlightedyank",
		event = "TextYankPost",
		config = function()
			-- Configure highlighted yank with no-clown-fiesta theme colors
			vim.g.highlightedyank_highlight_duration = 200
		end,
	},
	-- Features: Cursor position, Search results, Diagnostics, Git hunks, Marks, Quickfix
	{
		"lewis6991/satellite.nvim",
		event = "VeryLazy",
		dependencies = { "lewis6991/gitsigns.nvim" }, -- For git hunks display
		config = function()
			require("satellite").setup({
				current_only = false, -- Show scrollbars for all windows
				winblend = 40, -- Slight transparency for better integration
				zindex = 40, -- Layer ordering
				excluded_filetypes = {
					"dashboard", -- Exclude dashboard
					"alpha", -- Exclude alpha dashboard
					"TelescopePrompt", -- Exclude Telescope
					"TelescopeResults",
					"TelescopePreview",
					"mason", -- Exclude Mason
					"lazy", -- Exclude Lazy plugin manager
					"help", -- Exclude help windows
					"Outline", -- Exclude symbols outline
					"NvimTree", -- Exclude file explorer
					"neo-tree", -- Exclude neo-tree
					"terminal", -- Exclude terminal
					"toggleterm", -- Exclude toggleterm
					"notify", -- Exclude notifications
					"noice", -- Exclude noice popups
				},
				width = 2, -- Scrollbar width
				handlers = {
					cursor = {
						enable = true,
						-- Unicode block characters for smooth cursor indication
						symbols = { "⎺", "⎻", "⎼", "⎽" },
						-- Alternative minimal symbols: symbols = { "⎻", "⎼" },
					},
					search = {
						enable = true,
						-- Uses SatelliteSearch and SatelliteSearchCurrent highlights
					},
					diagnostic = {
						enable = true,
						-- Different symbols for different diagnostic severities
						-- signs = { "-", "=", "≡" },
						min_severity = vim.diagnostic.severity.ERROR,
						-- Shows all diagnostic levels including hints
					},
					gitsigns = {
						enable = true,
						signs = {
							add = "+", -- Git addition indicator
							change = "~", -- Git change indicator
							delete = "-", -- Git deletion indicator
						},
						-- Uses SatelliteGitSignsAdd, SatelliteGitSignsChange, SatelliteGitSignsDelete
					},
					marks = {
						enable = true,
						show_builtins = false, -- Hide builtin marks like [ ] < >
						key = "m", -- Key for setting marks
						-- Uses SatelliteMark highlight
					},
					quickfix = {
						enable = false,
					},
				},
			})
		end,
	},
	-- High-performance color highlighter
	{
		"norcalli/nvim-colorizer.lua",
		event = "BufRead",
		config = function()
			require("colorizer").setup({
				"css",
				"html",
				"javascript",
				"typescript",
				"vue",
				"scss",
				"sass",
			}, {
				RGB = true, -- #RGB hex codes
				RRGGBB = true, -- #RRGGBB hex codes
				names = false, -- Disable named colors to avoid false positives
				RRGGBBAA = false, -- #RRGGBBAA hex codes
				rgb_fn = true, -- CSS rgb() and rgba() functions
				hsl_fn = true, -- CSS hsl() and hsla() functions
				css = true, -- Enable all CSS features
				css_fn = true, -- Enable all CSS *functions*
				mode = "background", -- Set the display mode
			})
		end,
	},

	-- Tabby.nvim - Beautiful and configurable tab line
	{
		"nanozuki/tabby.nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local theme = {
				fill = "TabLineFill",
				-- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
				head = "TabLine",
				current_tab = "TabLineSel",
				tab = "TabLine",
				win = "TabLine",
				tail = "TabLine",
			}

			require("tabby.tabline").set(function(line)
				return {
					{
						{ "  ", hl = theme.head },
						line.sep("", theme.head, theme.fill),
					},
					line.tabs().foreach(function(tab)
						local hl = tab.is_current() and theme.current_tab or theme.tab
						return {
							line.sep("", hl, theme.fill),
							tab.is_current() and "" or "󰆣",
							tab.number(),
							tab.name(),
							tab.close_btn(""),
							line.sep("", hl, theme.fill),
							hl = hl,
							margin = " ",
						}
					end),
					line.spacer(),
					line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
						return {
							line.sep("", theme.win, theme.fill),
							win.is_current() and "" or "",
							win.buf_name(),
							line.sep("", theme.win, theme.fill),
							hl = theme.win,
							margin = " ",
						}
					end),
					{
						line.sep("", theme.tail, theme.fill),
						{ "  ", hl = theme.tail },
					},
					hl = theme.fill,
				}
			end)
		end,
	},

	-- Enhanced cursorword highlighting (cursorline disabled to avoid conflicts)
	{
		"ya2s/nvim-cursorline",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require('nvim-cursorline').setup({
				cursorline = {
					-- Disable cursorline management to avoid conflicts with existing setup
					enable = false,
					timeout = 1000,
					number = false,
				},
				cursorword = {
					-- Keep cursorword functionality for highlighting words under cursor
					enable = true,
					min_length = 3,
					hl = { underline = true },
				}
			})
		end,
	},

	-- Smooth scrolling animations for any movement
	{
		"declancm/cinnamon.nvim",
		version = "*",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("cinnamon").setup({
				-- Enable both basic and extra keymaps for comprehensive smooth scrolling
				keymaps = {
					basic = true,  -- Half-window, page, paragraph, search, cursor location movements
					extra = true,  -- Start/end of file/line, screen scrolling, up/down, left/right movements
				},
				options = {
					-- Animate cursor and window scrolling for any movement
					mode = "cursor",
					-- Don't require count for animation (smoother experience)
					count_only = false,
					-- Slightly faster delay for responsive feel
					delay = 4,
					max_delta = {
						-- Disable limits for line movements (always animate)
						line = false,
						-- Disable limits for column movements (always animate)
						column = false,
						-- Maximum duration for any movement (1 second)
						time = 1000,
					},
					step_size = {
						-- Smooth vertical movement (1 line per step)
						vertical = 1,
						-- Slightly larger horizontal steps for efficiency
						horizontal = 2,
					},
				},
			})

			-- Disable smooth scrolling for specific file types where it might be distracting
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"dashboard",
					"alpha",
					"lazy",
					"mason",
					"telescope",
					"TelescopePrompt",
					"TelescopeResults",
					"TelescopePreview",
					"notify",
					"noice",
					"NvimTree",
					"neo-tree",
					"oil",
					"trouble",
					"qf", -- quickfix
				},
				callback = function()
					vim.b.cinnamon_disable = true
				end,
			})
		end,
	},

}