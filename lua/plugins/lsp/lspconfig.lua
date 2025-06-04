return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{ "folke/neodev.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"glepnir/lspsaga.nvim",
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

			-- Setup LSP
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
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
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }
					local keymap = vim.keymap.set

					-- Standard LSP navigation commands
					keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { buffer = ev.buf, desc = "Go to definition" })
					keymap("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
					keymap("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>", { buffer = ev.buf, desc = "Go to type definition" })
					keymap("n", "<leader>us", "<cmd>Telescope lsp_references<CR>", { buffer = ev.buf, desc = "Find references" })
					keymap("n", "<leader>ii", "<cmd>Telescope lsp_implementations<CR>", { buffer = ev.buf, desc = "Find implementations" })

					-- Lspsaga peek keymaps - these provide a preview without jumping to the definition
					keymap("n", "<leader>pd", "<cmd>Lspsaga peek_definition<CR>", { buffer = ev.buf, desc = "Peek definition" })
					keymap("n", "<leader>pt", "<cmd>Lspsaga peek_type_definition<CR>", { buffer = ev.buf, desc = "Peek type definition" })
					keymap("n", "<leader>is", "<cmd>Lspsaga signature_help<CR>", { buffer = ev.buf, desc = "Signature Help (Lspsaga)" })

					-- Enhanced hover with Lspsaga for better UI
					keymap("n", "<D-i>", "<cmd>Lspsaga hover_doc<CR>", { buffer = ev.buf, desc = "Show documentation (Lspsaga)", silent = true })

					-- Additional useful Lspsaga keymaps
					keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { buffer = ev.buf, desc = "Code actions (Lspsaga)" })
					keymap("n", "<leader>lr", "<cmd>Lspsaga rename<CR>", { buffer = ev.buf, desc = "Rename symbol (Lspsaga)" })
					keymap("n", "<leader>lf", "<cmd>Lspsaga finder<CR>", { buffer = ev.buf, desc = "LSP finder" })
					keymap("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { buffer = ev.buf, desc = "LSP outline" })

					-- Standard actions (maintaining backward compatibility)
					keymap("n", "<leader>r", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename symbol" })
					keymap({"n", "v"}, "<leader>c", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code actions" })

					-- Diagnostics with enhanced Lspsaga UI
					-- Use ONLY Lspsaga for diagnostics UI to avoid duplication
					keymap("n", "<leader>d", "<cmd>Lspsaga show_line_diagnostics<CR>", { buffer = ev.buf, desc = "Line diagnostics" })
					keymap("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", { buffer = ev.buf, desc = "Buffer diagnostics" })
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
				})
			else
				-- Fallback for newer versions of mason-lspconfig
				-- Set up servers manually
				local servers = {
					"html", "cssls", "tailwindcss", "svelte", "lua_ls", "graphql",
					"emmet_ls", "prismals", "pyright", "eslint", "bashls"
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
		end,
	},
}
