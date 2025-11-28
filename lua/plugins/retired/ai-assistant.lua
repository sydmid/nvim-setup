-- Modern AI Assistant for Neovim - Cursor-like Experience
-- Reimplemented with latest best practices and no keybinding conflicts
-- Using: GitHub Copilot Chat + Copilot Completions

return {
	-- GitHub Copilot Core (Inline Suggestions)
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true, -- Auto-trigger like Cursor
				hide_during_completion = true,
				debounce = 75,
				keymap = {
					accept = "<M-l>", -- Alt+L to accept (avoiding Tab conflict with cmp)
					accept_word = "<M-w>",
					accept_line = "<M-j>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			panel = {
				enabled = true,
				auto_refresh = true,
				keymap = {
					jump_prev = "[[",
					jump_next = "]]",
					accept = "<CR>",
					refresh = "gr",
					open = "<M-CR>",
				},
				layout = {
					position = "bottom",
					ratio = 0.4,
				},
			},
			filetypes = {
				yaml = true,
				markdown = true,
				help = false,
				gitcommit = true,
				gitrebase = false,
				hgcommit = false,
				svn = false,
				cvs = false,
				["."] = false,
			},
			copilot_node_command = "node",
			server_opts_overrides = {},
		},
	},

	-- Copilot CMP Source (for nvim-cmp integration)
	{
		"zbirenbaum/copilot-cmp",
		dependencies = "copilot.lua",
		opts = {},
		config = function(_, opts)
			require("copilot_cmp").setup(opts)
		end,
	},

	-- GitHub Copilot Chat - Modern AI Chat Interface
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope.nvim" },
		},
		build = "make tiktoken",
		event = "VeryLazy",
		opts = {
			model = "grok-2-latest", -- Default: Free and fast Grok model
			temperature = 0.1,
			question_header = "## User ",
			answer_header = "## Copilot ",
			error_header = "## Error ",
			separator = "───",
			show_help = true,
			show_folds = true,
			highlight_selection = true,
			context = nil,
			window = {
				layout = "float",
				relative = "editor",
				width = 0.8,
				height = 0.8,
				row = 2,
				col = 2,
				border = "rounded",
				footer = function()
					local chat = require("CopilotChat")
					local model = chat.config and chat.config.model or "grok-2-latest"
					return " 🤖 Model: " .. model .. " │ Press ? for help "
				end,
				zindex = 1,
			},
			mappings = {
				complete = {
					detail = "Use @<Tab> or /<Tab> for options.",
					insert = "<Tab>",
				},
				close = {
					normal = "q",
					insert = "<C-c>",
				},
				reset = {
					normal = "<C-l>",
					insert = "<C-l>",
				},
				submit_prompt = {
					normal = "<CR>",
					insert = "<C-s>",
				},
				accept_diff = {
					normal = "<C-y>",
					insert = "<C-y>",
				},
				yank_diff = {
					normal = "gy",
					register = '"',
				},
				show_diff = {
					normal = "gd",
				},
				show_system_prompt = {
					normal = "gp",
				},
				show_user_selection = {
					normal = "gs",
				},
			},
		},
		config = function(_, opts)
			local chat = require("CopilotChat")
			local select = require("CopilotChat.select")

			-- Add custom prompts
			opts.prompts = {
				-- Code Generation & Editing
				Explain = {
					prompt = "/COPILOT_EXPLAIN Explain how the selected code works step by step.",
					description = "Explain code",
				},
				Review = {
					prompt = "/COPILOT_REVIEW Review the selected code for bugs, performance issues, and improvements.",
					description = "Review code",
				},
				Fix = {
					prompt = "/COPILOT_GENERATE There is a problem in this code. Rewrite the code to show it with the bug fixed.",
					description = "Fix the code",
				},
				Optimize = {
					prompt = "/COPILOT_GENERATE Optimize the selected code to improve performance and readability.",
					description = "Optimize code",
				},
				Docs = {
					prompt = "/COPILOT_GENERATE Add comprehensive documentation and comments to the code.",
					description = "Add documentation",
				},
				Tests = {
					prompt = "/COPILOT_GENERATE Generate comprehensive tests for the selected code.",
					description = "Generate tests",
				},
				-- Git & Commit
				Commit = {
					prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
					description = "Generate commit message",
					selection = select.gitdiff,
				},
				CommitStaged = {
					prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
					description = "Generate commit message (staged)",
					selection = function(source)
						return select.gitdiff(source, true)
					end,
				},
			}

			chat.setup(opts)

			-- Auto-commands for better UX
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-*",
				callback = function()
					vim.opt_local.relativenumber = true
					vim.opt_local.number = true
				end,
			})
		end,
		keys = {
			-- Main toggle (Cmd+Shift+A for macOS - avoiding conflict with Cmd+A)
			{
				"<D-A>", -- Cmd+Shift+A
				"<cmd>CopilotChatToggle<cr>",
				mode = { "n", "v", "i" },
				desc = "Toggle AI Chat (⌘⇧A)",
			},
			-- Alternative toggle
			{
				"<leader>ii",
				"<cmd>CopilotChatToggle<cr>",
				mode = { "n", "v" },
				desc = "AI: Toggle chat",
			},

			-- Quick ask (visual and normal mode)
			{
				"<leader>ia", -- Changed from <leader>ai to <leader>ia (i for AI)
				function()
					local input = vim.fn.input("Quick Question: ")
					if input ~= "" then
						require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
					end
				end,
				mode = { "n", "v" },
				desc = "AI: Quick ask",
			},

			-- AI Actions with Telescope picker
			{
				"<leader>ip", -- i for AI, p for prompt
				function()
					local actions = require("CopilotChat.actions")
					require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
				end,
				mode = { "n", "v" },
				desc = "AI: Prompt actions",
			},

			-- Quick Actions (common workflows)
			{
				"<leader>ie", -- Explain
				"<cmd>CopilotChatExplain<cr>",
				mode = { "n", "v" },
				desc = "AI: Explain code",
			},
			{
				"<leader>ir", -- Review
				"<cmd>CopilotChatReview<cr>",
				mode = { "n", "v" },
				desc = "AI: Review code",
			},
			{
				"<leader>if", -- Fix
				"<cmd>CopilotChatFix<cr>",
				mode = { "n", "v" },
				desc = "AI: Fix code",
			},
			{
				"<leader>io", -- Optimize
				"<cmd>CopilotChatOptimize<cr>",
				mode = { "n", "v" },
				desc = "AI: Optimize code",
			},
			{
				"<leader>id", -- Docs
				"<cmd>CopilotChatDocs<cr>",
				mode = { "n", "v" },
				desc = "AI: Add docs",
			},
			{
				"<leader>it", -- Tests
				"<cmd>CopilotChatTests<cr>",
				mode = { "n", "v" },
				desc = "AI: Generate tests",
			},

			-- Git Integration
			{
				"<leader>ic", -- Commit
				"<cmd>CopilotChatCommit<cr>",
				desc = "AI: Generate commit msg",
			},
			{
				"<leader>iC", -- Commit Staged
				"<cmd>CopilotChatCommitStaged<cr>",
				desc = "AI: Generate commit msg (staged)",
			},

			-- Chat Management
			{
				"<leader>iq", -- Quit/Close
				function()
					local chat = require("CopilotChat")
					chat.close()
				end,
				desc = "AI: Close chat",
			},
			{
				"<leader>iR", -- Reset
				function()
					local chat = require("CopilotChat")
					chat.reset()
				end,
				desc = "AI: Reset chat",
			},

			-- Model Selection with Telescope
			{
				"<leader>im", -- Model
				function()
					local pickers = require("telescope.pickers")
					local finders = require("telescope.finders")
					local conf = require("telescope.config").values
					local actions = require("telescope.actions")
					local action_state = require("telescope.actions.state")

					-- Available models with descriptions (verified model names)
					local models = {
						-- Free/Fast Models (Recommended defaults)
						{
							name = "grok-2-latest",
							display = "🚀 Grok 2 Latest (Fast & Free)",
							description = "Default - Fast, reliable, and free",
							category = "Free",
							recommended = true,
						},
						{
							name = "gpt-4o-mini",
							display = "⚡ GPT-4o Mini (Free)",
							description = "Fast and efficient OpenAI model",
							category = "Free",
						},
						{
							name = "o1-mini",
							display = "🧠 O1 Mini (Fast Reasoning)",
							description = "Quick reasoning model from OpenAI",
							category = "Free",
						},

						-- Premium Claude Models
						{
							name = "claude-3.5-sonnet",
							display = "🤖 Claude 3.5 Sonnet",
							description = "Excellent for code and reasoning",
							category = "Premium",
						},
						{
							name = "claude-sonnet-4",
							display = "💎 Claude Sonnet 4",
							description = "Latest Claude model",
							category = "Premium",
						},

						-- Premium GPT Models
						{
							name = "gpt-4o",
							display = "🔷 GPT-4o",
							description = "Latest GPT-4 optimized model",
							category = "Premium",
						},
						{
							name = "gpt-4",
							display = "🔶 GPT-4",
							description = "Classic GPT-4",
							category = "Premium",
						},
						{
							name = "gpt-4-turbo",
							display = "⚡ GPT-4 Turbo",
							description = "Faster GPT-4 variant",
							category = "Premium",
						},

						-- Reasoning Models
						{
							name = "o1",
							display = "🧠 O1 (Advanced Reasoning)",
							description = "Best for complex problem solving",
							category = "Reasoning",
						},
						{
							name = "o1-preview",
							display = "🎓 O1 Preview",
							description = "Preview reasoning model",
							category = "Reasoning",
						},

						-- Gemini Models
						{
							name = "gemini-2.0-flash-exp",
							display = "💫 Gemini 2.0 Flash",
							description = "Fast Google Gemini experimental",
							category = "Gemini",
						},
						{
							name = "gemini-exp-1206",
							display = "🌟 Gemini Experimental",
							description = "Latest Gemini experimental features",
							category = "Gemini",
						},
					}

					-- Get current model
					local chat = require("CopilotChat")
					local current_model = (chat.config and chat.config.model) or "grok-2-latest"

					-- Prepare entries with current model marker
					local entries = {}
					for _, model in ipairs(models) do
						local is_current = model.name == current_model
						local prefix = is_current and "➤ " or "  "
						local badge = model.recommended and " [DEFAULT]" or ""
						local free_badge = model.category == "Free" and " 🆓" or ""

						table.insert(entries, {
							name = model.name,
							display = prefix .. model.display .. free_badge .. badge,
							description = model.description,
							category = model.category,
							ordinal = model.name .. " " .. model.description,
							is_current = is_current,
						})
					end

					pickers
						.new({}, {
							prompt_title = "🤖 Select AI Model (Current: " .. current_model .. ")",
							initial_mode = "normal",
							finder = finders.new_table({
								results = entries,
								entry_maker = function(entry)
									return {
										value = entry,
										display = entry.display,
										ordinal = entry.ordinal,
									}
								end,
							}),
							sorter = conf.generic_sorter({}),
							previewer = require("telescope.previewers").new_buffer_previewer({
								title = "Model Details",
								define_preview = function(self, entry)
									local model = entry.value
									local preview_lines = {
										"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
										"",
										"🤖 Model: " .. model.name,
										"",
										"📦 Category: " .. model.category,
										"",
										"📝 Description:",
										"   " .. model.description,
										"",
										"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
										"",
									}

									-- Add category-specific info
									if model.category == "Free" then
										table.insert(preview_lines, "✅ Benefits:")
										table.insert(preview_lines, "   • No additional cost")
										table.insert(preview_lines, "   • Fast response times")
										table.insert(preview_lines, "   • Great for daily use")
									elseif model.category == "Premium" then
										table.insert(preview_lines, "💎 Premium Features:")
										table.insert(preview_lines, "   • Superior reasoning")
										table.insert(preview_lines, "   • Better context understanding")
										table.insert(preview_lines, "   • Advanced capabilities")
									elseif model.category == "Reasoning" then
										table.insert(preview_lines, "🧠 Reasoning Capabilities:")
										table.insert(preview_lines, "   • Complex problem solving")
										table.insert(preview_lines, "   • Mathematical reasoning")
										table.insert(preview_lines, "   • Step-by-step analysis")
									elseif model.category == "Gemini" then
										table.insert(preview_lines, "🌟 Google's AI:")
										table.insert(preview_lines, "   • Multimodal capabilities")
										table.insert(preview_lines, "   • Fast and efficient")
										table.insert(preview_lines, "   • Experimental features")
									end

									table.insert(preview_lines, "")
									if model.is_current then
										table.insert(preview_lines, "✨ Currently Active Model ✨")
									else
										table.insert(preview_lines, "Press Enter to switch to this model")
									end

									vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
								end,
							}),
							attach_mappings = function(prompt_bufnr, map)
								actions.select_default:replace(function()
									local selection = action_state.get_selected_entry()
									actions.close(prompt_bufnr)
									if selection and selection.value then
										local selected_model = selection.value.name

										-- Update the model
										local chat = require("CopilotChat")
										if chat.config then
											chat.config.model = selected_model
											vim.notify(
												"🤖 Switched to: " .. selected_model,
												vim.log.levels.INFO
											)
										else
											vim.notify(
												"❌ Failed to switch model",
												vim.log.levels.ERROR
											)
										end
									end
								end)

								-- Enhanced navigation
								map("n", "<BS>", actions.close)
								map("i", "<Esc>", actions.close)
								map("n", "<Esc>", actions.close)
								map("n", "q", actions.close)

								map("n", "?", function()
									vim.notify(
										"Model Selector Help:\n"
											.. "• Enter: Select model\n"
											.. "• j/k: Navigate\n"
											.. "• /: Search\n"
											.. "• ?: This help\n"
											.. "• q/Esc: Close\n\n"
											.. "💡 Free models are marked with 🆓",
										vim.log.levels.INFO
									)
								end)

								return true
							end,
						})
						:find()
				end,
				desc = "AI: Select model",
			},

			-- Debug & Status
			{
				"<leader>iS", -- Status
				function()
					local chat = require("CopilotChat")
					local current_model = (chat.config and chat.config.model) or "unknown"
					local status_msg = string.format(
						"🤖 Copilot Status\n\n"
							.. "Current Model: %s\n"
							.. "Press <leader>im to change model",
						current_model
					)
					vim.notify(status_msg, vim.log.levels.INFO)
				end,
				desc = "AI: Show status",
			},
		},
	},

	-- Status line integration (optional)
	{
		"nvim-lualine/lualine.nvim",
		optional = true,
		opts = function(_, opts)
			local colors = {
				[""] = "#6CC644",
				["Normal"] = "#6CC644",
				["Warning"] = "#FFCC00",
				["InProgress"] = "#0969DA",
			}

			local M = require("copilot.api")
			local icons = {
				[""] = " ",
				["Normal"] = " ",
				["Warning"] = " ",
				["InProgress"] = " ",
			}

			-- Add copilot status to lualine
			table.insert(opts.sections.lualine_x or {}, {
				function()
					if not M.status then
						return ""
					end
					local status = M.status.data.status
					return icons[status] or icons[""]
				end,
				cond = function()
					if not package.loaded["copilot"] then
						return false
					end
					local ok, clients = pcall(vim.lsp.get_clients, { name = "copilot", bufnr = 0 })
					if not ok then
						return false
					end
					return ok and #clients > 0
				end,
				color = function()
					if not M.status then
						return { fg = colors[""] }
					end
					local status = M.status.data.status
					return { fg = colors[status] or colors[""] }
				end,
			})

			return opts
		end,
	},
}
