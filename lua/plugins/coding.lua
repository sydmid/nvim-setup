return {
	-- Treesitter for better syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile", "BufReadPre" },
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				lazy = false, -- Make sure this is loaded early
				priority = 100, -- High priority to ensure it's loaded before keymaps
			},
			"windwp/nvim-ts-autotag",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				modules = {},
				sync_install = false,
				ignore_install = {},
				auto_install = true,
				ensure_installed = {
					"c",
					"lua",
					"vim",
					"vimdoc",
					"query",
					"javascript",
					"typescript",
					"python",
					"rust",
					"go",
					"bash",
					"json",
					"dockerfile",
					"gitignore",
					"query",
					"html",
					"css",
					"markdown",
					"markdown_inline",
				},
				-- enable autotagging (w/ nvim-ts-autotag plugin)
				autotag = {
					enable = true,
				},
				highlight = { enable = true },
				indent = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						-- scope_incremental = "<C-s>",
						node_decremental = "<C-backspace>",
					},
				},
				-- Enable folding with treesitter
				fold = { enable = true },
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = false, -- disable jump list population for increased speed
						goto_next_start = {},
						goto_next_end = {},
						goto_previous_start = {},
						goto_previous_end = {},
					},
				},
			})
		end,
	},

	-- Auto completion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer", -- source for text in buffer
			"hrsh7th/cmp-path", -- source for file system paths
			{
				"L3MON4D3/LuaSnip",
				-- follow latest release.
				version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
				-- install jsregexp (optional!).
				build = "make install_jsregexp",
			},
			"saadparwaiz1/cmp_luasnip", -- for autocompletion
			"rafamadriz/friendly-snippets", -- useful snippets
			"onsails/lspkind.nvim", -- vs-code like pictograms
        },
		config = function()
			local cmp = require("cmp")

			local luasnip = require("luasnip")

			local lspkind = require("lspkind")

            local capabilities = require('cmp_nvim_lsp').default_capabilities()

			-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,preview,noselect",
                    autocomplete = {
                        require("cmp.types").cmp.TriggerEvent.TextChanged,
                    },
				},
				snippet = { -- configure how nvim-cmp interacts with snippet engine
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
					["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<D-CR>"] = cmp.mapping.complete(), -- show completion suggestions
					["<C-e>"] = cmp.mapping.abort(), -- close completion window
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.confirm({ select = true }),
				}),
				-- sources for autocompletion
				sources = cmp.config.sources({
					{ name = "luasnip", trigger_characters = {}, option = { show_autosnippets = true } }, -- snippets
					{ name = "nvim_lsp", keyword_length = 1 }, -- lsp
					{ name = "buffer", keyword_length = 2 }, -- text within current buffer
					{ name = "path", keyword_length = 2 }, -- file system paths
				}),

                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },

				-- configure lspkind for vs-code like pictograms in completion menu
				formatting = {
					fields = { "kind", "abbr", "menu" },
					expandable_indicator = true,
					format = lspkind.cmp_format({
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
			})
		end,
	},
	-- Commenting
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			-- import comment plugin safely
			local comment = require("Comment")

			local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

			-- enable comment
			comment.setup({
				padding = true,
				sticky = true,
				ignore = "^$", -- ignore empty lines
				mappings = {
					basic = true,
					extra = true,
				},
				toggler = {
					line = "gcc",
					block = "gbc",
				},
				opleader = {
					line = "gc",
					block = "gb",
				},
				extra = {
					above = "gcO",
					below = "gco",
					eol = "gcA",
				},
				-- for commenting tsx, jsx, svelte, html files
				pre_hook = ts_context_commentstring.create_pre_hook(),
				post_hook = function() end, -- empty function instead of nil
			})
		end,
	},
	-- Auto pairs
	{
		"windwp/nvim-autopairs",
		event = { "InsertEnter" },
		dependencies = {
			"hrsh7th/nvim-cmp",
		},
		config = function()
			-- import nvim-autopairs
			local autopairs = require("nvim-autopairs")

			-- configure autopairs
			autopairs.setup({
				check_ts = true, -- enable treesitter
				ts_config = {
					lua = { "string" }, -- don't add pairs in lua string treesitter nodes
					javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
					java = false, -- don't check treesitter on java
				},
			})

			-- import nvim-autopairs completion functionality
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")

			-- import nvim-cmp plugin (completions plugin)
			local cmp = require("cmp")

			-- make autopairs and completion work together
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					javascript = { "prettier" },
					typescript = { "prettier" },
					javascriptreact = { "prettier" },
					typescriptreact = { "prettier" },
					svelte = { "prettier" },
					css = { "prettier" },
					html = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },
					graphql = { "prettier" },
					liquid = { "prettier" },
					lua = { "stylua" },
					python = { "isort", "black" },
					sh = { "shfmt" },
					bash = { "shfmt" },
					zsh = { "shfmt_zsh", "zsh_indent" }, -- Try shfmt_zsh first, fallback to custom indenter
				},
				formatters = {
					shfmt = {
						prepend_args = { "-i", "2", "-ci" } -- 2-space indentation and indent switch cases
					},
					shfmt_zsh = {
						command = "shfmt",
						args = { "-i", "2", "-ci", "--language-dialect", "bash" }, -- Use bash dialect for zsh files
						stdin = true,
					},
					zsh_indent = {
						-- Custom formatter for zsh files that have complex parameter expansions
						format = function(self, content, range)
							-- Simple indentation logic for zsh files
							local lines = vim.split(content, "\n")
							local indented = {}
							local indent_level = 0
							local indent_size = 2

							for _, line in ipairs(lines) do
								local trimmed = vim.trim(line)

								-- Check for closing markers to decrease indent first
								if trimmed:match("^fi$")
									or trimmed:match("^done$")
									or trimmed:match("^}$")
									or trimmed:match("^esac$")
									or trimmed:match("^%)$") then
									indent_level = math.max(0, indent_level - 1)
								end

								-- Add appropriate indent
								local indent = string.rep(" ", indent_level * indent_size)
								table.insert(indented, indent .. trimmed)

								-- Check for opening markers to increase indent
								if trimmed:match("^if ")
									or trimmed:match("then$")
									or trimmed:match("^for ")
									or trimmed:match("do$")
									or trimmed:match("^while ")
									or trimmed:match("^{$")
									or trimmed:match("^case ")
									or trimmed:match("^function ")
									or trimmed:match("%([ ]*%)[ ]*{[ ]*$") then
									indent_level = indent_level + 1
								end
							end

							return table.concat(indented, "\n")
						end,
					}
				},
				format_on_save = {
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
					-- Exclude problematic shell config files
					-- Use a function for more complex exclusion logic
					filter = function(bufnr)
						local filename = vim.api.nvim_buf_get_name(bufnr)
						-- Skip formatting shell config files that have complex parameter expansions
						if filename:match("%.zshrc$") or
						   filename:match("%.zsh_") or
						   filename:match("%.bashrc$") or
						   filename:match("%.bash_") then
							return false
						end
						return true
					end,
				},
			})

			vim.keymap.set({ "n", "v" }, "<leader>mp", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "Format file or range (in visual mode)" })
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			-- Configure eslint_d to respect .eslintrc file existence
			lint.linters.eslint_d = {
				name = "eslint_d",
				cmd = "eslint_d",
				stdin = true,
				args = {
					"--format",
					"json",
					"--stdin",
					"--stdin-filename",
					function()
						return vim.api.nvim_buf_get_name(0)
					end,
				},
				ignore_exitcode = true,
				parser = function(output, _)
					local diagnostics = {}

					-- If no ESLint config found, just return empty diagnostics silently
					if output:find("No ESLint configuration found") then
						return diagnostics
					end

					-- Continue with normal parsing for valid ESLint output
					if output and output ~= "" then
						local decoded = vim.json.decode(output)
						if decoded and decoded[1] then
							local filepath = vim.api.nvim_buf_get_name(0)
							for _, item in ipairs(decoded) do
								if item.filePath == filepath then
									for _, message in ipairs(item.messages) do
										table.insert(diagnostics, {
											lnum = message.line - 1,
											end_lnum = message.endLine and (message.endLine - 1) or nil,
											col = message.column - 1,
											end_col = message.endColumn and (message.endColumn - 1) or nil,
											severity = message.severity == 2 and vim.diagnostic.severity.ERROR
												or message.severity == 1 and vim.diagnostic.severity.WARN
												or vim.diagnostic.severity.INFO,
											message = message.message,
											code = message.ruleId,
											source = "eslint",
										})
									end
								end
							end
						end
					end

					return diagnostics
				end,
			}

			lint.linters_by_ft = {
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				svelte = { "eslint_d" },
				python = { "pylint" },
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				zsh = { "shellcheck" },
			}

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})

			vim.keymap.set("n", "<leader>l", function()
				lint.try_lint()
			end, { desc = "Trigger linting for current file" })
		end,
	},
}
