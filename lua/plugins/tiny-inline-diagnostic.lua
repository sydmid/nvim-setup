-- Tiny Inline Diagnostic Plugin - Modern Neovim diagnostic display
-- A beautiful replacement for traditional diagnostic virtual text with better styling

return {
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy", -- Or use "LspAttach" for LSP-specific loading
		priority = 1000, -- Load before other diagnostic plugins
		config = function()
			-- Setup tiny-inline-diagnostic with modern configuration
			require("tiny-inline-diagnostic").setup({
				-- Use minimal preset for better space management
				preset = "minimal", -- Changed from "modern" to "minimal" for better overflow handling

				-- Background styling for better visibility
				transparent_bg = false,
				transparent_cursorline = true, -- Make cursor line background transparent

				-- Highlight groups configuration
				hi = {
					error = "DiagnosticError",
					warn = "DiagnosticWarn",
					info = "DiagnosticInfo",
					hint = "DiagnosticHint",
					arrow = "NonText",
					background = "CursorLine", -- Use CursorLine for background
					mixing_color = "#1e1e1e", -- Dark mixing color for better contrast
				},

				-- Custom signs and blend for better visual appeal
			  signs = {
    left = "",
    right = "",
    diag = "●",
    arrow = "    ",
    up_arrow = "    ",
    vertical = " │",
    vertical_end = " └",
  },
				blend = {
					factor = 0.27, -- Slightly more blending for softer appearance
				},

				-- Main options configuration
				options = {
					-- Show diagnostic source (e.g., pyright, lua_ls)
					show_source = {
						enabled = true,
						if_many = true, -- Only show source if multiple sources exist
					},

					-- Use icons from diagnostic configuration
					use_icons_from_diagnostic = true, -- Use standard diagnostic icons

					-- Color the arrow same as diagnostic severity
					set_arrow_to_diag_color = true,

					-- Always add messages to diagnostics
					add_messages = true,

					-- Throttle updates for better performance (reduced for more responsive cursor updates)
					throttle = 0, -- No throttle for immediate cursor response

					-- Soft wrap threshold (make it shorter for better readability and screen bounds)
					softwrap = 40,

					-- Multiline diagnostic configuration
					multilines = {
						enabled = true, -- Enable multiline diagnostics
						always_show = true, -- Show all lines when cursor is on diagnostic line
						trim_whitespaces = true, -- Clean up whitespace
						tabstop = 4, -- Convert tabs to 4 spaces
					},

					-- Show all diagnostics on cursor line for full message visibility
					show_all_diags_on_cursorline = true, -- Enable to show full messages on cursor line

					-- Keep disabled in insert mode for performance
					enable_on_insert = false,

					-- Enable diagnostics in Select mode
					enable_on_select = false,

					-- Overflow handling configuration - CRITICAL for screen bounds
					overflow = {
						mode = "wrap", -- Force wrapping to prevent overflow
						padding = 5, -- Add padding to trigger wrapping earlier
					},

					-- Break line configuration for long messages - CRITICAL
					break_line = {
						enabled = true, -- Enable line breaking
						after = 50, -- Break after 50 characters to stay within bounds
					},

					-- Smart format function that shows full message on cursor line
					format = function(diagnostic)
						local message = diagnostic.message or ""
						local source = diagnostic.source and (" [" .. diagnostic.source .. "]") or ""

						-- Get current cursor position
						local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- Convert to 0-based
						local diagnostic_line = diagnostic.lnum

						-- If cursor is on the diagnostic line, show full message
						if current_line == diagnostic_line then
							return message .. source
						end

						-- Otherwise, apply truncation for off-cursor lines
						local max_width = math.min(60, vim.o.columns - 25) -- More conservative when off-cursor
						local total_text = message .. source

						if #total_text > max_width then
							local truncated_msg = message:sub(1, max_width - #source - 3) .. "..."
							return truncated_msg .. source
						end

						return total_text
					end,

					-- Virtual text configuration
					virt_texts = {
						priority = 2048, -- High priority to show above other virtual text
					},

					-- Filter by severity (show only errors by default)
					severity = {
						vim.diagnostic.severity.ERROR,
						-- vim.diagnostic.severity.WARN,  -- Disabled by default
						-- vim.diagnostic.severity.INFO,  -- Disabled by default
						-- vim.diagnostic.severity.HINT,  -- Disabled by default
					},

					-- Don't override default events
					overwrite_events = nil,
				},

				-- Disable for specific filetypes
				disabled_ft = {
					"alpha",
					"dashboard",
					"help",
					"lazy",
					"mason",
					"neo-tree",
					"NvimTree",
					"notify",
					"oil",
					"TelescopePrompt",
					"TelescopeResults",
					"TelescopePreview",
					"trouble",
				},
			})

			-- Ensure virtual_text is disabled to avoid conflicts
			vim.diagnostic.config({ virtual_text = false })

			-- Create user commands for controlling the plugin
			vim.api.nvim_create_user_command("TinyDiagnosticToggle", function()
				require("tiny-inline-diagnostic").toggle()
			end, { desc = "Toggle Tiny Inline Diagnostic" })

			vim.api.nvim_create_user_command("TinyDiagnosticEnable", function()
				require("tiny-inline-diagnostic").enable()
			end, { desc = "Enable Tiny Inline Diagnostic" })

			vim.api.nvim_create_user_command("TinyDiagnosticDisable", function()
				require("tiny-inline-diagnostic").disable()
			end, { desc = "Disable Tiny Inline Diagnostic" })

			-- Add keymaps for easy control
			vim.keymap.set("n", "<leader>dt", function()
				require("tiny-inline-diagnostic").toggle()
			end, { desc = "Toggle Tiny Inline Diagnostics", silent = true })

			vim.keymap.set("n", "<leader>de", function()
				require("tiny-inline-diagnostic").enable()
			end, { desc = "Enable Tiny Inline Diagnostics", silent = true })

			vim.keymap.set("n", "<leader>dd", function()
				require("tiny-inline-diagnostic").disable()
			end, { desc = "Disable Tiny Inline Diagnostics", silent = true })

			-- Keymap to get diagnostic under cursor (useful for statusline)
			vim.keymap.set("n", "<leader>di", function()
				local diagnostic = require("tiny-inline-diagnostic").get_diagnostic_under_cursor()
				if diagnostic then
					vim.notify(diagnostic.message, vim.log.levels.INFO, { title = "Diagnostic Under Cursor" })
				else
					vim.notify("No diagnostic under cursor", vim.log.levels.INFO)
				end
			end, { desc = "Show diagnostic under cursor", silent = true })

			-- Diagnostic severity control keymaps in <leader>x group
			vim.keymap.set("n", "<leader>xe", function()
				-- Show only errors (default mode)
				require("tiny-inline-diagnostic").change_severities({ vim.diagnostic.severity.ERROR })
				vim.notify("🔴 Showing only ERROR diagnostics", vim.log.levels.INFO)
			end, { desc = "Show only errors", silent = true })

			vim.keymap.set("n", "<leader>xw", function()
				-- Show errors and warnings
				require("tiny-inline-diagnostic").change_severities({
					vim.diagnostic.severity.ERROR,
					vim.diagnostic.severity.WARN
				})
				vim.notify("🟠 Showing ERROR and WARN diagnostics", vim.log.levels.INFO)
			end, { desc = "Show errors and warnings", silent = true })

			vim.keymap.set("n", "<leader>xa", function()
				-- Show all diagnostics (errors, warnings, info, hints)
				require("tiny-inline-diagnostic").change_severities({
					vim.diagnostic.severity.ERROR,
					vim.diagnostic.severity.WARN,
					vim.diagnostic.severity.INFO,
					vim.diagnostic.severity.HINT,
				})
				vim.notify("🌈 Showing ALL diagnostics", vim.log.levels.INFO)
			end, { desc = "Show all diagnostics", silent = true })

			vim.keymap.set("n", "<leader>xi", function()
				-- Show errors, warnings, and info (no hints)
				require("tiny-inline-diagnostic").change_severities({
					vim.diagnostic.severity.ERROR,
					vim.diagnostic.severity.WARN,
					vim.diagnostic.severity.INFO,
				})
				vim.notify("🔵 Showing ERROR, WARN and INFO diagnostics", vim.log.levels.INFO)
			end, { desc = "Show errors, warnings, and info", silent = true })

			vim.keymap.set("n", "<leader>xh", function()
				-- Show only hints (useful for seeing suggestions)
				require("tiny-inline-diagnostic").change_severities({
					vim.diagnostic.severity.HINT,
				})
				vim.notify("💡 Showing only HINT diagnostics", vim.log.levels.INFO)
			end, { desc = "Show only hints", silent = true })

			vim.keymap.set("n", "<leader>xn", function()
				-- Hide all diagnostics (none)
				require("tiny-inline-diagnostic").change_severities({})
				vim.notify("🚫 Hiding all diagnostics", vim.log.levels.INFO)
			end, { desc = "Hide all diagnostics", silent = true })

			-- Add preset switching commands for visual customization
			vim.api.nvim_create_user_command("TinyDiagnosticPreset", function(opts)
				local preset = opts.args
				if preset == "" then
					vim.notify("Available presets: modern, classic, minimal, powerline, ghost, simple, nonerdfont, amongus", vim.log.levels.INFO)
					return
				end

				-- Re-setup with new preset
				require("tiny-inline-diagnostic").setup({
					preset = preset,
					transparent_bg = false,
					transparent_cursorline = true,
					hi = {
						error = "DiagnosticError",
						warn = "DiagnosticWarn",
						info = "DiagnosticInfo",
						hint = "DiagnosticHint",
						arrow = "NonText",
						background = "CursorLine",
						mixing_color = "#1e1e1e",
					},
					-- ...rest of options remain the same...
				})
				vim.notify("🎨 Switched to preset: " .. preset, vim.log.levels.INFO)
			end, {
				desc = "Switch Tiny Inline Diagnostic preset",
				nargs = "?",
				complete = function()
					return {"modern", "classic", "minimal", "powerline", "ghost", "simple", "nonerdfont", "amongus"}
				end
			})

			-- Quick preset switching keymaps
			vim.keymap.set("n", "<leader>dp", ":TinyDiagnosticPreset ", { desc = "Switch diagnostic preset" })

			-- Quick switches to popular presets
			vim.keymap.set("n", "<leader>dm", function()
				vim.cmd("TinyDiagnosticPreset modern")
			end, { desc = "Modern preset", silent = true })

			vim.keymap.set("n", "<leader>dc", function()
				vim.cmd("TinyDiagnosticPreset classic")
			end, { desc = "Classic preset", silent = true })

			vim.keymap.set("n", "<leader>dg", function()
				vim.cmd("TinyDiagnosticPreset ghost")
			end, { desc = "Ghost preset", silent = true })

			-- Custom highlight setup for better theme integration
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("TinyInlineDiagnosticHighlights", { clear = true }),
				callback = function()
					-- Custom highlights for tiny-inline-diagnostic that match your theme
					-- These will be applied after colorscheme changes with enhanced styling

					-- Error highlights with subtle background
					vim.api.nvim_set_hl(0, "TinyInlineDiagnosticVirtualTextError", {
						fg = "#ff6b6b", -- Brighter red for better visibility
						bg = "#2d1b1b", -- Dark red background
						italic = true,
						bold = false,
					})

					-- Warning highlights with subtle background
					vim.api.nvim_set_hl(0, "TinyInlineDiagnosticVirtualTextWarn", {
						fg = "#ffa726", -- Brighter orange for warnings
						bg = "#2d2416", -- Dark orange background
						italic = true,
						bold = false,
					})

					-- Info highlights with subtle background
					vim.api.nvim_set_hl(0, "TinyInlineDiagnosticVirtualTextInfo", {
						fg = "#42a5f5", -- Brighter blue for info
						bg = "#1a1f2e", -- Dark blue background
						italic = true,
						bold = false,
					})

					-- Hint highlights with subtle background
					vim.api.nvim_set_hl(0, "TinyInlineDiagnosticVirtualTextHint", {
						fg = "#26c6da", -- Brighter cyan for hints
						bg = "#1a2626", -- Dark cyan background
						italic = true,
						bold = false,
					})

					-- Arrow highlights with better visibility
					vim.api.nvim_set_hl(0, "TinyInlineDiagnosticVirtualTextArrow", {
						fg = "#666666", -- Medium gray for arrows
						bg = "NONE",
						bold = true,
					})

					-- Enhanced inverted background highlights for signs
					vim.api.nvim_set_hl(0, "TinyInlineInvDiagnosticVirtualTextError", {
						fg = "#ffffff", -- White text on colored background
						bg = "#ff6b6b", -- Error color background
						bold = true,
					})

					vim.api.nvim_set_hl(0, "TinyInlineInvDiagnosticVirtualTextWarn", {
						fg = "#000000", -- Black text for better contrast
						bg = "#ffa726",
						bold = true,
					})

					vim.api.nvim_set_hl(0, "TinyInlineInvDiagnosticVirtualTextInfo", {
						fg = "#ffffff",
						bg = "#42a5f5",
						bold = true,
					})

					vim.api.nvim_set_hl(0, "TinyInlineInvDiagnosticVirtualTextHint", {
						fg = "#000000",
						bg = "#26c6da",
						bold = true,
					})
				end,
			})

			-- Trigger the highlight setup immediately
			vim.cmd("doautocmd ColorScheme")

			-- Success notification
			vim.notify("🎨 Tiny Inline Diagnostic loaded with modern preset", vim.log.levels.INFO, {
				title = "Diagnostics",
				timeout = 2000
			})

			-- Add a command to fix width issues dynamically
			vim.api.nvim_create_user_command("TinyDiagnosticFixWidth", function()
				local current_width = vim.o.columns
				local safe_width = math.max(30, math.min(60, current_width - 30))

				-- Re-setup with width-aware configuration
				require("tiny-inline-diagnostic").setup({
					preset = "minimal",
					transparent_bg = false,
					transparent_cursorline = true,
					hi = {
						error = "DiagnosticError",
						warn = "DiagnosticWarn",
						info = "DiagnosticInfo",
						hint = "DiagnosticHint",
						arrow = "NonText",
						background = "CursorLine",
						mixing_color = "#1e1e1e",
					},
					options = {
						show_source = { enabled = false }, -- Disable source to save space
						use_icons_from_diagnostic = true,
						set_arrow_to_diag_color = true,
						add_messages = true,
						throttle = 10,
						softwrap = safe_width,
						multilines = { enabled = false }, -- Disable multilines
						show_all_diags_on_cursorline = false,
						enable_on_insert = false,
						enable_on_select = false,
						overflow = {
							mode = "wrap",
							padding = 10,
						},
						break_line = {
							enabled = true,
							after = safe_width - 10,
						},
						format = function(diagnostic)
							local message = diagnostic.message or ""
							if #message > safe_width then
								return message:sub(1, safe_width - 3) .. "..."
							end
							return message
						end,
						-- ...existing options...
					},
				})
				vim.notify("📏 Fixed width for " .. current_width .. " columns (max: " .. safe_width .. ")", vim.log.levels.INFO)
			end, { desc = "Fix diagnostic width for current screen size" })

			-- Auto-fix width on window resize
			vim.api.nvim_create_autocmd("VimResized", {
				group = vim.api.nvim_create_augroup("TinyDiagnosticAutoResize", { clear = true }),
				callback = function()
					vim.cmd("TinyDiagnosticFixWidth")
				end,
			})

			-- Add keymap for manual width fixing
			vim.keymap.set("n", "<leader>dw", ":TinyDiagnosticFixWidth<CR>", { desc = "Fix diagnostic width", silent = true })

			-- Add command to show full diagnostics temporarily
			vim.api.nvim_create_user_command("TinyDiagnosticShowFull", function()
				require("tiny-inline-diagnostic").setup({
					preset = "minimal",
					transparent_bg = false,
					transparent_cursorline = true,
					hi = {
						error = "DiagnosticError",
						warn = "DiagnosticWarn",
						info = "DiagnosticInfo",
						hint = "DiagnosticHint",
						arrow = "NonText",
						background = "CursorLine",
						mixing_color = "#1e1e1e",
					},
					options = {
						show_source = { enabled = true, if_many = true },
						use_icons_from_diagnostic = true,
						set_arrow_to_diag_color = true,
						add_messages = true,
						throttle = 0,
						softwrap = 120, -- Allow longer messages
						multilines = { enabled = true, always_show = true, trim_whitespaces = true, tabstop = 4 },
						show_all_diags_on_cursorline = true,
						enable_on_insert = false,
						enable_on_select = false,
						overflow = { mode = "wrap", padding = 0 },
						break_line = { enabled = false }, -- Disable breaking for full view
						format = function(diagnostic) -- Show everything without truncation
							local message = diagnostic.message or ""
							local source = diagnostic.source and (" [" .. diagnostic.source .. "]") or ""
							return message .. source
						end,
						virt_texts = { priority = 2048 },
						severity = {
							vim.diagnostic.severity.ERROR,
							vim.diagnostic.severity.WARN,
							vim.diagnostic.severity.INFO,
							vim.diagnostic.severity.HINT,
						},
						overwrite_events = nil,
					},
				})
				vim.notify("📝 Showing full diagnostic messages (no truncation)", vim.log.levels.INFO)
			end, { desc = "Show full diagnostic messages without truncation" })

			-- Add keymap for quickly showing full diagnostics
			vim.keymap.set("n", "<leader>df", ":TinyDiagnosticShowFull<CR>", { desc = "Show full diagnostics", silent = true })

			-- Add a cycling toggle for diagnostic levels
			local diagnostic_levels = {
				{ name = "Errors Only", severities = { vim.diagnostic.severity.ERROR }, icon = "🔴" },
				{ name = "Errors + Warnings", severities = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN }, icon = "🟠" },
				{ name = "Errors + Warnings + Info", severities = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN, vim.diagnostic.severity.INFO }, icon = "🔵" },
				{ name = "All Diagnostics", severities = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN, vim.diagnostic.severity.INFO, vim.diagnostic.severity.HINT }, icon = "🌈" },
			}
			local current_level = 1 -- Start with errors only

			vim.keymap.set("n", "<leader>xt", function()
				-- Cycle through diagnostic levels
				current_level = current_level % #diagnostic_levels + 1
				local level = diagnostic_levels[current_level]

				require("tiny-inline-diagnostic").change_severities(level.severities)
				vim.notify(level.icon .. " " .. level.name, vim.log.levels.INFO)
			end, { desc = "Toggle diagnostic levels", silent = true })

			-- Add a quick status display
			vim.keymap.set("n", "<leader>xs", function()
				local level = diagnostic_levels[current_level]
				vim.notify("Current: " .. level.icon .. " " .. level.name, vim.log.levels.INFO, { title = "Diagnostic Level" })
			end, { desc = "Show current diagnostic level", silent = true })
		end,
	},
}
