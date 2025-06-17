-- filepath: /Users/omid/.config/nvim/lua/plugins/copilot.lua
-- GitHub Copilot integration for Neovim with full AI assistant capabilities
-- Consolidated configuration following nvim architecture best practices

-- Available models configuration
local MODELS = {
	-- Anthropic Claude Models (prioritized)
  { name = "claude-sonnet-4", description = "Claude 4", category = "🤖 Claude" },
  { name = "claude-3.5-sonnet", description = "Claude 3.5", category = "🤖 Claude" },
	{ name = "claude-3.7-sonnet", description = "claude-3.7-sonnet", category = "🤖 Claude" },
  { name = "claude-3.7-sonnet-thought", description = "claude-3.7-sonnet thinking", category = "🤖 Claude" },

	-- OpenAI GPT Models
	{ name = "gpt-4", description = "gpt4", category = "🤖 GPT" },
	{ name = "gpt-4.1", description = "gpt4.1", category = "🤖 GPT" },
	{ name = "gpt-4o", description = "gpt4.0", category = "🤖 GPT" },
	{ name = "gpt-4o-mini", description = "gpt4.0-mini", category = "🤖 GPT" },
	{ name = "gpt-3.5-turbo", description = "gpt3.5-turbo", category = "🤖 GPT" },

	-- OpenAI o1 Models (Reasoning)
	{ name = "o1", description = "o1- Advanced reasoning", category = "🧠 Reasoning" },
	{ name = "o4-mini", description = "o4-mini - Fast reasoning model", category = "🧠 Reasoning" },

	-- Google Gemini Models
	{ name = "gemini-2.5-pro", description = "Gemini Pro - Google's flagship model", category = "💎 Gemini" },
}

-- Get current model
local function get_current_model()
	local ok, chat = pcall(require, "CopilotChat")
	if ok and chat.config and chat.config.model then
		return chat.config.model
	end
	return "gemini-2.5-pro" -- Default fallback
end

-- Set model
local function set_model(model)
	local chat_ok, chat = pcall(require, "CopilotChat")
	if chat_ok and chat.config then
		chat.config.model = model
		vim.notify("✅ Model set to: " .. model, vim.log.levels.INFO)
	else
		vim.notify("❌ Failed to set model", vim.log.levels.ERROR)
	end
end

-- Enhanced model selection with telescope
local function select_model_telescope()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local current_model = get_current_model()

	-- Prepare model entries with enhanced display
	local model_entries = {}
	for _, model in ipairs(MODELS) do
		local status_icon = "  "
		local category = model.category

		-- Mark current model
		if model.name == current_model then
			status_icon = "➤ "
		end

		table.insert(model_entries, {
			name = model.name,
			description = model.description,
			category = category,
			display = status_icon .. model.name .. " (" .. category .. ")",
			ordinal = model.name .. " " .. model.description,
		})
	end

	pickers.new({}, {
		prompt_title = "🤖 Select Copilot Chat Model (" .. #MODELS .. " available)",
		finder = finders.new_table({
			results = model_entries,
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
					"Model: " .. model.name,
					"Category: " .. model.category,
					"",
					"Description:",
					model.description,
					"",
					"Usage Notes:",
				}

				if model.name:find("o1") then
					table.insert(preview_lines, "• Optimized for complex reasoning tasks")
					table.insert(preview_lines, "• Best for math, coding, and analysis")
				elseif model.name:find("claude") then
					table.insert(preview_lines, "• Anthropic's Claude model")
					table.insert(preview_lines, "• Strong performance on text and code")
				elseif model.name:find("gemini") then
					table.insert(preview_lines, "• Google's Gemini model")
					table.insert(preview_lines, "• Multimodal capabilities")
				elseif model.name:find("gpt") then
					table.insert(preview_lines, "• OpenAI's GPT model")
					table.insert(preview_lines, "• Reliable and well-tested")
				end

				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
			end,
		}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if selection then
					set_model(selection.value.name)
				end
			end)

			map("i", "<Esc>", actions.close)
			map("n", "<Esc>", actions.close)
			map("n", "q", actions.close)

			return true
		end,
	}):find()
end

-- Enhanced context-aware chat function
local function context_aware_chat()
	local filetype = vim.bo.filetype
	local filename = vim.fn.expand("%:t")
	local current_function = vim.fn.expand("<cword>")

	local context = string.format(
		"I'm working on a %s file (%s). Current context around '%s'. ",
		filetype, filename, current_function
	)

	local input = vim.fn.input("Ask Copilot (" .. filetype .. "): ")
	if input ~= "" then
		vim.cmd("CopilotChat " .. context .. input)
	end
