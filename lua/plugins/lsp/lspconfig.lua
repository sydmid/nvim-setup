return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{ "folke/neodev.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"glepnir/lspsaga.nvim",
			"Hoffs/omnisharp-extended-lsp.nvim",
		},
		config = function()
			-- Fix position_encoding warning
			local orig_util = vim.lsp.util
			local orig_make_position_params = orig_util.make_position_params
			orig_util.make_position_params = function(winnr, encoding)
				return orig_make_position_params(winnr, encoding or "utf-8")
			end

			-- Configure diagnostics for Error Lens integration
			-- Enhanced diagnostic configuration with Error Lens support
			vim.diagnostic.config({
				virtual_text = false, -- Disabled - Error Lens handles inline display
				signs = {
					severity = { min = vim.diagnostic.severity.HINT }, -- Show all diagnostic signs
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.INFO] = " ",
						[vim.diagnostic.severity.HINT] = " ",
					}
				},
				underline = {
					severity = { min = vim.diagnostic.severity.HINT } -- Underline all diagnostics
				},
				update_in_insert = false,
				severity_sort = true,
				float = {
					focusable = false,
					style = "minimal",
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
					format = function(diagnostic)
						-- Enhanced formatting for floating diagnostics
						local severity_map = {
							[vim.diagnostic.severity.ERROR] = "ERROR",
							[vim.diagnostic.severity.WARN] = "WARN",
							[vim.diagnostic.severity.INFO] = "INFO",
							[vim.diagnostic.severity.HINT] = "HINT"
						}
						local severity = severity_map[diagnostic.severity] or "UNKNOWN"
						local code = diagnostic.code and string.format(" [%s]", diagnostic.code) or ""
						return string.format("%s: %s%s", severity, diagnostic.message, code)
					end,
				},
			})

			-- Configure LSP signature help with improved styling and fixed dimensions
			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
				focusable = true,  -- Make it focusable for navigation
				silent = true,
				close_events = { "BufHidden", "InsertCharPre" },  -- Remove CursorMoved to keep it open
				max_width = 80,
				max_height = 15,
				wrap = true,
				-- Custom styling
				style = "minimal",
				-- Position the window near the cursor
				anchor_bias = "below",
				-- Force window dimensions
				width = 80,
				height = 15,
				-- Additional styling options
				title = " Signature Help ",
				title_pos = "center",
				-- Window position
				relative = "cursor",
				row = 1,
				col = 0,
			})

			-- Configure LSP hover with consistent styling
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
				focusable = true,
				style = "minimal",
				max_width = 80,
				max_height = 15,
				wrap = true,
				title = " Documentation ",
				title_pos = "center",
				close_events = { "BufHidden" }, -- Only close when leaving buffer, not on cursor movement
			})

			-- Custom highlight groups for LSP floating windows to match theme
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("CustomLspHighlights", {}),
				callback = function()
					-- LSP signature help styling with no-clown-fiesta theme
					vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", {
						bg = "#2A2A2A",
						fg = "#F4BF75",
						bold = true,
						italic = true
					})
					-- Ensure all floating windows match Telescope background
					vim.api.nvim_set_hl(0, "FloatBorder", {
						fg = "#505050",
						bg = "#121212"
					})
					vim.api.nvim_set_hl(0, "NormalFloat", {
						bg = "#121212",
						fg = "#E1E1E1"
					})
					vim.api.nvim_set_hl(0, "FloatTitle", {
						bg = "#BAD7FF",
						fg = "#121212",
						bold = true
					})
					-- Enhanced highlight for LSP reference previews
					vim.api.nvim_set_hl(0, "TelescopePreviewLine", {
						bg = "#2A2A2A",
						fg = "#E1E1E1"
					})
				end,
			})

			-- Trigger the highlight setup immediately
			vim.cmd("doautocmd ColorScheme")

			-- Custom signature help function with better window management
			local function show_signature_help()
				local params = vim.lsp.util.make_position_params()
				vim.lsp.buf_request(0, 'textDocument/signatureHelp', params, function(err, result, ctx, config)
					if err or not result or not result.signatures or #result.signatures == 0 then
						return
					end

					-- Custom window configuration
					local opts = {
						border = "rounded",
						focusable = true,
						style = "minimal",
						max_width = 80,
						max_height = 15,
						wrap = true,
						title = " Signature Help ",
						title_pos = "center",
						close_events = { "BufHidden" },
					}

					vim.lsp.handlers["textDocument/signatureHelp"](err, result, ctx, vim.tbl_extend("force", config or {}, opts))
				end)
			end

			-- Setup LSP
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Disable signature help capability to prevent auto-suggestions
			capabilities.textDocument.signatureHelp = nil

			local lspconfig = require("lspconfig")
			local mason_lspconfig = require("mason-lspconfig")


			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }
					local keymap = vim.keymap.set
					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					-- C# specific keymaps with omnisharp-extended
					if client and client.name == "omnisharp" then
						-- Enhanced LSP keymaps for C# with omnisharp-extended decompilation support
						keymap("n", "gd", function()
							require("omnisharp_extended").lsp_definitions()
						end, { buffer = ev.buf, desc = "Go to definition (with decompilation)" })

						keymap("n", "<leader>pd", function()
							require("omnisharp_extended").lsp_definitions()
						end, { buffer = ev.buf, desc = "Peek definition (with decompilation)" })

						keymap("n", "<leader>us", function()
							-- Get current position to filter out keymap definitions
							local current_buf = vim.api.nvim_get_current_buf()
							local current_line = vim.api.nvim_win_get_cursor(0)[1]
							local current_file = vim.api.nvim_buf_get_name(current_buf)

							-- Use omnisharp-extended but with filtering
							local params = vim.lsp.util.make_position_params()
							local bufnr = vim.api.nvim_get_current_buf()

							vim.lsp.buf_request(bufnr, "textDocument/references", params, function(err, result, ctx, config)
								if err then
									vim.notify("LSP references error: " .. tostring(err), vim.log.levels.ERROR)
									return
								end

								if not result or vim.tbl_isempty(result) then
									vim.notify("No references found", vim.log.levels.INFO)
									return
								end

								-- Filter out current line references
								local filtered_result = {}
								for _, ref in ipairs(result) do
									local uri = ref.uri
									local file_path = vim.uri_to_fname(uri)
									local line_num = ref.range.start.line + 1 -- Convert to 1-based

									-- Skip if it's the same file and same line
									if not (file_path == current_file and line_num == current_line) then
										table.insert(filtered_result, ref)
									end
								end

								if vim.tbl_isempty(filtered_result) then
									vim.notify("No external references found", vim.log.levels.INFO)
									return
								end

								-- Convert to quickfix format and show in telescope
								local qf_list = vim.lsp.util.locations_to_items(filtered_result, vim.lsp.get_client_by_id(ctx.client_id).offset_encoding)

								require("telescope.builtin").quickfix({
									initial_mode = "normal",
									path_display = { "smart" },
									-- Force preview to show even for single results
									preview = {
										check_mime_type = false,
										hide_on_startup = false,
									},
									layout_config = {
										preview_width = 0.6,
										width = 0.9,
										height = 0.8,
									},
									selection_strategy = "reset",
									sorting_strategy = "ascending",
									attach_mappings = function(prompt_bufnr, map_func)
										local actions = require("telescope.actions")
										local action_state = require("telescope.actions.state")

										-- Custom mapping to ensure preview is triggered
										local function ensure_preview()
											local selection = action_state.get_selected_entry()
											if selection then
												-- Force preview refresh
												require("telescope.actions").preview_scrolling_up(prompt_bufnr)
												require("telescope.actions").preview_scrolling_down(prompt_bufnr)
											end
										end

										map_func("i", "<Esc>", actions.close)
										map_func("n", "<Esc>", actions.close)
										map_func("n", "q", actions.close)

										-- Add preview refresh on movement
										map_func("n", "j", function()
											actions.move_selection_next(prompt_bufnr)
											ensure_preview()
										end)
										map_func("n", "k", function()
											actions.move_selection_previous(prompt_bufnr)
											ensure_preview()
										end)

										return true
									end,
									-- Enhanced display
									entry_maker = function(entry)
										local make_entry = require("telescope.make_entry")
										local default_entry = make_entry.gen_from_quickfix({})(entry)

										if default_entry then
											default_entry.display = function(ent)
												local path_display = require("telescope.utils").path_smart(ent.filename)
												local line_preview = ent.text and ent.text:gsub("^%s+", "") or ""
												return string.format("%s:%d:%d │ %s", path_display, ent.lnum, ent.col, line_preview)
											end
										end

										return default_entry
									end,
									-- Enhanced previewer for C# references (same as non-C# version)
									previewer = require("telescope.previewers").new_buffer_previewer({
										title = "C# LSP References",
										dyn_title = function(_, entry)
											if entry and entry.filename then
												return vim.fn.fnamemodify(entry.filename, ":t")
											end
											return "C# LSP References"
										end,
										get_buffer_by_name = function(_, entry)
											return entry and entry.filename or ""
										end,
										define_preview = function(self, entry, status)
											if not entry or not entry.filename then
												return
											end

											-- Enhanced preview function with better initialization
											local function setup_preview_and_highlight()
												if not entry.lnum or not self.state.winid or not vim.api.nvim_win_is_valid(self.state.winid) then
													return
												end

												-- Set cursor position with better error handling
												pcall(vim.api.nvim_win_set_cursor, self.state.winid, { entry.lnum, math.max(0, (entry.col or 1) - 1) })

												-- Center the line in the window
												pcall(vim.api.nvim_win_call, self.state.winid, function()
													vim.cmd("normal! zz")
												end)

												-- Clear previous highlights
												pcall(vim.api.nvim_buf_clear_namespace, self.state.bufnr, -1, 0, -1)

												-- Apply highlighting with enhanced logic
												if entry.lnum and entry.col then
													-- First, highlight the entire line
													pcall(vim.api.nvim_buf_add_highlight,
														self.state.bufnr,
														-1,
														"TelescopePreviewLine",
														entry.lnum - 1,
														0,
														-1
													)

													-- Then highlight the specific symbol
													local lines = vim.api.nvim_buf_get_lines(self.state.bufnr, entry.lnum - 1, entry.lnum, false)
													if lines and lines[1] then
														local line_text = lines[1]
														local col = math.max(0, entry.col - 1)

														-- Find word boundaries
														local start_col = col
														local end_col = col

														while start_col > 0 and line_text:sub(start_col, start_col):match("[%w_]") do
															start_col = start_col - 1
														end
														if start_col < col and not line_text:sub(start_col + 1, start_col + 1):match("[%w_]") then
															start_col = start_col + 1
														end

														while end_col < #line_text and line_text:sub(end_col + 1, end_col + 1):match("[%w_]") do
															end_col = end_col + 1
														end

														-- Apply symbol highlight
														if end_col >= start_col then
															pcall(vim.api.nvim_buf_add_highlight,
																self.state.bufnr,
																-1,
																"TelescopeMatching",
																entry.lnum - 1,
																start_col,
																end_col + 1
															)
														end
													end
												end
											end

											-- Robust preview with multiple attempts
											local ok = pcall(function()
												require("telescope.previewers").buffer_previewer_maker(entry.filename, self.state.bufnr, {
													bufname = self.state.bufname,
													winid = self.state.winid,
													preview = {
														mime_type = vim.filetype.match({ filename = entry.filename }),
													},
												})

												-- Multiple scheduling attempts
												setup_preview_and_highlight()
												vim.schedule(function()
													setup_preview_and_highlight()
												end)
												vim.defer_fn(function()
													setup_preview_and_highlight()
												end, 10)
												vim.defer_fn(function()
													setup_preview_and_highlight()
												end, 50)
											end)

											if not ok then
												-- Fallback
												pcall(require("telescope.previewers").buffer_previewer_maker, entry.filename, self.state.bufnr, {
													bufname = self.state.bufname,
													winid = self.state.winid,
												})
												vim.defer_fn(function()
													setup_preview_and_highlight()
												end, 100)
											end
										end
									}),
								})
							end)
						end, { buffer = ev.buf, desc = "Find references (enhanced)" })

						keymap("n", "<leader>ii", function()
							require("omnisharp_extended").lsp_implementation()
						end, { buffer = ev.buf, desc = "Find implementations (enhanced)" })

						keymap("n", "gt", function()
							require("omnisharp_extended").lsp_type_definition()
						end, { buffer = ev.buf, desc = "Go to type definition (enhanced)" })
					else
						-- Standard LSP navigation commands for non-C# files
						keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { buffer = ev.buf, desc = "Go to definition" })
						keymap("n", "<leader>pd", "<cmd>Lspsaga peek_definition<CR>", { buffer = ev.buf, desc = "Peek definition" })
						keymap("n", "<leader>us", function()
							require("telescope.builtin").lsp_references({
								initial_mode = "normal",
								path_display = { "smart" },
								include_declaration = false, -- Exclude the declaration itself
								include_current_line = false, -- Custom option we'll handle
								-- Force preview to show even for single results
								preview = {
									check_mime_type = false,
									hide_on_startup = false,
								},
								layout_config = {
									preview_width = 0.6,
									width = 0.9,
									height = 0.8,
								},
								-- Ensure first result is selected and previewed
								selection_strategy = "reset",
								sorting_strategy = "ascending",
								attach_mappings = function(prompt_bufnr, map_func)
									local actions = require("telescope.actions")
									local action_state = require("telescope.actions.state")

									-- Custom mapping to ensure preview is triggered
									local function ensure_preview()
										local selection = action_state.get_selected_entry()
										if selection then
											-- Force preview refresh
											require("telescope.actions").preview_scrolling_up(prompt_bufnr)
											require("telescope.actions").preview_scrolling_down(prompt_bufnr)
										end
									end

									map_func("i", "<Esc>", actions.close)
									map_func("n", "<Esc>", actions.close)
									map_func("n", "q", actions.close)

									-- Add preview refresh on movement
									map_func("n", "j", function()
										actions.move_selection_next(prompt_bufnr)
										ensure_preview()
									end)
									map_func("n", "k", function()
										actions.move_selection_previous(prompt_bufnr)
										ensure_preview()
									end)

									return true
								end,
								-- Filter out the current line to avoid showing keymap definitions
								entry_maker = function(entry)
									local make_entry = require("telescope.make_entry")
									local default_entry = make_entry.gen_from_quickfix({})(entry)

									if default_entry then
										-- Get current buffer and line
										local current_buf = vim.api.nvim_get_current_buf()
										local current_line = vim.api.nvim_win_get_cursor(0)[1]
										local current_file = vim.api.nvim_buf_get_name(current_buf)

										-- Filter out references from the same line in the same file
										if entry.filename == current_file and entry.lnum == current_line then
											return nil -- Skip this entry
										end

										-- Enhanced display with better formatting
										default_entry.display = function(ent)
											local path_display = require("telescope.utils").path_smart(ent.filename)
											local line_preview = ent.text and ent.text:gsub("^%s+", "") or "" -- Trim leading whitespace
											return string.format("%s:%d:%d │ %s", path_display, ent.lnum, ent.col, line_preview)
										end
									end

									return default_entry
								end,
								-- Enhanced previewer for better reliability
								previewer = require("telescope.previewers").new_buffer_previewer({
									title = "LSP References",
									dyn_title = function(_, entry)
										if entry and entry.filename then
											return vim.fn.fnamemodify(entry.filename, ":t")
										end
										return "LSP References"
									end,
									get_buffer_by_name = function(_, entry)
										return entry and entry.filename or ""
									end,
									define_preview = function(self, entry, status)
										if not entry or not entry.filename then
											return
										end

										-- Enhanced preview function with better initialization
										local function setup_preview_and_highlight()
											if not entry.lnum or not self.state.winid or not vim.api.nvim_win_is_valid(self.state.winid) then
												return
											end

											-- Set cursor position with better error handling
											pcall(vim.api.nvim_win_set_cursor, self.state.winid, { entry.lnum, math.max(0, (entry.col or 1) - 1) })

											-- Center the line in the window
											pcall(vim.api.nvim_win_call, self.state.winid, function()
												vim.cmd("normal! zz")
											end)

											-- Clear previous highlights
											pcall(vim.api.nvim_buf_clear_namespace, self.state.bufnr, -1, 0, -1)

											-- Apply highlighting with enhanced logic
											if entry.lnum and entry.col then
												-- First, highlight the entire line with a subtle background
												pcall(vim.api.nvim_buf_add_highlight,
													self.state.bufnr,
													-1,
													"TelescopePreviewLine",
													entry.lnum - 1,
													0,
													-1
												)

												-- Then highlight the specific symbol with a more prominent color
												local lines = vim.api.nvim_buf_get_lines(self.state.bufnr, entry.lnum - 1, entry.lnum, false)
												if lines and lines[1] then
													local line_text = lines[1]
													local col = math.max(0, entry.col - 1)

													-- Find word boundaries for the symbol
													local start_col = col
													local end_col = col

													-- Expand to word boundaries
													while start_col > 0 and line_text:sub(start_col, start_col):match("[%w_]") do
														start_col = start_col - 1
													end
													if start_col < col and not line_text:sub(start_col + 1, start_col + 1):match("[%w_]") then
														start_col = start_col + 1
													end

													while end_col < #line_text and line_text:sub(end_col + 1, end_col + 1):match("[%w_]") do
														end_col = end_col + 1
													end

													-- Apply symbol highlight with bright color
													if end_col >= start_col then
														pcall(vim.api.nvim_buf_add_highlight,
															self.state.bufnr,
															-1,
															"TelescopeMatching",
															entry.lnum - 1,
															start_col,
															end_col + 1
														)
													end
												end
											end
										end

										-- Robust preview with multiple attempts and error handling
										local ok = pcall(function()
											require("telescope.previewers").buffer_previewer_maker(entry.filename, self.state.bufnr, {
												bufname = self.state.bufname,
												winid = self.state.winid,
												preview = {
													mime_type = vim.filetype.match({ filename = entry.filename }),
												},
											})

											-- Multiple scheduling attempts to ensure highlighting works
											-- Immediate attempt
											setup_preview_and_highlight()

											-- Scheduled attempt for better reliability
											vim.schedule(function()
												setup_preview_and_highlight()
											end)

											-- Delayed attempt for edge cases (especially single results)
											vim.defer_fn(function()
												setup_preview_and_highlight()
											end, 10)

											-- Additional delayed attempt for very slow loading
											vim.defer_fn(function()
												setup_preview_and_highlight()
											end, 50)
										end)

										if not ok then
											-- Fallback: show file content without special positioning
											pcall(require("telescope.previewers").buffer_previewer_maker, entry.filename, self.state.bufnr, {
												bufname = self.state.bufname,
												winid = self.state.winid,
											})
											-- Still try to apply highlighting even in fallback
											vim.defer_fn(function()
												setup_preview_and_highlight()
											end, 100)
										end
									end
								}),
								-- Force preview on single result by customizing telescope behavior
								default_selection_index = 1,
							})
						end, { buffer = ev.buf, desc = "Find references" })
						keymap("n", "<leader>ii", function()
							require("telescope.builtin").lsp_implementations({
								initial_mode = "normal",
								attach_mappings = function(prompt_bufnr, map_func)
									local actions = require("telescope.actions")
									map_func("i", "<Esc>", actions.close)
									map_func("n", "<Esc>", actions.close)
									map_func("n", "q", actions.close)
									return true
								end,
							})
						end, { buffer = ev.buf, desc = "Find implementations" })
						keymap("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>", { buffer = ev.buf, desc = "Go to type definition" })
					end

					-- Common LSP keymaps for all languages
					keymap("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
					keymap("n", "<leader>pt", "<cmd>Lspsaga peek_type_definition<CR>", { buffer = ev.buf, desc = "Peek type definition" })

					-- Manual signature help triggers (auto-suggestions disabled)
					-- Use <D-S-i> (Cmd+Shift+I) to manually show function signatures when needed
					keymap("n", "<D-S-i>", function()
						show_signature_help()
					end, { buffer = ev.buf, desc = "Show method signature (manual)", silent = true })

					keymap("i", "<D-S-i>", function()
						show_signature_help()
					end, { buffer = ev.buf, desc = "Show method signature (manual)", silent = true })

					-- Signature help navigation between overloads
					keymap("i", "<C-k>", function()
						if vim.fn.pumvisible() == 0 then
							-- Navigate to previous signature overload
							local params = vim.lsp.util.make_position_params()
							vim.lsp.buf_request(0, 'textDocument/signatureHelp', params, function(err, result, ctx, config)
								if result and result.signatures and #result.signatures > 1 then
									local current = result.activeSignature or 0
									local prev = current > 0 and current - 1 or #result.signatures - 1
									result.activeSignature = prev

									local opts = {
										border = "rounded",
										focusable = true,
										style = "minimal",
										max_width = 80,
										max_height = 15,
										wrap = true,
										title = " Signature Help (" .. (prev + 1) .. "/" .. #result.signatures .. ") ",
										title_pos = "center",
									}
									vim.lsp.handlers["textDocument/signatureHelp"](err, result, ctx, vim.tbl_extend("force", config or {}, opts))
								else
									show_signature_help()
								end
							end)
						else
							vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-p>", true, false, true), "n", false)
						end
					end, { buffer = ev.buf, desc = "Previous signature overload or completion", silent = true })

					keymap("i", "<C-j>", function()
						if vim.fn.pumvisible() == 0 then
							-- Navigate to next signature overload
							local params = vim.lsp.util.make_position_params()
							vim.lsp.buf_request(0, 'textDocument/signatureHelp', params, function(err, result, ctx, config)
								if result and result.signatures and #result.signatures > 1 then
									local current = result.activeSignature or 0
									local next = (current + 1) % #result.signatures
									result.activeSignature = next

									local opts = {
										border = "rounded",
										focusable = true,
										style = "minimal",
										max_width = 80,
										max_height = 15,
										wrap = true,
										title = " Signature Help (" .. (next + 1) .. "/" .. #result.signatures .. ") ",
										title_pos = "center",
									}
									vim.lsp.handlers["textDocument/signatureHelp"](err, result, ctx, vim.tbl_extend("force", config or {}, opts))
								else
									show_signature_help()
								end
							end)
						else
							vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", false)
						end
					end, { buffer = ev.buf, desc = "Next signature overload or completion", silent = true })

					-- Auto-trigger signature help when typing function parameters (DISABLED)
					-- local function auto_signature_help()
					-- 	if vim.fn.pumvisible() == 0 then
					-- 		show_signature_help()
					-- 	end
					-- end

					-- Auto-trigger on opening parentheses and commas (DISABLED - use manual trigger <D-S-i> instead)
					-- keymap("i", "(", function()
					-- 	vim.api.nvim_feedkeys("(", "n", false)
					-- 	vim.defer_fn(auto_signature_help, 100)
					-- end, { buffer = ev.buf, desc = "Auto-trigger signature help", silent = true })

					-- keymap("i", ",", function()
					-- 	vim.api.nvim_feedkeys(",", "n", false)
					-- 	vim.defer_fn(auto_signature_help, 100)
					-- end, { buffer = ev.buf, desc = "Auto-trigger signature help", silent = true })

					-- Enhanced hover with beautiful styling and proper persistence
					keymap("n", "<D-i>", function()
						-- Get LSP clients for current buffer
						local clients = vim.lsp.get_clients({ bufnr = 0 })
						if #clients == 0 then
							vim.notify("No LSP client attached to current buffer", vim.log.levels.WARN)
							return
						end

						-- Use vim.lsp.buf.hover with enhanced configuration
						local params = vim.lsp.util.make_position_params()

						-- Create custom hover handler with enhanced styling
						local function enhanced_hover_handler(err, result, ctx, config)
							if err then
								vim.notify("LSP hover error: " .. tostring(err), vim.log.levels.ERROR)
								return
							end

							if not result or not result.contents then
								vim.notify("No hover information available", vim.log.levels.INFO)
								return
							end

							-- Enhanced window configuration matching peek_definition style
							local opts = vim.tbl_extend("force", config or {}, {
								border = "rounded",
								focusable = true,
								style = "minimal",
								max_width = 80,
								max_height = 15,
								wrap = true,
								title = " Documentation ",
								title_pos = "center",
								close_events = { "BufHidden" }, -- Only close on buffer change, not cursor movement
							})

							-- Call the default hover handler with our custom styling
							vim.lsp.handlers["textDocument/hover"](err, result, ctx, opts)
						end

						-- Make the hover request with our enhanced handler
						vim.lsp.buf_request(0, 'textDocument/hover', params, enhanced_hover_handler)
					end, { buffer = ev.buf, desc = "Show documentation (Enhanced)", silent = true })

					-- Fallback hover using native LSP hover (for troubleshooting)
					keymap("n", "<D-S-h>", function()
						vim.lsp.buf.hover()
					end, { buffer = ev.buf, desc = "Show documentation (Native)", silent = true })

					-- Debug command to test LSP hover capability
					keymap("n", "<leader>dh", function()
						local clients = vim.lsp.get_clients({ bufnr = 0 })
						if #clients == 0 then
							vim.notify("No LSP clients attached", vim.log.levels.ERROR)
							return
						end

						local client_info = {}
						for _, client in ipairs(clients) do
							table.insert(client_info, string.format("%s (hover: %s)",
								client.name,
								client.server_capabilities.hoverProvider and "yes" or "no"
							))
						end

						vim.notify("LSP clients: " .. table.concat(client_info, ", "), vim.log.levels.INFO)

						-- Test hover
						local params = vim.lsp.util.make_position_params()
						vim.lsp.buf_request(0, 'textDocument/hover', params, function(err, result, ctx, config)
							if err then
								vim.notify("Hover error: " .. tostring(err), vim.log.levels.ERROR)
							elseif not result or not result.contents then
								vim.notify("No hover content available", vim.log.levels.WARN)
							else
								vim.notify("Hover content received successfully", vim.log.levels.INFO)
								-- Show the content
								vim.lsp.handlers["textDocument/hover"](err, result, ctx, config)
							end
						end)
					end, { buffer = ev.buf, desc = "Debug hover functionality", silent = true })

					-- Additional useful Lspsaga keymaps
					keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { buffer = ev.buf, desc = "Code actions (Lspsaga)" })
					keymap("n", "<leader>lr", "<cmd>Lspsaga rename<CR>", { buffer = ev.buf, desc = "Rename symbol (Lspsaga)" })
					keymap("n", "<leader>lf", "<cmd>Lspsaga finder<CR>", { buffer = ev.buf, desc = "LSP finder" })
					keymap("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { buffer = ev.buf, desc = "LSP outline" })

					-- Standard actions (maintaining backward compatibility)
					keymap("n", "<leader>r", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename symbol" })

					-- Enhanced line diagnostics with better formatting (replacing lspsaga)
					keymap("n", "<leader>xx", function()
						-- Use vim's native diagnostics with enhanced formatting
						local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })

						if #diagnostics == 0 then
							vim.notify("No diagnostics found on current line", vim.log.levels.INFO)
							return
						end

						-- Create a comprehensive diagnostic display
						local lines = {}
						local severity_icons = {
							[vim.diagnostic.severity.ERROR] = " ",
							[vim.diagnostic.severity.WARN] = " ",
							[vim.diagnostic.severity.INFO] = " ",
							[vim.diagnostic.severity.HINT] = " ",
						}

						local severity_names = {
							[vim.diagnostic.severity.ERROR] = "ERROR",
							[vim.diagnostic.severity.WARN] = "WARN",
							[vim.diagnostic.severity.INFO] = "INFO",
							[vim.diagnostic.severity.HINT] = "HINT",
						}

						table.insert(lines, "Line " .. vim.fn.line('.') .. " Diagnostics:")
						table.insert(lines, "")

						for i, diagnostic in ipairs(diagnostics) do
							local icon = severity_icons[diagnostic.severity] or "󰌶"
							local severity = severity_names[diagnostic.severity] or "UNKNOWN"
							local source = diagnostic.source and (" [" .. diagnostic.source .. "]") or ""
							local code = diagnostic.code and (" (" .. diagnostic.code .. ")") or ""

							table.insert(lines, string.format("%s %s%s%s", icon, severity, source, code))
							table.insert(lines, "  " .. diagnostic.message)

							if i < #diagnostics then
								table.insert(lines, "")
							end
						end

						-- Show in a floating window with better styling
						local buf = vim.api.nvim_create_buf(false, true)
						vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

						-- Set buffer filetype for syntax highlighting
						vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')

						local width = math.min(80, vim.o.columns - 4)
						local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.4))

						local win = vim.api.nvim_open_win(buf, false, {
							relative = 'cursor',
							width = width,
							height = height,
							row = 1,
							col = 0,
							border = 'rounded',
							style = 'minimal',
							title = ' Line Diagnostics ',
							title_pos = 'center',
							focusable = true, -- Make it focusable for better interaction
						})

						-- Set window options
						vim.api.nvim_win_set_option(win, 'wrap', true)
						vim.api.nvim_win_set_option(win, 'linebreak', true)

						-- Auto-close on buffer change or insert mode (removed CursorMoved for stability)
						local group = vim.api.nvim_create_augroup('LineDiagnosticFloat', { clear = true })
						vim.api.nvim_create_autocmd({'BufLeave', 'InsertEnter'}, {
							group = group,
							buffer = vim.api.nvim_get_current_buf(),
							once = true,
							callback = function()
								if vim.api.nvim_win_is_valid(win) then
									vim.api.nvim_win_close(win, true)
								end
								vim.api.nvim_del_augroup_by_id(group)
							end,
						})

						-- Auto-close after 10 seconds (timeout)
						vim.defer_fn(function()
							if vim.api.nvim_win_is_valid(win) then
								vim.api.nvim_win_close(win, true)
							end
							pcall(vim.api.nvim_del_augroup_by_id, group)
						end, 10000)

						-- Add keymap to close manually
						vim.keymap.set('n', '<Esc>', function()
							if vim.api.nvim_win_is_valid(win) then
								vim.api.nvim_win_close(win, true)
							end
						end, { buffer = buf, nowait = true })

						vim.keymap.set('n', 'q', function()
							if vim.api.nvim_win_is_valid(win) then
								vim.api.nvim_win_close(win, true)
							end
						end, { buffer = buf, nowait = true })
					end, { buffer = ev.buf, desc = "Line diagnostics (enhanced native)" })
					keymap("n", "<leader>fx", function()
						require("telescope.builtin").diagnostics({
							bufnr = 0,
							attach_mappings = function(prompt_bufnr, map_func)
								local actions = require("telescope.actions")
								map_func("i", "<Esc>", actions.close)
								map_func("n", "<Esc>", actions.close)
								map_func("n", "q", actions.close)
								return true
							end,
						})
					end, { buffer = ev.buf, desc = "Buffer diagnostics" })

					-- Enhanced diagnostic navigation that works with Error Lens
					keymap("n", "<leader>xj", function()
						vim.diagnostic.goto_next()
						-- Trigger Error Lens update after navigation
						if _G.ErrorLens and _G.ErrorLens.enabled then
							vim.defer_fn(function()
								_G.ErrorLens.refresh_current_buffer()
							end, 50)
						end
					end, { buffer = ev.buf, desc = "Next diagnostic (with Error Lens sync)" })

					keymap("n", "<leader>xk", function()
						vim.diagnostic.goto_prev()
						-- Trigger Error Lens update after navigation
						if _G.ErrorLens and _G.ErrorLens.enabled then
							vim.defer_fn(function()
								_G.ErrorLens.refresh_current_buffer()
							end, 50)
						end
					end, { buffer = ev.buf, desc = "Previous diagnostic (with Error Lens sync)" })

					keymap("n", "<D-]>", function()
						vim.diagnostic.goto_next()
						if _G.ErrorLens and _G.ErrorLens.enabled then
							vim.defer_fn(function()
								_G.ErrorLens.refresh_current_buffer()
							end, 50)
						end
					end, { buffer = ev.buf, desc = "Next diagnostic (with Error Lens sync)" })

					keymap("n", "<D-[>", function()
						vim.diagnostic.goto_prev()
						if _G.ErrorLens and _G.ErrorLens.enabled then
							vim.defer_fn(function()
								_G.ErrorLens.refresh_current_buffer()
							end, 50)
						end
					end, { buffer = ev.buf, desc = "Previous diagnostic (with Error Lens sync)" })
				end,
			})

			-- Handle servers
			if mason_lspconfig.setup_handlers then
				mason_lspconfig.setup_handlers({
					function(server_name)
						lspconfig[server_name].setup({ capabilities = capabilities })
					end,

					-- Special server configs
					["lua_ls"] = function()
						lspconfig.lua_ls.setup({
							capabilities = capabilities,
							settings = {
								Lua = {
									diagnostics = { globals = { "vim" } },
									completion = { callSnippet = "Replace" },
								},
							},
						})
					end,

					["bashls"] = function()
						lspconfig.bashls.setup({
							capabilities = capabilities,
							filetypes = { "sh", "bash", "zsh" },
							-- Associate common shell config files with appropriate filetypes
							-- This ensures files like .zshrc, .bashrc are properly recognized
							init_options = {
								filetypes = { "sh", "bash", "zsh" },
							},
							-- Disable the built-in shellcheck in bashls to avoid duplicate diagnostics
							settings = {
								bashIde = {
									shellcheckPath = "", -- Empty string disables shellcheck in bashls
								},
							},
						})
					end,

					["pyright"] = function()
						-- Professional Python LSP configuration
						lspconfig.pyright.setup({
							capabilities = capabilities,
							settings = {
								pyright = {
									-- Using Ruff's import organizer
									disableOrganizeImports = true,
									-- Disable some features that Ruff handles better
									disableTaggedHints = false,
								},
								python = {
									analysis = {
										-- Enhanced type checking
										typeCheckingMode = "strict",
										-- Auto-import completions
										autoImportCompletions = true,
										-- Use workspace libraries
										useLibraryCodeForTypes = true,
										-- Diagnostic modes
										diagnosticMode = "workspace",
										-- Auto-search paths
										autoSearchPaths = true,
										-- Stub path
										stubPath = "typings",
										-- Extra paths for analysis
										extraPaths = {},
										-- Diagnostic severity overrides
										diagnosticSeverityOverrides = {
											reportMissingTypeStubs = "none",
											reportUnknownParameterType = "none",
											reportUnknownArgumentType = "none",
											reportUnknownLambdaType = "none",
											reportUnknownVariableType = "none",
											reportUnknownMemberType = "none",
											reportMissingParameterType = "none",
										},
									},
								},
							},
						})
					end,

					["ruff_lsp"] = function()
						-- Ruff LSP for ultra-fast Python linting and formatting
						lspconfig.ruff_lsp.setup({
							capabilities = capabilities,
							init_options = {
								settings = {
									-- Ruff configuration
									args = {
										"--config=pyproject.toml", -- Use pyproject.toml if available
									},
								}
							},
							-- Organize imports capability
							on_attach = function(client, bufnr)
								-- Disable hover in favor of Pyright
								client.server_capabilities.hoverProvider = false
							end,
						})
					end,

					["csharp_ls"] = function()
						local handlers = {}

						-- Only add the handler if the plugin is available
						local ok, csharpls_extended = pcall(require, "csharpls_extended")
						if ok and csharpls_extended.handler then
							handlers["textDocument/definition"] = csharpls_extended.handler
						end

						lspconfig.csharp_ls.setup({
							capabilities = capabilities,
							handlers = handlers,
							root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", "omnisharp.json", "function.json"),
							init_options = {
								AutomaticWorkspaceInit = true,
							},
							settings = {
								csharp = {
									semanticHighlighting = {
										enabled = true,
									},
								},
							},
						})
					end,
				})
			else
				-- Fallback for newer versions of mason-lspconfig
				-- Set up servers manually
				local servers = {
					"html", "cssls", "tailwindcss", "svelte", "lua_ls", "graphql",
					"emmet_ls", "prismals", "pyright", "ruff_lsp", "eslint", "bashls", "csharp_ls"
				}

				for _, server_name in ipairs(servers) do
					if server_name == "lua_ls" then
						lspconfig.lua_ls.setup({
							capabilities = capabilities,
							settings = {
								Lua = {
									diagnostics = { globals = { "vim" } },
									completion = { callSnippet = "Replace" },
								},
							},
						})
					elseif server_name == "bashls" then
						lspconfig.bashls.setup({
							capabilities = capabilities,
							filetypes = { "sh", "bash", "zsh" },
							init_options = {
								filetypes = { "sh", "bash", "zsh" },
							},
							settings = {
								bashIde = {
									shellcheckPath = "",
								},
							},
						})
					elseif server_name == "pyright" then
						-- Professional Python LSP configuration
						lspconfig.pyright.setup({
							capabilities = capabilities,
							settings = {
								pyright = {
									-- Using Ruff's import organizer
									disableOrganizeImports = true,
									-- Disable some features that Ruff handles better
									disableTaggedHints = false,
								},
								python = {
									analysis = {
										-- Enhanced type checking
										typeCheckingMode = "strict",
										-- Auto-import completions
										autoImportCompletions = true,
										-- Use workspace libraries
										useLibraryCodeForTypes = true,
										-- Diagnostic modes
										diagnosticMode = "workspace",
										-- Auto-search paths
										autoSearchPaths = true,
										-- Stub path
										stubPath = "typings",
										-- Extra paths for analysis
										extraPaths = {},
										-- Diagnostic severity overrides
										diagnosticSeverityOverrides = {
											reportMissingTypeStubs = "none",
											reportUnknownParameterType = "none",
											reportUnknownArgumentType = "none",
											reportUnknownLambdaType = "none",
											reportUnknownVariableType = "none",
											reportUnknownMemberType = "none",
											reportMissingParameterType = "none",
										},
									},
								},
							},
						})
					elseif server_name == "ruff_lsp" then
						-- Ruff LSP for ultra-fast Python linting and formatting
						lspconfig.ruff_lsp.setup({
							capabilities = capabilities,
							init_options = {
								settings = {
									-- Ruff configuration
									args = {
										"--config=pyproject.toml", -- Use pyproject.toml if available
									},
								}
							},
							-- Organize imports capability
							on_attach = function(client, bufnr)
								-- Disable hover in favor of Pyright
								client.server_capabilities.hoverProvider = false
							end,
						})
					elseif server_name == "csharp_ls" then
						local handlers = {}

						-- Only add the handler if the plugin is available
						local ok, csharpls_extended = pcall(require, "csharpls_extended")
						if ok and csharpls_extended.handler then
							handlers["textDocument/definition"] = csharpls_extended.handler
						end

						lspconfig.csharp_ls.setup({
							capabilities = capabilities,
							handlers = handlers,
							root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", "omnisharp.json", "function.json"),
							init_options = {
								AutomaticWorkspaceInit = true,
							},
							settings = {
								csharp = {
									semanticHighlighting = {
										enabled = true,
									},
								},
							},
						})
					else
						lspconfig[server_name].setup({ capabilities = capabilities })
					end
				end
			end

			-- Add filetype detection for common shell files
			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				pattern = { ".bashrc", ".zshrc", ".bash_profile", ".profile", ".zsh_*", ".bash_*", ".env" },
				callback = function(ev)
					vim.bo[ev.buf].filetype = "sh"
				end,
			})

			-- Add filetype detection for Python files
			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				pattern = { "*.py", "*.pyi", "*.pyw", ".pythonrc", "SConstruct", "SConscript", "*.wsgi" },
				callback = function(ev)
					vim.bo[ev.buf].filetype = "python"
				end,
			})

			-- Setup csharpls-extended for Neovim 0.11+
			local has_csharpls_extended, csharpls_extended = pcall(require, "csharpls_extended")
			if has_csharpls_extended and csharpls_extended.buf_read_cmd_bind then
				csharpls_extended.buf_read_cmd_bind()
			end
		end,
	},
}