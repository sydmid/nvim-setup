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

			-- Configure diagnostics to prevent duplication with Lspsaga
			vim.diagnostic.config({
				virtual_text = false, -- Disable virtual text since Lspsaga will handle this
				signs = true, -- Keep signs in the gutter
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					focusable = false,
					style = "minimal",
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
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

			-- Diagnostic signs
			-- local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			-- for type, icon in pairs(signs) do
			-- 	local hl = "DiagnosticSign" .. type
			-- 	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			-- end

			-- LSP keymaps
			-- Best practice: Define all LSP-related keymaps in the LspAttach event
			-- This ensures the keymaps are only active when an LSP server is attached to the buffer
			-- Prevents errors when trying to use LSP features in buffers without LSP support

			-- Auto-trigger signature help autocmd (DISABLED - use manual trigger <D-S-i> instead)
			-- vim.api.nvim_create_autocmd("LspAttach", {
			-- 	group = vim.api.nvim_create_augroup("UserLspSignatureHelp", {}),
			-- 	callback = function(ev)
			-- 		local client = vim.lsp.get_client_by_id(ev.data.client_id)
			-- 		if client and client.server_capabilities.signatureHelpProvider then
			-- 			-- Auto-trigger signature help on specific events
			-- 			vim.api.nvim_create_autocmd({ "TextChangedI" }, {
			-- 				buffer = ev.buf,
			-- 				group = vim.api.nvim_create_augroup("SignatureHelpAutoTrigger", { clear = false }),
			-- 				callback = function()
			-- 					local line = vim.api.nvim_get_current_line()
			-- 					local col = vim.api.nvim_win_get_cursor(0)[2]
			-- 					local char_before = col > 0 and line:sub(col, col) or ""
			-- 					local char_current = line:sub(col + 1, col + 1)
			--
			-- 					-- Trigger on function call characters
			-- 					if char_before == "(" or char_before == "," or char_current == "(" then
			-- 						vim.defer_fn(function()
			-- 							if vim.fn.pumvisible() == 0 then
			-- 								vim.lsp.buf.signature_help()
			-- 							end
			-- 						end, 150)
			-- 					end
			-- 				end,
			-- 			})
			-- 		end
			-- 	end,
			-- })

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
							require("omnisharp_extended").lsp_references()
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
							_G.telescope_lsp_references_with_dynamic_title()
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

					-- Enhanced hover with Lspsaga for better UI
					keymap("n", "<D-i>", "<cmd>Lspsaga hover_doc<CR>", { buffer = ev.buf, desc = "Show documentation (Lspsaga)", silent = true })

					-- Additional useful Lspsaga keymaps
					keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { buffer = ev.buf, desc = "Code actions (Lspsaga)" })
					keymap("n", "<leader>lr", "<cmd>Lspsaga rename<CR>", { buffer = ev.buf, desc = "Rename symbol (Lspsaga)" })
					keymap("n", "<leader>lf", "<cmd>Lspsaga finder<CR>", { buffer = ev.buf, desc = "LSP finder" })
					keymap("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { buffer = ev.buf, desc = "LSP outline" })

					-- Standard actions (maintaining backward compatibility)
					keymap("n", "<leader>r", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename symbol" })

					-- Diagnostics with enhanced Lspsaga UI
					-- Use ONLY Lspsaga for diagnostics UI to avoid duplication
					keymap("n", "<leader>d", "<cmd>Lspsaga show_line_diagnostics<CR>", { buffer = ev.buf, desc = "Line diagnostics" })
					keymap("n", "<leader>D", function()
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
					keymap("n", "<leader>dj", "<cmd>Lspsaga diagnostic_jump_next<CR>", { buffer = ev.buf, desc = "Next diagnostic" })
					keymap("n", "<leader>dk", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { buffer = ev.buf, desc = "Previous diagnostic" })
					keymap("n", "<D-]>", "<cmd>Lspsaga diagnostic_jump_next<CR>", { buffer = ev.buf, desc = "Next diagnostic" })
					keymap("n", "<D-[>", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { buffer = ev.buf, desc = "Previous diagnostic" })
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
					"emmet_ls", "prismals", "pyright", "eslint", "bashls", "csharp_ls"
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

			-- Setup csharpls-extended for Neovim 0.11+
			local has_csharpls_extended, csharpls_extended = pcall(require, "csharpls_extended")
			if has_csharpls_extended and csharpls_extended.buf_read_cmd_bind then
				csharpls_extended.buf_read_cmd_bind()
			end
		end,
	},
}
