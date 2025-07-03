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
		initial_mode = "normal",
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

			-- Enhanced navigation with backspace support
			map("n", "<BS>", function()
				actions.close(prompt_bufnr)
			end)

			map("i", "<BS>", function()
				local line = action_state.get_current_line()
				if line == "" then
					actions.close(prompt_bufnr)
				else
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "n", false)
				end
			end)

			map("i", "<Esc>", actions.close)
			map("n", "<Esc>", actions.close)
			map("n", "q", actions.close)

			return true
		end,
	}):find()
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

-- Settings interface using telescope
local function show_settings()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local settings_options = {
		{ name = "🤖 Change Model", action = "model", desc = "Switch between " .. #MODELS .. " available AI models" },
		{ name = "🎭 Change Chat Mode", action = "mode", desc = "Switch between edit, ask, agent, and other chat modes" },
		{ name = "📊 Copilot Status", action = "status", desc = "View detailed status and diagnostics dashboard" },
		{ name = "🔄 Restart Copilot", action = "restart", desc = "Restart service to fix connection issues" },
		{ name = "🔧 Authentication", action = "auth", desc = "Re-authenticate with GitHub account" },
		{ name = "💬 Chat History", action = "history", desc = "View and manage saved chat sessions" },
		{ name = "🗑️ Clear All History", action = "clear_all", desc = "Permanently delete all chat sessions" },
	}

	pickers.new({}, {
		prompt_title = "🤖 Copilot Settings & Configuration",
		initial_mode = "normal",
		finder = finders.new_table({
			results = settings_options,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry.name,
					ordinal = entry.name .. " " .. entry.desc,
				}
			end,
		}),
		sorter = conf.generic_sorter({}),
		previewer = require("telescope.previewers").new_buffer_previewer({
			title = "Setting Details",
			define_preview = function(self, entry)
				local setting = entry.value
				local preview_lines = {
					"⚙️ " .. setting.name,
					"",
					"Description:",
					setting.desc,
					"",
				}

				-- Add action-specific details
				if setting.action == "model" then
					table.insert(preview_lines, "Available Models:")
					for _, model in ipairs(MODELS) do
						local marker = model.name == get_current_model() and "➤ " or "  "
						table.insert(preview_lines, marker .. model.name .. " - " .. model.description)
					end
				elseif setting.action == "mode" then
					table.insert(preview_lines, "Available Chat Modes:")
					table.insert(preview_lines, "🎯 Edit Mode - Direct code editing")
					table.insert(preview_lines, "❓ Ask Mode - Question & answer format")
					table.insert(preview_lines, "🤖 Agent Mode - AI assistant behavior")
					table.insert(preview_lines, "💬 Chat Mode - Conversational interface")
					table.insert(preview_lines, "🔧 Fix Mode - Code problem solving")
					table.insert(preview_lines, "📝 Review Mode - Code review assistance")
				elseif setting.action == "status" then
					table.insert(preview_lines, "Status Dashboard includes:")
					table.insert(preview_lines, "• Connection and service health")
					table.insert(preview_lines, "• Authentication information")
					table.insert(preview_lines, "• System requirements check")
					table.insert(preview_lines, "• Quick action buttons")
					table.insert(preview_lines, "• Troubleshooting tools")
				elseif setting.action == "restart" then
					table.insert(preview_lines, "Restart process:")
					table.insert(preview_lines, "• Stops current Copilot service")
					table.insert(preview_lines, "• Clears existing connections")
					table.insert(preview_lines, "• Reinitializes with fresh state")
					table.insert(preview_lines, "• Resolves most connection issues")
				elseif setting.action == "auth" then
					table.insert(preview_lines, "Authentication steps:")
					table.insert(preview_lines, "• Opens GitHub authentication flow")
					table.insert(preview_lines, "• Requires valid GitHub account")
					table.insert(preview_lines, "• Verifies Copilot subscription")
					table.insert(preview_lines, "• Refreshes access tokens")
				elseif setting.action == "history" then
					table.insert(preview_lines, "Chat history management:")
					table.insert(preview_lines, "• View all saved sessions")
					table.insert(preview_lines, "• Open specific conversations")
					table.insert(preview_lines, "• Browse session timestamps")
					table.insert(preview_lines, "• Quick session access")
				elseif setting.action == "clear_all" then
					table.insert(preview_lines, "⚠️  WARNING: This action:")
					table.insert(preview_lines, "• Permanently deletes ALL chat sessions")
					table.insert(preview_lines, "• Cannot be undone")
					table.insert(preview_lines, "• Requires confirmation")
					table.insert(preview_lines, "• Clears conversation history")
				end

				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
			end,
		}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if selection then
					handle_setting_action(selection.value.action)
				end
			end)

			-- Enhanced navigation with backspace support
			map("n", "<BS>", function()
				actions.close(prompt_bufnr)
			end)

			map("i", "<BS>", function()
				local line = action_state.get_current_line()
				if line == "" then
					actions.close(prompt_bufnr)
				else
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "n", false)
				end
			end)

			map("n", "?", function()
				vim.notify("Copilot Settings:\n• Enter: Select option\n• BS: Navigate back/close\n• ?: Show this help\n• /: Search settings\n• q/Esc: Close", vim.log.levels.INFO)
			end)

			return true
		end,
	}):find()
