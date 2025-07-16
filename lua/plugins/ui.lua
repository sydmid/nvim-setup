-- Global variables to track current background mode
_G.background_modes = {
	{ bg = "#121212", cursorline = "#272727", name = "Dark" },
	{ bg = "#1f1f19", cursorline = "#333227", name = "Warm" },
	{ bg = "#282c34", cursorline = "#383e4a", name = "MonoKai" },
	{ bg = "#0f1419", cursorline = "#1a1f29", name = "Cool" }
}
_G.current_bg_index = 1

-- Function to set background mode
function _G.set_background_mode(mode_index)
	if mode_index < 1 or mode_index > #_G.background_modes then
		vim.notify("❌ Invalid background mode index!", vim.log.levels.ERROR)
		return
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
	-- One Monokai colorscheme - the only theme we need
	{
		"cpea2506/one_monokai.nvim",
		priority = 1000,
		config = function()
			-- Configure One Monokai theme
			require("one_monokai").setup({
				transparent = false,
				colors = {},
				highlights = function(colors)
					return {}
				end,
				italics = true,
			})

			-- Load saved background preference
			_G.load_background_preference()

			-- Set the colorscheme
			vim.opt.background = "dark"
			vim.cmd.colorscheme("one_monokai")

			-- Apply the current background mode
			_G.set_background_mode(_G.current_bg_index)

			-- Create autocmd to reapply background highlights when colorscheme changes
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "one_monokai",
				group = vim.api.nvim_create_augroup("OneMonokaiBackground", { clear = true }),
				callback = function()
					-- Reapply current background mode
					_G.set_background_mode(_G.current_bg_index)
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

			-- Enhanced no-clown-fiesta palette with improved vibrancy and contrast
			local colors = {
				-- Core theme colors from no-clown-fiesta palette
				bg = "#121212",           -- Main background
				alt_bg = "#121212",       -- Alternative background
				accent = "#202020",       -- Accent background
				fg = "#E1E1E1",          -- Main foreground
				light_gray = "#AFAFAF",   -- Light gray text
				medium_gray = "#727272",  -- Medium gray text
				gray = "#373737",        -- Dark gray

				-- Enhanced vibrant colors with better contrast
				blue = "#BAD7FF",        -- Bright blue (no-clown-fiesta blue)
				cyan = "#88afa2",        -- Cyan (no-clown-fiesta cyan)
				green = "#90A959",       -- Green (no-clown-fiesta green)
				yellow = "#F4BF75",      -- Yellow (no-clown-fiesta yellow)
				orange = "#FFA557",      -- Orange (no-clown-fiesta orange)
				red = "#b46958",         -- Red (no-clown-fiesta red)
				purple = "#AA749F",      -- Purple (no-clown-fiesta purple)
				gray_blue = "#7E97AB",   -- Gray-blue (no-clown-fiesta gray_blue)
			}

			local my_lualine_theme = {
				normal = {
					a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
					b = { bg = colors.alt_bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.light_gray },
				},
				insert = {
					a = { bg = colors.green, fg = colors.bg, gui = "bold" },
					b = { bg = colors.alt_bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.light_gray },
				},
				visual = {
					a = { bg = colors.purple, fg = colors.fg, gui = "bold" },
					b = { bg = colors.alt_bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.light_gray },
				},
				command = {
					a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
					b = { bg = colors.alt_bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.light_gray },
				},
				replace = {
					a = { bg = colors.red, fg = colors.fg, gui = "bold" },
					b = { bg = colors.alt_bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.light_gray },
				},
				inactive = {
					a = { bg = colors.gray, fg = colors.medium_gray, gui = "bold" },
					b = { bg = colors.gray, fg = colors.medium_gray },
					c = { bg = colors.gray, fg = colors.medium_gray },
				},
			}

			-- configure lualine with enhanced theme
			lualine.setup({
				options = {
					theme = my_lualine_theme,
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
							color = { fg = colors.fg },
							symbols = {
								modified = "",
								readonly = "",
								unnamed = "",
							}
						},
						{
							"diff",
							colored = true,
							diff_color = {
								added    = { fg = colors.green },
								modified = { fg = colors.yellow },
								removed  = { fg = colors.red },
							},
						}
					},
					lualine_c = {
					},
					lualine_x = {
						-- {
						-- 	lazy_status.updates,
						-- 	cond = lazy_status.has_updates,
						-- 	color = { fg = colors.orange },
						-- },
						{
							"diagnostics",
							sources = { "nvim_lsp", "nvim_diagnostic" },
							sections = { "error", "warn", "info", "hint" },
							diagnostics_color = {
								error = { fg = colors.red },
								warn  = { fg = colors.yellow },
								info  = { fg = colors.blue },
								hint  = { fg = colors.cyan },
							},
							symbols = {
								error = " ",
								warn = " ",
								info = " ",
								hint = " "
							},
						},
						-- {
						-- 	"encoding",
						-- 	color = { fg = colors.medium_gray }
						-- },
						{
							"fileformat",
							color = { fg = colors.medium_gray },
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
							color = { fg = colors.gray_blue }
						},
					},
					lualine_y = {
						{
							-- "progress",
							-- color = { fg = colors.light_gray }
						}
					},
					lualine_z = {
						{
							"branch",
							icon = "󰊢",
							color = { fg = colors.cyan, bg = colors.alt_bg }
						}
					}
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {
						{
							"filename",
							color = { fg = colors.medium_gray }
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
			vim.api.nvim_set_hl(0, "HighlightedyankRegion", {
				fg = "#121212",
				bg = "#F4BF75",
				bold = true
			})
		end,
	},

	-- Indentation guides with enhanced visibility
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = {
				char = "│",
				tab_char = "│",
			},
			scope = {
				enabled = true,
				char = "│",
				show_start = true,
				show_end = true,
				highlight = { "IblScope" },
			},
			exclude = {
				filetypes = {
					"help",
					"dashboard",
					"alpha",
					"lazy",
					"mason",
					"trouble",
					"oil",
					"NvimTree",
					"neo-tree",
					"terminal",
					"toggleterm",
					"notify",
					"noice",
					"TelescopePrompt",
					"TelescopeResults",
					"TelescopePreview",
				},
				buftypes = {
					"terminal",
					"nofile",
					"quickfix",
					"prompt",
					"help",
				},
			},
		},
		config = function(_, opts)
			require("ibl").setup(opts)
			-- Enhanced indent guide colors
			vim.api.nvim_set_hl(0, "IblIndent", { fg = "#2A2A2A" })
			vim.api.nvim_set_hl(0, "IblScope", { fg = "#404040", bold = true })
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
			-- Enhanced noice highlight groups with no-clown-fiesta theme
			vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#505050", bg = "#121212" })
			vim.api.nvim_set_hl(0, "NoiceCmdlinePrompt", { fg = "#BAD7FF", bold = true })
			vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#88afa2" })
			vim.api.nvim_set_hl(0, "NoicePopup", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "NoicePopupBorder", { fg = "#505050", bg = "#121212" })
			vim.api.nvim_set_hl(0, "NoiceConfirm", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { fg = "#505050", bg = "#121212" })
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
				{ "<leader>ch", desc = "Toggle context header (robust)" },
				{ "<leader>cj", desc = "Jump to context" },
				{ "<leader>cd", desc = "Debug context state" },
				{ "<leader>ce", desc = "Force enable context" },
				{ "<leader>cx", desc = "Force disable context" },
				{ "<leader>cs", desc = "Context status & health" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>e", group = "Error Lens/Explorer" },
				{ "<leader>el", desc = "Toggle Error Lens (ThePrimeagen style)" },
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
				background_colour = "#000000",
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

			-- Set custom yank highlight using theme colors
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("YankHighlightTheme", { clear = true }),
				callback = function()
					vim.api.nvim_set_hl(0, "HighlightedyankRegion", {
						fg = "#121212",
						bg = "#F4BF75",
						bold = true
					})
				end,
			})

			-- Apply highlights immediately
			vim.api.nvim_set_hl(0, "HighlightedyankRegion", {
				fg = "#121212",
				bg = "#F4BF75",
				bold = true
			})
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

}