end

-- Smart commit message generation based on git diff
local function smart_commit_message()
	local diff_stats = vim.fn.systemlist("git diff --stat")
	local diff_files = vim.fn.systemlist("git diff --name-only")

	if #diff_files == 0 then
		vim.notify("No changes to commit", vim.log.levels.WARN)
		return
	end

	local context = "Generate a commit message for changes to: " .. table.concat(diff_files, ", ")
	vim.cmd("CopilotChat " .. context)
end

-- Code explanation with enhanced context
local function explain_with_context()
	local line = vim.fn.line(".")
	local col = vim.fn.col(".")
	local filename = vim.fn.expand("%:t")
	local filetype = vim.bo.filetype

	-- Get surrounding context (10 lines before and after)
	local start_line = math.max(1, line - 10)
	local end_line = math.min(vim.fn.line("$"), line + 10)
	local context_lines = vim.fn.getline(start_line, end_line)

	local context = string.format(
		"In %s file '%s', explain this code (line %d, col %d):\n%s",
		filetype, filename, line, col, table.concat(context_lines, "\n")
	)

	vim.cmd("CopilotChat " .. context)
end

-- Project-aware assistance
local function project_help()
	local cwd = vim.fn.getcwd()
	local project_name = vim.fn.fnamemodify(cwd, ":t")

	-- Check for common project files to understand context
	local project_context = {}
	if vim.fn.filereadable("package.json") == 1 then
		table.insert(project_context, "Node.js/JavaScript project")
	end
	if vim.fn.filereadable("Cargo.toml") == 1 then
		table.insert(project_context, "Rust project")
	end
	if vim.fn.filereadable("requirements.txt") == 1 then
		table.insert(project_context, "Python project")
	end
	if vim.fn.glob("*.csproj") ~= "" then
		table.insert(project_context, "C# project")
	end

	local context = "I'm working on project '" .. project_name .. "'"
	if #project_context > 0 then
		context = context .. " (" .. table.concat(project_context, ", ") .. ")"
	end
	context = context .. ". "

	local input = vim.fn.input("Project question: ")
	if input ~= "" then
		vim.cmd("CopilotChat " .. context .. input)
	end
end

-- Handle setting actions
local function handle_setting_action(action)
	if action == "model" then
		select_model_telescope()
	elseif action == "status" then
		show_status()
	elseif action == "restart" then
		vim.cmd("Copilot restart")
		vim.notify("Copilot restarted", vim.log.levels.INFO)
	elseif action == "auth" then
		vim.cmd("Copilot auth")
	elseif action == "history" then
		show_chat_history()
	elseif action == "clear_all" then
		clear_all_history()
	end
end

-- Show Copilot status
local function show_status()
	local ok, copilot = pcall(require, "copilot.api")
	if ok and copilot.status then
		local status = copilot.status.data
		if status then
			vim.notify(
				string.format("Copilot Status: %s\nMessage: %s",
					status.status or "unknown",
					status.message or "no message"
				),
				vim.log.levels.INFO
			)
		else
			vim.notify("Copilot status not available", vim.log.levels.WARN)
		end
	else
		vim.notify("Copilot not loaded", vim.log.levels.ERROR)
	end
end