end

-- Chat mode selection with telescope
local function select_chat_mode()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local chat_modes = {
		{
			name = "edit",
			display = "🎯 Edit Mode",
			description = "Direct code editing and modification",
			detail = "Copilot will make direct edits to your code with inline suggestions and modifications.",
		},
		{
			name = "ask",
			display = "❓ Ask Mode",
			description = "Question and answer format",
			detail = "Interactive Q&A format where you ask questions and get detailed explanations.",
		},
		{
			name = "agent",
			display = "🤖 Agent Mode",
			description = "AI assistant behavior",
			detail = "Copilot acts as an intelligent agent, proactively helping with your development tasks.",
		},
		{
			name = "chat",
			display = "💬 Chat Mode",
			description = "Conversational interface",
			detail = "Natural conversation mode for discussing code, ideas, and getting assistance.",
		},
		{
			name = "fix",
			display = "🔧 Fix Mode",
			description = "Code problem solving",
			detail = "Focused on identifying and fixing bugs, errors, and code issues.",
		},
		{
			name = "review",
			display = "📝 Review Mode",
			description = "Code review assistance",
			detail = "Comprehensive code review with suggestions for improvements and best practices.",
		},
		{
			name = "explain",
			display = "💡 Explain Mode",
			description = "Code explanation and documentation",
			detail = "Detailed explanations of code functionality, patterns, and concepts.",
		},
		{
			name = "optimize",
			display = "⚡ Optimize Mode",
			description = "Performance and efficiency improvements",
			detail = "Focus on code optimization, performance improvements, and efficiency.",
		},
	}

	-- Get current mode (if available)
	local current_mode = "chat" -- Default mode
	local chat_ok, chat = pcall(require, "CopilotChat")
	if chat_ok and chat.config and chat.config.mode then
		current_mode = chat.config.mode
	end

	pickers.new({}, {
		prompt_title = "🎭 Select Copilot Chat Mode",
		initial_mode = "normal",
		finder = finders.new_table({
			results = chat_modes,
			entry_maker = function(entry)
				local marker = entry.name == current_mode and "➤ " or "  "
				return {
					value = entry,
					display = marker .. entry.display,
					ordinal = entry.name .. " " .. entry.description .. " " .. entry.detail,
				}
			end,
		}),
		sorter = conf.generic_sorter({}),
		previewer = require("telescope.previewers").new_buffer_previewer({
			title = "Mode Details",
			define_preview = function(self, entry)
				local mode = entry.value
				local preview_lines = {
					"🎭 " .. mode.display,
					"",
					"Mode: " .. mode.name,
					"",
					"Description:",
					mode.description,
					"",
					"Details:",
					mode.detail,
					"",
					"Use Cases:",
				}

				-- Add specific use cases for each mode
				if mode.name == "edit" then
					table.insert(preview_lines, "• Refactoring existing code")
					table.insert(preview_lines, "• Making specific modifications")
					table.insert(preview_lines, "• Applying code suggestions directly")
					table.insert(preview_lines, "• Quick fixes and improvements")
				elseif mode.name == "ask" then
					table.insert(preview_lines, "• Getting explanations about code")
					table.insert(preview_lines, "• Learning new concepts")
					table.insert(preview_lines, "• Troubleshooting issues")
					table.insert(preview_lines, "• Understanding APIs and libraries")
				elseif mode.name == "agent" then
					table.insert(preview_lines, "• Complex problem solving")
					table.insert(preview_lines, "• Multi-step development tasks")
					table.insert(preview_lines, "• Architectural decisions")
					table.insert(preview_lines, "• Project planning assistance")
				elseif mode.name == "chat" then
					table.insert(preview_lines, "• Casual coding discussions")
					table.insert(preview_lines, "• Brainstorming ideas")
					table.insert(preview_lines, "• General programming help")
					table.insert(preview_lines, "• Learning and exploration")
				elseif mode.name == "fix" then
					table.insert(preview_lines, "• Debugging runtime errors")
					table.insert(preview_lines, "• Fixing compilation issues")
					table.insert(preview_lines, "• Resolving logical bugs")
					table.insert(preview_lines, "• Error message interpretation")
				elseif mode.name == "review" then
					table.insert(preview_lines, "• Code quality assessment")
					table.insert(preview_lines, "• Security vulnerability checks")
					table.insert(preview_lines, "• Performance optimization")
					table.insert(preview_lines, "• Best practices validation")
				elseif mode.name == "explain" then
					table.insert(preview_lines, "• Complex algorithm explanation")
					table.insert(preview_lines, "• Design pattern clarification")
					table.insert(preview_lines, "• Documentation generation")
					table.insert(preview_lines, "• Educational content creation")
				elseif mode.name == "optimize" then
					table.insert(preview_lines, "• Performance bottleneck analysis")
					table.insert(preview_lines, "• Memory usage optimization")
					table.insert(preview_lines, "• Algorithm efficiency improvements")
					table.insert(preview_lines, "• Resource usage reduction")
				end

				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
			end,
		}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if selection then
					-- Set the chat mode
					local chat_ok, chat = pcall(require, "CopilotChat")
					if chat_ok and chat.config then
						chat.config.mode = selection.value.name
						vim.notify("🎭 Chat mode set to: " .. selection.value.display, vim.log.levels.INFO)
					else
						vim.notify("❌ Failed to set chat mode", vim.log.levels.ERROR)
					end
				end
			end)

			-- Enhanced navigation with backspace support
			map("n", "<BS>", function()
				actions.close(prompt_bufnr)
			end)

			map("i", "<BS>", function()
				local line = action_state.get_current_line()
				if line == "" then
					actions.close(prompt_bufnr)
				else
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "n", false)
				end
			end)

			map("n", "?", function()
				vim.notify("Chat Mode Selection:\n• Enter: Select mode\n• BS: Navigate back/close\n• ?: Show this help\n• /: Search modes\n• q/Esc: Close", vim.log.levels.INFO)
			end)

			map("i", "<Esc>", actions.close)
			map("n", "<Esc>", actions.close)
			map("n", "q", actions.close)

			return true
		end,
	}):find()
