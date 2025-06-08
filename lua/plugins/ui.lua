--
-- Comprehensive UI theming for Neovim with no-clown-fiesta theme
-- Features:
-- - Consistent #121212 background across ALL UI elements (main editor, Telescope, LSP floating windows, command line)
-- - Enhanced syntax highlighting with better contrast and vibrancy
-- - Telescope theming with proper title colors and selection highlighting
-- - LSP hover/signature help windows styled to match the theme
-- - Command line (noice) floating windows with consistent background
-- - Completion menu (nvim-cmp) styled with theme colors
-- - LSP Saga windows themed consistently
-- - Auto-persistence of custom highlights after theme changes via ColorScheme autocmd
--
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

local function config_theme()
	local plugin = require("no-clown-fiesta")
	plugin.setup(theme_opts)
	plugin.load()

	-- Apply additional highlight enhancements for better vibrancy and contrast
	local enhancements = {
		-- Enhance syntax highlighting with better contrast
		Normal = { fg = "#E1E1E1", bg = "#121212" }, -- Match Telescope background exactly
		NormalNC = { fg = "#E1E1E1", bg = "#121212" }, -- Non-current window background
		Function = { fg = "#88afa2", bold = true }, -- Enhanced cyan for functions
		Keyword = { fg = "#7E97AB", bold = true }, -- Enhanced gray-blue for keywords
		String = { fg = "#A2B5C1" }, -- Brighter string color
		Number = { fg = "#b46958", bold = true }, -- Enhanced red for numbers
		Comment = { fg = "#727272", italic = true }, -- Italic comments
		Type = { fg = "#E1E1E1", bold = true }, -- Bold types
		Constant = { fg = "#E1E1E1", bold = true }, -- Bold constants
		Special = { fg = "#FFA557" }, -- Orange for special characters
		PreProc = { fg = "#AA749F" }, -- Purple for preprocessor
		Identifier = { fg = "#BAD7FF" }, -- Blue for identifiers
		Statement = { fg = "#7E97AB", bold = true }, -- Bold statements

		-- Enhanced UI elements
		Visual = { bg = "#2A2A2A" }, -- Darker visual selection for better contrast
		Search = { fg = "#121212", bg = "#FFA557", bold = true }, -- High contrast search
		IncSearch = { fg = "#121212", bg = "#F4BF75", bold = true }, -- High contrast incremental search
		CursorLine = { bg = "#1A1A1A" }, -- Subtle cursor line
		LineNr = { fg = "#505050" }, -- Brighter line numbers
		CursorLineNr = { fg = "#AFAFAF", bold = true }, -- Bright current line number
		StatusLine = { fg = "#E1E1E1", bg = "#202020" }, -- Enhanced statusline
		WinSeparator = { fg = "#404040" }, -- Brighter window separators

		-- Ensure floating windows match the main background
		NormalFloat = { fg = "#E1E1E1", bg = "#121212" }, -- Floating windows background
		FloatBorder = { fg = "#505050", bg = "#121212" }, -- Floating window borders

		-- Enhanced diagnostic colors for better visibility
		DiagnosticError = { fg = "#E74C3C" }, -- Brighter red
		DiagnosticWarn = { fg = "#F39C12" }, -- Brighter orange
		DiagnosticInfo = { fg = "#3498DB" }, -- Brighter blue
		DiagnosticHint = { fg = "#17A2B8" }, -- Brighter cyan

		-- Enhanced git colors
		GitSignsAdd = { fg = "#27AE60" }, -- Brighter green
		GitSignsChange = { fg = "#3498DB" }, -- Brighter blue
		GitSignsDelete = { fg = "#E74C3C" }, -- Brighter red

		-- Enhanced popup menu
		Pmenu = { fg = "#E1E1E1", bg = "#121212" }, -- Better contrast popup menu to match theme
		PmenuSel = { fg = "#121212", bg = "#BAD7FF", bold = true }, -- High contrast selection
		PmenuBorder = { fg = "#505050", bg = "#121212" }, -- Visible popup border to match theme
		PmenuKind = { fg = "#88afa2", bg = "#121212" }, -- LSP kind indicators
		PmenuKindSel = { fg = "#121212", bg = "#BAD7FF", bold = true }, -- Selected LSP kind
		PmenuExtra = { fg = "#AFAFAF", bg = "#121212" }, -- Extra text
		PmenuExtraSel = { fg = "#121212", bg = "#BAD7FF" }, -- Selected extra text

		-- Enhanced Telescope theming for consistency with no-clown-fiesta
		TelescopeNormal = { fg = "#E1E1E1", bg = "#121212" },
		TelescopeBorder = { fg = "#505050", bg = "#121212" },
		TelescopePromptNormal = { fg = "#E1E1E1", bg = "#1A1A1A" },
		TelescopePromptBorder = { fg = "#BAD7FF", bg = "#1A1A1A" },
		TelescopePromptTitle = { fg = "#121212", bg = "#BAD7FF", bold = true },
		TelescopePromptPrefix = { fg = "#88afa2", bold = true },
		TelescopePromptCounter = { fg = "#F4BF75" },
		TelescopeResultsNormal = { fg = "#E1E1E1", bg = "#121212" },
		TelescopeResultsBorder = { fg = "#505050", bg = "#121212" },
		TelescopeResultsTitle = { fg = "#121212", bg = "#90A959", bold = true },
		TelescopePreviewNormal = { fg = "#E1E1E1", bg = "#121212" },
		TelescopePreviewBorder = { fg = "#505050", bg = "#121212" },
		TelescopePreviewTitle = { fg = "#121212", bg = "#FFA557", bold = true },
		TelescopeSelection = { fg = "#E1E1E1", bg = "#2A2A2A", bold = true },
		TelescopeSelectionCaret = { fg = "#88afa2", bold = true },
		TelescopeMatching = { fg = "#F4BF75", bold = true },
		TelescopeMultiSelection = { fg = "#AA749F", bold = true },
		TelescopeMultiIcon = { fg = "#AA749F" },

		-- LSP Saga theming for consistency
		SagaNormal = { fg = "#E1E1E1", bg = "#121212" },
		SagaBorder = { fg = "#505050", bg = "#121212" },
		SagaTitle = { fg = "#121212", bg = "#BAD7FF", bold = true },
		SagaHover = { fg = "#E1E1E1", bg = "#121212" },
		SagaCodeAction = { fg = "#F4BF75", bold = true },
		SagaRename = { fg = "#E1E1E1", bg = "#121212" },
		SagaFinderSelection = { fg = "#E1E1E1", bg = "#2A2A2A", bold = true },
	}

	-- Apply the enhancements
	for group, opts in pairs(enhancements) do
		vim.api.nvim_set_hl(0, group, opts)
	end

	-- Ensure Telescope highlights are applied after theme load
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("TelescopeThemeEnhancements", { clear = true }),
		callback = function()
			-- Ensure main background matches Telescope background exactly
			vim.api.nvim_set_hl(0, "Normal", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "NormalNC", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#505050", bg = "#121212" })

			-- Re-apply Telescope highlights to ensure they persist after theme changes
			local telescope_highlights = {
				TelescopeNormal = { fg = "#E1E1E1", bg = "#121212" },
				TelescopeBorder = { fg = "#505050", bg = "#121212" },
				TelescopePromptNormal = { fg = "#E1E1E1", bg = "#1A1A1A" },
				TelescopePromptBorder = { fg = "#BAD7FF", bg = "#1A1A1A" },
				TelescopePromptTitle = { fg = "#121212", bg = "#BAD7FF", bold = true },
				TelescopePromptPrefix = { fg = "#88afa2", bold = true },
				TelescopePromptCounter = { fg = "#F4BF75" },
				TelescopeResultsNormal = { fg = "#E1E1E1", bg = "#121212" },
				TelescopeResultsBorder = { fg = "#505050", bg = "#121212" },
				TelescopeResultsTitle = { fg = "#121212", bg = "#90A959", bold = true },
				TelescopePreviewNormal = { fg = "#E1E1E1", bg = "#121212" },
				TelescopePreviewBorder = { fg = "#505050", bg = "#121212" },
				TelescopePreviewTitle = { fg = "#121212", bg = "#FFA557", bold = true },
				TelescopeSelection = { fg = "#E1E1E1", bg = "#2A2A2A", bold = true },
				TelescopeSelectionCaret = { fg = "#88afa2", bold = true },
				TelescopeMatching = { fg = "#F4BF75", bold = true },
				TelescopeMultiSelection = { fg = "#AA749F", bold = true },
				TelescopeMultiIcon = { fg = "#AA749F" },
			}

			for group, opts in pairs(telescope_highlights) do
				vim.api.nvim_set_hl(0, group, opts)
			end

			-- Re-apply LSP floating window highlights
			vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", {
				bg = "#2A2A2A",
				fg = "#F4BF75",
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, "FloatTitle", {
				bg = "#BAD7FF",
				fg = "#121212",
				bold = true
			})

			-- Re-apply noice highlights
			vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#505050", bg = "#121212" })
			vim.api.nvim_set_hl(0, "NoiceCmdlinePrompt", { fg = "#BAD7FF", bold = true })
			vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#88afa2" })
			vim.api.nvim_set_hl(0, "NoicePopup", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "NoicePopupBorder", { fg = "#505050", bg = "#121212" })
			vim.api.nvim_set_hl(0, "NoiceConfirm", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { fg = "#505050", bg = "#121212" })

			-- Re-apply popup menu highlights for consistency
			vim.api.nvim_set_hl(0, "Pmenu", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#121212", bg = "#BAD7FF", bold = true })
			vim.api.nvim_set_hl(0, "PmenuBorder", { fg = "#505050", bg = "#121212" })
			vim.api.nvim_set_hl(0, "PmenuKind", { fg = "#88afa2", bg = "#121212" })
			vim.api.nvim_set_hl(0, "PmenuKindSel", { fg = "#121212", bg = "#BAD7FF", bold = true })
			vim.api.nvim_set_hl(0, "PmenuExtra", { fg = "#AFAFAF", bg = "#121212" })
			vim.api.nvim_set_hl(0, "PmenuExtraSel", { fg = "#121212", bg = "#BAD7FF" })

			-- LSP Saga specific highlights to match theme
			vim.api.nvim_set_hl(0, "SagaNormal", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "SagaBorder", { fg = "#505050", bg = "#121212" })
			vim.api.nvim_set_hl(0, "SagaTitle", { fg = "#121212", bg = "#BAD7FF", bold = true })
			vim.api.nvim_set_hl(0, "SagaHover", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "SagaCodeAction", { fg = "#F4BF75", bold = true })
			vim.api.nvim_set_hl(0, "SagaRename", { fg = "#E1E1E1", bg = "#121212" })
			vim.api.nvim_set_hl(0, "SagaFinderSelection", { fg = "#E1E1E1", bg = "#2A2A2A", bold = true })
		end,
	})

	-- Apply all highlights immediately after theme load
	vim.schedule(function()
		vim.cmd("doautocmd ColorScheme")
	end)
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
								initial_mode = "normal",
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

	-- Symbols Outline - Traditional sidebar view (complements Telescope symbols)
	-- Provides a persistent sidebar with document symbols for quick overview
	-- Works great alongside the Telescope symbol pickers for different workflows
	{
		"simrat39/symbols-outline.nvim",
		keys = {
			{
				"<leader>ss",
				function()
					require("symbols-outline").toggle_outline()
				end,
				desc = "Toggle Symbols Outline",
			},
		},
		config = function()
			require("symbols-outline").setup({
				-- Enhanced symbols outline configuration with minimal padding
				highlight_hovered_item = true,
				show_guides = true,
				auto_preview = false, -- Disable auto preview to avoid conflicts with Telescope
				position = "right", -- Position on the right side
				relative_width = true,
				width = 25, -- 25% of screen width
				auto_close = false,
				show_numbers = false,
				show_relative_numbers = false,
				show_symbol_details = false, -- Reduce clutter by hiding extra details
				preview_bg_highlight = "Pmenu",
				autofold_depth = nil, -- Don't auto-fold any levels
				auto_unfold_hover = true,
				fold_markers = { "", "" }, -- Minimal fold markers
				wrap = false,
				-- Minimize spacing and padding for maximum space efficiency
				winblend = 0,
				border = "none", -- Remove border to save space
				cursor_follows_symbol = true,
				keymaps = { -- Custom keymaps for symbols outline
					close = {"<Esc>", "q"},
					goto_location = "<Cr>",
					focus_location = "o",
					hover_symbol = "<C-space>",
					toggle_preview = "K",
					rename_symbol = "r",
					code_actions = "a",
					fold = "h",
					unfold = "l",
					fold_all = "zM",
					unfold_all = "zR",
					fold_reset = "zE",
				},
				lsp_blacklist = {},
				symbol_blacklist = {},
				-- Optimize display for maximum space efficiency
				symbols_padding = 0, -- Remove symbol padding
				show_guides = false, -- Disable guide lines for cleaner look
				-- Enhanced symbol icons using the same icons as Telescope
				symbols = {
					File = { icon = "󰈔", hl = "@text.uri" },
					Module = { icon = "󰏖", hl = "@namespace" },
					Namespace = { icon = "󰌗", hl = "@namespace" },
					Package = { icon = "󰏗", hl = "@namespace" },
					Class = { icon = "󰠱", hl = "@type" },
					Method = { icon = "󰊕", hl = "@method" },
					Property = { icon = "󰜢", hl = "@method" },
					Field = { icon = "󰓹", hl = "@field" },
					Constructor = { icon = "󰆧", hl = "@constructor" },
					Enum = { icon = "󰕘", hl = "@type" },
					Interface = { icon = "󰜰", hl = "@type" },
					Function = { icon = "󰡱", hl = "@function" },
					Variable = { icon = "󰀫", hl = "@constant" },
					Constant = { icon = "󰏿", hl = "@constant" },
					String = { icon = "󰀬", hl = "@string" },
					Number = { icon = "󰎠", hl = "@number" },
					Boolean = { icon = "󰨙", hl = "@boolean" },
					Array = { icon = "󰅪", hl = "@constant" },
					Object = { icon = "󰅩", hl = "@type" },
					Key = { icon = "󰌋", hl = "@type" },
					Null = { icon = "󰟢", hl = "@type" },
					EnumMember = { icon = "󰕘", hl = "@field" },
					Struct = { icon = "󰙅", hl = "@type" },
					Event = { icon = "󰉁", hl = "@type" },
					Operator = { icon = "󰆕", hl = "@operator" },
					TypeParameter = { icon = "󰊄", hl = "@parameter" },
				},
			})

			-- Additional optimization: set compact window options when outline opens
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "Outline",
				callback = function()
					-- Maximize space utilization in the outline window
					vim.opt_local.signcolumn = "no"  -- Remove sign column
					vim.opt_local.foldcolumn = "0"   -- Remove fold column
					vim.opt_local.number = false     -- Ensure no line numbers
					vim.opt_local.relativenumber = false
					vim.opt_local.wrap = false       -- Ensure no wrapping
					vim.opt_local.cursorline = true  -- Highlight current line for better visibility
				end,
			})
		end,
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
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Context/Code-Actions" },
				{ "<leader>d", group = "Diagnostics/Debug" },
				{ "<leader>f", group = "File/Find" },
				{ "<leader>g", group = "Git/Goto" },
				{ "<leader>h", group = "Hunks/Git-Stage" },
				{ "<leader>i", group = "Info" },
				{ "<leader>m", group = "Bookmarks" },
				{ "<leader>n", group = "Navigation" },
				{ "<leader>r", group = "Rename/Refactor" },
				{ "<leader>s", group = "Split" },
				{ "<leader>t", group = "Terminal/Tabs" },
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

			-- Apply immediately
			vim.api.nvim_set_hl(0, "HighlightedyankRegion", {
				fg = "#121212",
				bg = "#F4BF75",
				bold = true
			})
		end,
	},
}