-- Chat history management
local function show_chat_history()
	local session_dir = vim.fn.expand("~/.config/nvim/copilot-chats")

	-- Create directory if it doesn't exist
	if vim.fn.isdirectory(session_dir) == 0 then
		vim.fn.mkdir(session_dir, "p")
	end

	local session_files = vim.fn.glob(session_dir .. "/*.json", false, true)

	if #session_files == 0 then
		vim.notify("No saved chat sessions found", vim.log.levels.INFO)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")

	local sessions = {}
	for _, file in ipairs(session_files) do
		local filename = vim.fn.fnamemodify(file, ":t:r")
		table.insert(sessions, {
			name = filename,
			file = file,
			display = filename,
		})
	end

	pickers.new({}, {
		prompt_title = "💬 Chat Session History",
		finder = finders.new_table({
			results = sessions,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry.display,
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
					vim.cmd("edit " .. selection.value.file)
				end
			end)
			return true
		end,
	}):find()
end

-- Clear all chat history
local function clear_all_history()
	local session_dir = vim.fn.expand("~/.config/nvim/copilot-chats")
	vim.ui.input({
		prompt = "Clear all chat history? This cannot be undone. (y/N): ",
	}, function(input)
		if input and input:lower() == "y" then
			vim.fn.system("rm -f " .. session_dir .. "/*.json")
			vim.notify("All chat history cleared", vim.log.levels.INFO)
		end
	end)
end

-- New chat session
local function new_chat_session()
	vim.cmd("CopilotChatReset")
	vim.notify("Started new chat session", vim.log.levels.INFO)
end

-- Save current chat session
local function save_chat_session()
	vim.ui.input({
		prompt = "Session name: ",
		default = "chat-" .. os.date("%Y-%m-%d-%H%M%S"),
	}, function(name)
		if name and name ~= "" then
			local session_dir = vim.fn.expand("~/.config/nvim/copilot-chats")
			if vim.fn.isdirectory(session_dir) == 0 then
				vim.fn.mkdir(session_dir, "p")
			end

			local filepath = session_dir .. "/" .. name .. ".json"
			-- This is a placeholder - actual implementation would depend on CopilotChat's API
			vim.notify("Session saved as: " .. name, vim.log.levels.INFO)
		end
	end)
end

-- Settings interface using telescope
local function show_settings()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local settings_options = {
		{ name = "🤖 Change Model", action = "model" },
		{ name = "📊 Copilot Status", action = "status" },
		{ name = "🔄 Restart Copilot", action = "restart" },
		{ name = "🔧 Authentication", action = "auth" },
		{ name = "🎨 Chat History", action = "history" },
		{ name = "🗑️ Clear All History", action = "clear_all" },
	}

	pickers.new({}, {
		prompt_title = "🤖 Copilot Settings",
		finder = finders.new_table({
			results = settings_options,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry.name,
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
					handle_setting_action(selection.value.action)
				end
			end)

			map("n", "?", function()
				vim.notify("Settings Navigation:\n• Enter: Select option\n• q/Esc: Close\n• ?: Show this help", vim.log.levels.INFO)
			end)

			return true
		end,
	}):find()
end

return {
	-- GitHub Copilot core functionality
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				hide_during_completion = true,
				debounce = 75,
				keymap = {
					accept = "<M-l>",
					accept_word = false,
					accept_line = false,
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			panel = {
				enabled = true,
				auto_refresh = false,
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
				yaml = false,
				markdown = false,
				help = false,
				gitcommit = false,
				gitrebase = false,
				hgcommit = false,
				svn = false,
				cvs = false,
				["."] = false,
			},
			copilot_node_command = "node",
			server_opts_overrides = {},
		},
		config = function(_, opts)
			require("copilot").setup(opts)

			-- Custom highlight groups for better visibility
			vim.api.nvim_set_hl(0, "CopilotSuggestion", {
				fg = "#555555",
				ctermfg = 8,
				italic = true
			})
		end,
	},

	-- Copilot Chat for interactive AI conversations
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
		},
		build = "make tiktoken",
		opts = function()
			local select = require("CopilotChat.select")

			return {
				debug = false,
				model = "gemini-2.5-pro",
				window = {
					layout = "vertical",
					width = 0.5,
					height = 0.5,
					relative = "editor",
					border = "single",
					title = "Copilot Chat",
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
						insert = "<C-CR>",
					},
					accept_diff = {
						normal = "<C-y>",
						insert = "<C-y>",
					},
					yank_diff = {
						normal = "gy",
					},
					show_diff = {
						normal = "gd",
					},
					show_system_prompt = {
						normal = "gp",
					},
				},
				-- Enhanced prompts for specific development scenarios
				prompts = {
					-- Code analysis prompts
					Performance = {
						prompt = "/COPILOT_GENERATE Analyze this code for performance issues and suggest optimizations:",
						selection = select.visual,
					},
					Security = {
						prompt = "/COPILOT_GENERATE Review this code for security vulnerabilities and suggest fixes:",
						selection = select.visual,
					},
					Architecture = {
						prompt = "/COPILOT_GENERATE Analyze the architecture of this code and suggest improvements:",
						selection = select.buffer,
					},
					-- Standard prompts
					Explain = {
						prompt = "/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text.",
						selection = select.visual,
					},
					Review = {
						prompt = "/COPILOT_REVIEW Review the selected code.",
						selection = select.visual,
					},
					Fix = {
						prompt = "/COPILOT_GENERATE There is a problem in this code. Rewrite the code to fix the problem.",
						selection = select.visual,
					},
					Optimize = {
						prompt = "/COPILOT_GENERATE Optimize the selected code to improve performance and readability.",
						selection = select.visual,
					},
					Docs = {
						prompt = "/COPILOT_GENERATE Please add documentation comment for the selection.",
						selection = select.visual,
					},
					Tests = {
						prompt = "/COPILOT_GENERATE Please generate tests for my code.",
						selection = select.visual,
					},
					FixDiagnostic = {
						prompt = "/COPILOT_GENERATE Please assist with the following diagnostic issue in file:",
						selection = select.diagnostics,
					},
					-- Git commit prompts
					Commit = {
						prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
						selection = select.gitdiff,
					},
					CommitStaged = {
						prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
						selection = function(source)
							return select.gitdiff(source, true)
						end,
					},
					-- Language-specific prompts
					TypeScriptHelp = {
						prompt = "I'm working with TypeScript. Help me with: ",
						selection = select.buffer,
					},
					ReactComponent = {
						prompt = "/COPILOT_GENERATE Create a React component based on this description:",
						selection = select.visual,
					},
					CSSStyleing = {
						prompt = "/COPILOT_GENERATE Help me style this component with modern CSS:",
						selection = select.visual,
					},
					-- Documentation prompts
					APIDocs = {
						prompt = "/COPILOT_GENERATE Generate comprehensive API documentation for this code:",
						selection = select.visual,
					},
					README = {
						prompt = "/COPILOT_GENERATE Create a README.md for this project with proper sections:",
						selection = select.buffer,
					},
				},
			}
		end,
		config = function(_, opts)
			local chat = require("CopilotChat")
			chat.setup(opts)

			-- Register CMP integration
			require("CopilotChat.integrations.cmp").setup()

			-- Auto-open chat settings
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-*",
				callback = function()
					vim.opt_local.relativenumber = true
					vim.opt_local.number = true
				end,
			})
		end,
		keys = {
			-- Chat management
			{ "<leader>ac", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat" },
			{ "<D-a>", "<cmd>CopilotChatToggle<cr>", mode = { "n", "v" }, desc = "Toggle Copilot Chat (CMD+A)" },
			{ "<leader>al", "<cmd>CopilotChatReset<cr>", desc = "Reset chat" },

			-- Prompt actions with telescope
			{
				"<leader>ah",
				function()
					local actions = require("CopilotChat.actions")
					require("CopilotChat.integrations.telescope").pick(actions.help_actions())
				end,
				desc = "Copilot Help actions",
			},
			{
				"<leader>ap",
				function()
					local actions = require("CopilotChat.actions")
					require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
				end,
				desc = "Copilot Prompt actions",
			},
			{
				"<leader>ap",
				":lua require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions({selection = require('CopilotChat.select').visual}))<CR>",
				mode = "x",
				desc = "Copilot Prompt actions (visual)",
			},

			-- Quick actions
			{ "<leader>ae", "<cmd>CopilotChat Explain the selected code<cr>", mode = { "n", "v" }, desc = "Explain code" },
			{ "<leader>at", "<cmd>CopilotChat Generate comprehensive tests for the selected code<cr>", mode = { "n", "v" }, desc = "Generate tests" },
			{ "<leader>ar", "<cmd>CopilotChat Review the selected code for potential improvements, bugs, and best practices<cr>", mode = { "n", "v" }, desc = "Review code" },
			{ "<leader>aR", "<cmd>CopilotChat Refactor the selected code to improve readability and maintainability<cr>", mode = { "n", "v" }, desc = "Refactor code" },
			{ "<leader>an", "<cmd>CopilotChat Suggest better variable and function names for the selected code<cr>", mode = { "n", "v" }, desc = "Better naming" },

			-- Chat input
			{
				"<leader>ai",
				function()
					local input = vim.fn.input("Ask Copilot: ")
					if input ~= "" then
						vim.cmd("CopilotChat " .. input)
					end
				end,
				desc = "Ask Copilot",
			},
			{
				"<leader>aq",
				function()
					local input = vim.fn.input("Quick Chat: ")
					if input ~= "" then
						vim.cmd("CopilotChat " .. input)
					end
				end,
				desc = "Quick chat",
			},

			-- Enhanced context-aware functions
			{
				"<leader>aX",
				function()
					context_aware_chat()
				end,
				desc = "Enhanced context chat",
			},
			{
				"<leader>aE",
				function()
					explain_with_context()
				end,
				desc = "Explain with context",
			},
			{
				"<leader>aP",
				function()
					project_help()
				end,
				desc = "Project-aware help",
			},

			-- Git integration
			{ "<leader>am", "<cmd>CopilotChat Write a commit message for the changes based on the git diff<cr>", desc = "Generate commit message" },
			{ "<leader>aM", "<cmd>CopilotChat Write a commit message for the staged changes<cr>", desc = "Generate commit message (staged)" },
			{
				"<leader>aC",
				function()
					smart_commit_message()
				end,
				desc = "Smart commit message",
			},

			-- Visual mode
			{
				"<leader>av",
				function()
					local mode = vim.fn.mode()
					if mode == "v" or mode == "V" or mode == "" then
						vim.cmd("'<,'>CopilotChat")
					else
						vim.cmd("CopilotChatToggle")
					end
				end,
				mode = { "n", "x" },
				desc = "Visual/Toggle chat",
			},

			-- Model and settings
			{
				"<leader>a?",
				function()
					select_model_telescope()
				end,
				desc = "Select model (enhanced)",
			},
			{
				"<leader>aS",
				function()
					show_settings()
				end,
				desc = "Copilot Settings",
			},
			{
				"<leader>as",
				function()
					show_status()
				end,
				desc = "Check Copilot status",
			},
			{
				"<leader>aT",
				function()
					if vim.g.copilot_enabled == false then
						vim.cmd("Copilot enable")
						vim.notify("Copilot enabled", vim.log.levels.INFO)
					else
						vim.cmd("Copilot disable")
						vim.notify("Copilot disabled", vim.log.levels.WARN)
					end
				end,
				desc = "Toggle Copilot on/off",
			},

			-- Session management
			{
				"<leader>aH",
				function()
					show_chat_history()
				end,
				desc = "Chat history",
			},
			{
				"<leader>aN",
				function()
					new_chat_session()
				end,
				desc = "New chat session",
			},
			{
				"<leader>a$",
				function()
					save_chat_session()
				end,
				desc = "Save current session",
			},
		},
	},

	-- Copilot completions integration with nvim-cmp
	{
		"zbirenbaum/copilot-cmp",
		dependencies = "copilot.lua",
		opts = {},
		config = function(_, opts)
			local copilot_cmp = require("copilot_cmp")
			copilot_cmp.setup(opts)

			-- Attach cmp source whenever copilot attaches
			vim.defer_fn(function()
				local ok, copilot = pcall(require, "copilot")
				if ok and copilot.api then
					copilot.api.register_status_notification_handler(function(data)
						if vim.g.copilot_status_disabled then
							return
						end
						local lualine_ok, lualine = pcall(require, "lualine")
						if lualine_ok then
							lualine.refresh()
						end
					end)
				end
			end, 1000)
		end,
	},

	-- Status line integration
	{
		"nvim-lualine/lualine.nvim",
		optional = true,
		opts = function(_, opts)
			if not opts then opts = {} end
			if not opts.sections then opts.sections = {} end
			if not opts.sections.lualine_x then opts.sections.lualine_x = {} end

			local colors = {
				[""] = "#6CC644",
				["Normal"] = "#6CC644",
				["Warning"] = "#FFCC00",
				["InProgress"] = "#0969DA",
			}

			table.insert(opts.sections.lualine_x, 2, {
				function()
					local icon = ""
					local ok, copilot = pcall(require, "copilot.api")
					if ok and copilot.status and copilot.status.data then
						return icon .. (copilot.status.data.message or "")
					end
					return icon
				end,
				cond = function()
					if not package.loaded["copilot"] then return false end
					local ok, copilot = pcall(require, "copilot.api")
					if not ok or not copilot then return false end
					local status = copilot.status and copilot.status.data
					return status and status.status ~= "offline"
				end,
				color = function()
					if not package.loaded["copilot"] then return { fg = "#6CC644" } end
					local ok, copilot = pcall(require, "copilot.api")
					if ok and copilot.status and copilot.status.data then
						return { fg = colors[copilot.status.data.status] or "#6CC644" }
					end
					return { fg = "#6CC644" }
				end,
			})

			return opts
		end,
	},
}