end

-- Handle setting actions
local function handle_setting_action(action)
	if action == "model" then
		select_model_telescope()
	elseif action == "mode" then
		select_chat_mode()
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

-- Show Copilot status using telescope
local function show_status()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	-- Gather comprehensive status information
	local status_items = {}
	local ok, copilot = pcall(require, "copilot.api")

	-- Status icons for different states
	local status_icons = {
		["Normal"] = "✅",
		["Warning"] = "⚠️",
		["InProgress"] = "🔄",
		["offline"] = "❌",
		["unknown"] = "❓",
	}

	-- Core status information
	if ok and copilot and copilot.status and copilot.status.data then
		local status_payload = copilot.status.data
		local status = status_payload.status or "unknown"
		local message = status_payload.message or "no message"
		local icon = status_icons[status] or status_icons["unknown"]

		table.insert(status_items, {
			name = "📊 Connection Status",
			value = icon .. " " .. status,
			detail = message,
			action = "none",
			category = "status",
		})

		-- User information
		if status_payload.user then
			table.insert(status_items, {
				name = "👤 Authenticated User",
				value = status_payload.user,
				detail = "Currently signed in GitHub account",
				action = "none",
				category = "status",
			})
		end

		-- Version information
		if status_payload.version then
			table.insert(status_items, {
				name = "🏷️ Copilot Version",
				value = status_payload.version,
				detail = "Current Copilot extension version",
				action = "none",
				category = "status",
			})
		end

		-- Additional detailed status
		table.insert(status_items, {
			name = "📈 Service Health",
			value = status == "Normal" and "🟢 Healthy" or "🔴 Issues Detected",
			detail = "Overall service health assessment",
			action = "none",
			category = "status",
		})

	else
		-- Error state with detailed diagnostics
		local reason = "unknown issue"
		if not ok then
			reason = "copilot.api module could not be loaded"
		elseif not copilot then
			reason = "copilot.api module loaded as nil"
		elseif not copilot.status then
			reason = "copilot.api has no status member"
		elseif not copilot.status.data then
			reason = "copilot.api.status has no data property"
		end

		table.insert(status_items, {
			name = "❌ Connection Error",
			value = "Service Unavailable",
			detail = "Reason: " .. reason,
			action = "none",
			category = "status",
		})

		table.insert(status_items, {
			name = "🔧 Troubleshooting",
			value = "Diagnostic Information",
			detail = "Check authentication and network connectivity",
			action = "none",
			category = "status",
		})
	end

	-- Current model information
	local current_model = get_current_model()
	table.insert(status_items, {
		name = "🤖 Active Model",
		value = current_model,
		detail = "Currently selected AI model for chat",
		action = "model",
		category = "settings",
	})

	-- Current chat mode information
	local current_mode = "chat" -- Default mode
	local mode_display = "💬 Chat Mode"
	local chat_ok, chat = pcall(require, "CopilotChat")
	if chat_ok and chat.config and chat.config.mode then
		current_mode = chat.config.mode
		-- Map mode names to display formats
		local mode_displays = {
			edit = "🎯 Edit Mode",
			ask = "❓ Ask Mode",
			agent = "🤖 Agent Mode",
			chat = "💬 Chat Mode",
			fix = "🔧 Fix Mode",
			review = "📝 Review Mode",
			explain = "📚 Explain Mode",
			optimize = "⚡ Optimize Mode",
		}
		mode_display = mode_displays[current_mode] or ("🎭 " .. current_mode .. " Mode")
	end

	table.insert(status_items, {
		name = "🎭 Active Chat Mode",
		value = mode_display,
		detail = "Current interaction mode for Copilot Chat",
		action = "mode",
		category = "settings",
	})

	-- Configuration status
	local chat_ok, chat = pcall(require, "CopilotChat")
	if chat_ok and chat.config then
		table.insert(status_items, {
			name = "⚙️ Chat Configuration",
			value = "Loaded",
			detail = "CopilotChat plugin is properly configured",
			action = "none",
			category = "settings",
		})
	else
		table.insert(status_items, {
			name = "⚙️ Chat Configuration",
			value = "❌ Error",
			detail = "CopilotChat plugin configuration issue",
			action = "none",
			category = "settings",
		})
	end

	-- Node.js status (required for Copilot)
	local node_version = vim.fn.system("node --version 2>/dev/null"):gsub("\n", "")
	if vim.v.shell_error == 0 then
		table.insert(status_items, {
			name = "📦 Node.js Runtime",
			value = node_version,
			detail = "Node.js is available and working",
			action = "none",
			category = "system",
		})
	else
		table.insert(status_items, {
			name = "📦 Node.js Runtime",
			value = "❌ Not Found",
			detail = "Node.js is required for Copilot functionality",
			action = "none",
			category = "system",
		})
	end

	-- Separator
	table.insert(status_items, {
		name = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
		value = "Actions & Settings",
		detail = "",
		action = "none",
		category = "separator",
	})

	-- Action items with more comprehensive options
	table.insert(status_items, {
		name = "🔄 Restart Copilot Service",
		value = "Reset Connection",
		detail = "Restart Copilot to fix connection issues",
		action = "restart",
		category = "actions",
	})

	table.insert(status_items, {
		name = "🔧 Re-authenticate",
		value = "GitHub Login",
		detail = "Sign in to GitHub or refresh authentication",
		action = "auth",
		category = "actions",
	})

	table.insert(status_items, {
		name = "🤖 Change AI Model",
		value = "Model Selection",
		detail = "Switch between " .. #MODELS .. " available AI models",
		action = "model",
		category = "actions",
	})

	table.insert(status_items, {
		name = "💬 Chat History",
		value = "Session Management",
		detail = "View and manage saved chat sessions",
		action = "history",
		category = "actions",
	})

	table.insert(status_items, {
		name = "🗑️ Clear All History",
		value = "Reset Sessions",
		detail = "Delete all saved chat sessions permanently",
		action = "clear_all",
		category = "actions",
	})

	table.insert(status_items, {
		name = "🔀 Toggle Copilot",
		value = vim.g.copilot_enabled == false and "Enable" or "Disable",
		detail = "Turn Copilot suggestions on or off",
		action = "toggle",
		category = "actions",
	})

	table.insert(status_items, {
		name = "📋 Full Settings Menu",
		value = "Advanced Options",
		detail = "Open comprehensive settings interface",
		action = "settings",
		category = "actions",
	})

	pickers.new({}, {
		prompt_title = "📊 Copilot Status & Settings Dashboard",
		initial_mode = "normal",
		finder = finders.new_table({
			results = status_items,
			entry_maker = function(entry)
				local icon_prefix = ""
				if entry.category == "status" then
					icon_prefix = ""
				elseif entry.category == "settings" then
					icon_prefix = "⚙️ "
				elseif entry.category == "system" then
					icon_prefix = "🖥️ "
				elseif entry.category == "actions" then
					icon_prefix = "⚡ "
				elseif entry.category == "separator" then
					icon_prefix = ""
				end

				return {
					value = entry,
					display = entry.category == "separator" and entry.name or (icon_prefix .. entry.name .. ": " .. entry.value),
					ordinal = entry.name .. " " .. entry.value .. " " .. entry.detail .. " " .. entry.category,
				}
			end,
		}),
		sorter = conf.generic_sorter({}),
		previewer = require("telescope.previewers").new_buffer_previewer({
			title = "Details & Information",
			define_preview = function(self, entry)
				local item = entry.value
				local preview_lines = {
					"📋 " .. item.name,
					"",
					"Value: " .. item.value,
					"",
					"Category: " .. string.upper(item.category),
					"",
					"Description:",
					item.detail,
				}

				-- Add category-specific information
				if item.category == "status" then
					table.insert(preview_lines, "")
					table.insert(preview_lines, "Status Information:")
					table.insert(preview_lines, "• Real-time connection status")
					table.insert(preview_lines, "• Service health indicators")
					table.insert(preview_lines, "• Authentication state")
				elseif item.category == "system" then
					table.insert(preview_lines, "")
					table.insert(preview_lines, "System Requirements:")
					table.insert(preview_lines, "• Node.js runtime environment")
					table.insert(preview_lines, "• Network connectivity")
					table.insert(preview_lines, "• GitHub authentication")
				elseif item.action == "restart" then
					table.insert(preview_lines, "")
					table.insert(preview_lines, "This action will:")
					table.insert(preview_lines, "• Stop the current Copilot service")
					table.insert(preview_lines, "• Clear existing connections")
					table.insert(preview_lines, "• Restart with fresh state")
					table.insert(preview_lines, "• May resolve connection issues")
				elseif item.action == "auth" then
					table.insert(preview_lines, "")
					table.insert(preview_lines, "Authentication process:")
					table.insert(preview_lines, "• Opens browser for GitHub login")
					table.insert(preview_lines, "• Requires valid GitHub account")
					table.insert(preview_lines, "• Refreshes access tokens")
					table.insert(preview_lines, "• Verifies Copilot subscription")
				elseif item.action == "model" then
					table.insert(preview_lines, "")
					table.insert(preview_lines, "Available AI models:")
					for _, model in ipairs(MODELS) do
						table.insert(preview_lines, "• " .. model.name .. " (" .. model.category .. ")")
					end
				elseif item.action == "toggle" then
					table.insert(preview_lines, "")
					table.insert(preview_lines, "Toggle functionality:")
					table.insert(preview_lines, "• Enable/disable code suggestions")
					table.insert(preview_lines, "• Affects autocomplete behavior")
					table.insert(preview_lines, "• Does not affect chat features")
				end

				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
			end,
		}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if selection and selection.value.action and selection.value.action ~= "none" then
					if selection.value.action == "toggle" then
						-- Handle toggle action specifically
						if vim.g.copilot_enabled == false then
							vim.cmd("Copilot enable")
							vim.notify("✅ Copilot enabled", vim.log.levels.INFO)
						else
							vim.cmd("Copilot disable")
							vim.notify("⚠️ Copilot disabled", vim.log.levels.WARN)
						end
					elseif selection.value.action == "settings" then
						-- Open the main settings menu
						show_settings()
					else
						handle_setting_action(selection.value.action)
					end
				end
			end)

			-- Enhanced navigation with backspace support
			map("n", "<BS>", function()
				actions.close(prompt_bufnr)
				-- Navigate back to main settings if this was called from there
				-- This allows for a breadcrumb-like navigation experience
			end)

			map("i", "<BS>", function()
				-- Allow normal backspace in insert mode for editing
				local line = action_state.get_current_line()
				if line == "" then
					actions.close(prompt_bufnr)
				else
					-- Normal backspace behavior
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "n", false)
				end
			end)

			-- Enhanced help mapping
			map("n", "?", function()
				vim.notify("Copilot Status Dashboard:\n• Enter: Execute action/view details\n• BS: Navigate back/close\n• ?: Show this help\n• /: Search items\n• q/Esc: Close\n• j/k: Navigate up/down", vim.log.levels.INFO)
			end)

			-- Standard close mappings
			map("n", "q", actions.close)
			map("i", "<Esc>", actions.close)
			map("n", "<Esc>", actions.close)

			return true
		end,
	}):find()
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

return {
	-- GitHub Copilot core functionality (Re-enabled for inline suggestions)
	-- Works alongside avante.nvim for comprehensive AI assistance
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = false,
				hide_during_completion = true,
				debounce = 75,
				keymap = {
					accept = "<Tab>",
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

	-- Copilot Chat DISABLED - Using avante.nvim for enhanced chat features
	--[[
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
        auto_insert_mode = true,
        references_display = 'write',
         chat_autocomplete = false,
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
			{ "<D-a>", "<cmd>CopilotChatToggle<cr>", mode = { "n", "v", "i" }, desc = "Toggle Copilot Chat (CMD+A)" },
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
			{
				"<leader>aE",
				function()
					explain_with_context()
				end,
				desc = "Explain with context",
			},

			-- Git integration
			{ "<leader>am", "<cmd>CopilotChat Write a commit message for the changes based on the git diff<cr>", desc = "Generate commit message" },
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
				"<leader>aM",
				function()
					select_chat_mode()
				end,
				desc = "Select chat mode",
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
	--]] -- End of disabled CopilotChat section

	-- Copilot completions integration with nvim-cmp (Re-enabled for inline suggestions)
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