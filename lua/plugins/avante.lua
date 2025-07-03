-- Avante.nvim configuration for macOS
-- AI-powered code assistant using GitHub Copilot backend

return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = function()
      -- Build command that works better on macOS
      if vim.fn.has("macunix") == 1 then
        return "make BUILD_FROM_SOURCE=false"
      else
        return "make"
      end
    end,
    opts = {
      provider = "copilot", -- Using your GitHub Copilot subscription
      auto_suggestions = false,
      -- Provider configurations
      providers = {
        copilot = {
          endpoint = "https://api.githubcopilot.com",
          model = "gpt-4o-2024-05-13",
          proxy = nil,
          allow_insecure = false,
          timeout = 30000,
          temperature = 0,
          max_tokens = 4096,
        },
        ollama = {
          endpoint = "http://127.0.0.1:11434/v1",
          model = "qwen2.5:8b",
          parse_curl_args = function(opts, code_opts)
            return {
              url = opts.endpoint .. "/chat/completions",
              headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
              },
              body = {
                model = opts.model,
                messages = require("avante.providers").copilot.parse_message(code_opts),
                max_tokens = 4096,
                stream = true,
                temperature = 0.7,
              },
            }
          end,
          parse_response_data = function(data_stream, event_state, opts)
            require("avante.providers").openai.parse_response(data_stream, event_state, opts)
          end,
        },
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
        minimize_diff = true,
      },
      windows = {
        position = "right",
        width = 35,
        wrap = true,
        sidebar_header = {
          enabled = true,
          align = "center",
          rounded = true,
        },
        input = {
          prefix = "> ",
          height = 8,
        },
        ask = {
          floating = false,
          start_insert = true,
          border = "rounded",
          focus_on_apply = "ours",
        },
        edit = {
          border = "rounded",
          start_insert = true,
        },
      },
      highlights = {
        diff = {
          current = "DiffText",
          incoming = "DiffAdd",
        },
      },
      mappings = {
        diff = {
          ours = "co",
          theirs = "ct",
          all_theirs = "ca",
          both = "cb",
          cursor = "cc",
          next = "]x",
          prev = "[x",
        },
        suggestion = {
          accept = "<Tab>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
        jump = {
          next = "]]",
          prev = "[[",
        },
        submit = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        sidebar = {
          apply_all = "A",
          apply_cursor = "a",
          switch_windows = "<Tab>",
          reverse_switch_windows = "<S-Tab>",
        },
      },
    },    keys = {
      -- Primary toggle (Cmd+A for macOS - Cursor-like)
      { "<D-a>", "<cmd>AvanteToggle<cr>", mode = { "n", "v", "i" }, desc = "Toggle Avante Chat (Cmd+A)" },
      { "<leader>ac", "<cmd>AvanteToggle<cr>", desc = "Toggle Avante Chat" },
      { "<leader>av", "<cmd>AvanteToggle<cr>", mode = { "v" }, desc = "Toggle Chat with selection" },

      -- Core chat functionality
      { "<leader>ai", "<cmd>AvanteAsk<cr>", desc = "Ask Avante" },
      { "<leader>af", "<cmd>AvanteFocus<cr>", desc = "Focus Avante" },
      { "<leader>al", "<cmd>AvanteClear<cr>", desc = "Clear chat" },
      { "<leader>aR", "<cmd>AvanteRefresh<cr>", desc = "Refresh Avante" },

      -- Native Avante history features
      { "<leader>ah", "<cmd>AvanteHistory<cr>", desc = "Avante history" },
      { "<D-4>", "<cmd>AvanteHistory<cr>", desc = "Avante history" },
      { "[a", avante_history_nav, desc = "Chat history selector" },
      { "]a", avante_history_nav, desc = "Chat history selector" },

      -- Code assistance (visual mode only)
      { "<leader>ae", "<cmd>AvanteAsk Explain the selected code in detail<cr>", mode = { "v" }, desc = "Explain code" },
      { "<leader>at", "<cmd>AvanteAsk Generate comprehensive tests for the selected code<cr>", mode = { "v" }, desc = "Generate tests" },
      { "<leader>ar", "<cmd>AvanteAsk Review the selected code for bugs, performance issues, and improvements<cr>", mode = { "v" }, desc = "Review code" },
      { "<leader>ad", "<cmd>AvanteAsk Add detailed documentation and comments for the selected code<cr>", mode = { "v" }, desc = "Add docs" },
      { "<leader>ao", "<cmd>AvanteAsk Optimize the selected code for performance and readability<cr>", mode = { "v" }, desc = "Optimize code" },
      { "<leader>aD", "<cmd>AvanteAsk Debug the selected code and identify potential issues<cr>", mode = { "v" }, desc = "Debug code" },
      { "<leader>aF", "<cmd>AvanteAsk Fix and refactor the selected code<cr>", mode = { "v" }, desc = "Fix code" },

      -- Advanced AI features
      { "<leader>aC", "<cmd>AvanteChat<cr>", desc = "Open Avante Chat" },
      { "<leader>aE", "<cmd>AvanteEdit<cr>", desc = "Edit with Avante" },
      { "<leader>aA", "<cmd>AvanteApply<cr>", desc = "Apply suggestions" },

      -- Git integration
      { "<leader>am", "<cmd>AvanteAsk Generate a detailed commit message based on git diff<cr>", desc = "Generate commit message" },
      { "<leader>aG", "<cmd>AvanteGitAnalyze<cr>", desc = "Analyze git changes" },

      -- Provider and settings management
      { "<leader>ap", "<cmd>AvanteSwitchProvider<cr>", desc = "Switch AI provider" },
      { "<leader>aT", "<cmd>AvanteTestOllama<cr>", desc = "Test Ollama connection" },
      { "<leader>aP", "<cmd>AvanteTestProvider<cr>", desc = "Test current provider" },
      { "<leader>aI", "<cmd>AvanteInfo<cr>", desc = "Show Avante info" },

      -- Quick context actions
      { "<leader>aq", "<cmd>AvanteQuickChat<cr>", desc = "Quick chat" },
      { "<leader>aX", "<cmd>AvanteExplain<cr>", desc = "Explain current context" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua", -- for copilot provider
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
    config = function(_, opts)
      require("avante_lib").load()
      require("avante").setup(opts)

      -- Provider switching function (improved)
      local function switch_provider()
        local providers = {
          { name = "copilot", display = "🤖 GitHub Copilot (gpt-4o)", description = "Uses your GitHub Copilot subscription" },
          { name = "ollama", display = "🦙 Local Ollama (Qwen 2.5 8B)", description = "Local Qwen 2.5 8B model via Ollama" },
        }

        local provider_options = {}
        for _, provider in ipairs(providers) do
          table.insert(provider_options, provider.display)
        end

        vim.ui.select(provider_options, {
          prompt = "Select AI Provider:",
          format_item = function(item)
            return item
          end,
        }, function(choice, idx)
          if choice and idx then
            local selected_provider = providers[idx]

            -- Method 1: Try to update the running config
            local avante_ok, avante = pcall(require, "avante")
            local config_updated = false

            if avante_ok and avante.config then
              avante.config.provider = selected_provider.name
              config_updated = true
            end

            -- Method 2: Try to call avante's built-in switch function if available
            if avante_ok and avante.switch_provider then
              pcall(avante.switch_provider, selected_provider.name)
              config_updated = true
            end

            -- Method 3: Use vim variables as fallback
            vim.g.avante_provider = selected_provider.name

            if config_updated then
              vim.notify("🔄 Switched to " .. selected_provider.display, vim.log.levels.INFO)
            else
              vim.notify("🔄 Switched to " .. selected_provider.display .. " (restart Neovim to apply)", vim.log.levels.WARN)
            end

            -- Clear current chat to avoid confusion
            pcall(vim.cmd, "AvanteClear")
          end
        end)
      end

      -- Test functions
      local function test_ollama_connection()
        local curl_cmd = "curl -s http://127.0.0.1:11434/api/tags"
        local handle = io.popen(curl_cmd)
        if handle then
          local result = handle:read("*a")
          handle:close()
          if result and result ~= "" then
            vim.notify("🦙 Ollama connection successful!", vim.log.levels.INFO)
            return true
          end
        end
        vim.notify("❌ Ollama not running on port 11434", vim.log.levels.WARN)
        return false
      end

      local function test_current_provider()
        local avante_ok, avante = pcall(require, "avante")
        if avante_ok and avante.config then
          local current_provider = avante.config.provider or "unknown"
          vim.notify("🔍 Current provider: " .. current_provider, vim.log.levels.INFO)
        else
          local fallback_provider = vim.g.avante_provider or "not set"
          vim.notify("🔍 Provider (fallback): " .. fallback_provider, vim.log.levels.INFO)
        end
      end

      -- Quick actions
      local function avante_quick_chat()
        local input = vim.fn.input("Quick question: ")
        if input ~= "" then
          vim.cmd("AvanteAsk " .. input)
        end
      end

      local function avante_explain_context()
        local line = vim.fn.line(".")
        local filename = vim.fn.expand("%:t")
        local filetype = vim.bo.filetype
        local context = string.format("Explain this %s code in file '%s' at line %d", filetype, filename, line)
        vim.cmd("AvanteAsk " .. context)
      end

      local function avante_git_analyze()
        local has_git = vim.fn.system("git rev-parse --git-dir 2>/dev/null"):match("^%.git") ~= nil
        if not has_git then
          vim.notify("❌ Not in a git repository", vim.log.levels.ERROR)
          return
        end

        local diff = vim.fn.system("git diff --staged")
        if diff == "" then
          diff = vim.fn.system("git diff")
        end

        if diff == "" then
          vim.notify("📝 No changes to analyze", vim.log.levels.WARN)
          return
        end

        vim.cmd("AvanteAsk Analyze these git changes and suggest improvements:\\n" .. diff)
      end

      -- Simple history navigation (opens history selector)
      local function avante_history_nav()
        vim.notify("📚 Opening chat history...", vim.log.levels.INFO)
        require("avante.api").select_history()
      end

      -- Provider switching function (improved)
      local function switch_provider()
        local providers = {
          { name = "copilot", display = "🤖 GitHub Copilot (gpt-4o)", description = "Uses your GitHub Copilot subscription" },
          { name = "ollama", display = "🦙 Local Ollama (Qwen 2.5 8B)", description = "Local Qwen 2.5 8B model via Ollama" },
        }

        local provider_options = {}
        for _, provider in ipairs(providers) do
          table.insert(provider_options, provider.display)
        end

        vim.ui.select(provider_options, {
          prompt = "Select AI Provider:",
          format_item = function(item)
            return item
          end,
        }, function(choice, idx)
          if choice and idx then
            local selected_provider = providers[idx]

            -- Method 1: Try to update the running config
            local avante_ok, avante = pcall(require, "avante")
            local config_updated = false

            if avante_ok and avante.config then
              avante.config.provider = selected_provider.name
              config_updated = true
            end

            -- Method 2: Try to call avante's built-in switch function if available
            if avante_ok and avante.switch_provider then
              pcall(avante.switch_provider, selected_provider.name)
              config_updated = true
            end

            -- Method 3: Use vim variables as fallback
            vim.g.avante_provider = selected_provider.name

            if config_updated then
              vim.notify("🔄 Switched to " .. selected_provider.display, vim.log.levels.INFO)
            else
              vim.notify("🔄 Switched to " .. selected_provider.display .. " (restart Neovim to apply)", vim.log.levels.WARN)
            end

            -- Clear current chat to avoid confusion
            pcall(vim.cmd, "AvanteClear")
          end
        end)
      end

      -- Test functions
      local function test_ollama_connection()
        local curl_cmd = "curl -s http://127.0.0.1:11434/api/tags"
        local handle = io.popen(curl_cmd)
        if handle then
          local result = handle:read("*a")
          handle:close()
          if result and result ~= "" then
            vim.notify("🦙 Ollama connection successful!", vim.log.levels.INFO)
            return true
          end
        end
        vim.notify("❌ Ollama not running on port 11434", vim.log.levels.WARN)
        return false
      end

      local function test_current_provider()
        local avante_ok, avante = pcall(require, "avante")
        if avante_ok and avante.config then
          local current_provider = avante.config.provider or "unknown"
          vim.notify("🔍 Current provider: " .. current_provider, vim.log.levels.INFO)
        else
          local fallback_provider = vim.g.avante_provider or "not set"
          vim.notify("🔍 Provider (fallback): " .. fallback_provider, vim.log.levels.INFO)
        end
      end

      -- Quick actions
      local function avante_quick_chat()
        local input = vim.fn.input("Quick question: ")
        if input ~= "" then
          vim.cmd("AvanteAsk " .. input)
        end
      end

      local function avante_explain_context()
        local line = vim.fn.line(".")
        local filename = vim.fn.expand("%:t")
        local filetype = vim.bo.filetype
        local context = string.format("Explain this %s code in file '%s' at line %d", filetype, filename, line)
        vim.cmd("AvanteAsk " .. context)
      end

      local function avante_git_analyze()
        local has_git = vim.fn.system("git rev-parse --git-dir 2>/dev/null"):match("^%.git") ~= nil
        if not has_git then
          vim.notify("❌ Not in a git repository", vim.log.levels.ERROR)
          return
        end

        local diff = vim.fn.system("git diff --staged")
        if diff == "" then
          diff = vim.fn.system("git diff")
        end

        if diff == "" then
          vim.notify("� No changes to analyze", vim.log.levels.WARN)
          return
        end

        vim.cmd("AvanteAsk Analyze these git changes and suggest improvements:\\n" .. diff)
      end

      -- Register essential commands
      vim.api.nvim_create_user_command("AvanteSwitchProvider", switch_provider, {})
      vim.api.nvim_create_user_command("AvanteTestOllama", test_ollama_connection, {})
      vim.api.nvim_create_user_command("AvanteTestProvider", test_current_provider, {})
      vim.api.nvim_create_user_command("AvanteQuickChat", avante_quick_chat, {})
      vim.api.nvim_create_user_command("AvanteExplain", avante_explain_context, {})
      vim.api.nvim_create_user_command("AvanteGitAnalyze", avante_git_analyze, {})
      vim.api.nvim_create_user_command("AvanteHistoryNav", avante_history_nav, {})

      -- Custom highlight groups for enhanced UI
      vim.api.nvim_set_hl(0, "AvanteTitle", { fg = "#6CC644", bold = true })
      vim.api.nvim_set_hl(0, "AvanteSubtitle", { fg = "#FFCC00", italic = true })
      vim.api.nvim_set_hl(0, "AvanteHistory", { fg = "#58A6FF", italic = true })
      vim.api.nvim_set_hl(0, "AvanteSession", { fg = "#F78166", bold = true })

      -- Test Ollama connection on startup
      vim.defer_fn(function()
        test_ollama_connection()
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        vim.notify("🚀 Avante.nvim loaded for project: " .. project_name, vim.log.levels.INFO)
      end, 1000)
    end,
  },
}
