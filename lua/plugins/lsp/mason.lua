return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "rcarriga/nvim-notify",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")

    -- Set up notify if available
    local has_notify, notify = pcall(require, "notify")
    if has_notify then
      vim.notify = notify
    end

    -- Check network connectivity before Mason operations
    local function check_network_connectivity()
      local handle = io.popen("ping -c 1 -W 3000 github.com 2>/dev/null && echo 'online' || echo 'offline'")
      if not handle then
        return false
      end
      local result = handle:read("*a")
      handle:close()
      return result and result:match("online")
    end

    -- Enhanced error handling for network issues
    local function safe_mason_setup()
      local is_online = check_network_connectivity()

      if not is_online then
        vim.notify("⚠️  Network connectivity limited - Mason will skip automatic installations", vim.log.levels.WARN)

        -- Setup Mason in offline mode (minimal configuration)
        pcall(function()
          mason.setup({
            ui = {
              icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗",
              },
            },
            log_level = vim.log.levels.WARN, -- Reduce log noise when offline
            -- Disable automatic installations when offline
            automatic_installation = false,
          })
        end)

        -- Setup mason-lspconfig without automatic installations
        pcall(function()
          mason_lspconfig.setup({
            automatic_installation = false, -- Don't try to install when offline
          })
        end)

        return false -- Indicate offline mode
      end

      -- Normal online setup
      mason.setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
        log_level = vim.log.levels.INFO,
        -- Enhanced timeout settings for slow connections
        install_root_dir = vim.fn.stdpath("data") .. "/mason",
        pip = {
          upgrade_pip = false, -- Disable pip upgrade to avoid network issues
        },
        providers = {
          "mason.providers.registry-api",
          "mason.providers.client",
        },
      })

      mason_lspconfig.setup({
        -- list of servers for mason to install
        ensure_installed = {
          -- "tsserver",
          "html",
          "cssls",
          "tailwindcss",
          "svelte",
          "lua_ls",
          "graphql",
          "emmet_ls",
          "prismals",
          "pyright",
          "ruff", -- Modern Python linting/formatting
          "eslint",
          "bashls",
          "csharp_ls",
        },
        automatic_installation = true,
      })

      return true -- Indicate online mode
    end

    -- Attempt safe setup with error handling
    local setup_success, setup_result = pcall(safe_mason_setup)

    if not setup_success then
      vim.notify("⚠️  Mason setup failed - continuing without automatic tool installation\nError: " .. tostring(setup_result), vim.log.levels.WARN)
      return
    end

    -- Only try to install tools if we're online and setup succeeded
    if setup_result then
      pcall(function()
        mason_tool_installer.setup({
          ensure_installed = {
            "prettier", -- prettier formatter
            "stylua", -- lua formatter
            "isort", -- python formatter
            "black", -- python formatter
            "ruff", -- python linting and formatting (replaces flake8, pylint, etc.)
            "mypy", -- python type checker
            "debugpy", -- python debugger
            "pylint", -- python linter (legacy support)
            "eslint_d",
            "shfmt", -- shell script formatter
            "shellcheck", -- shell script linter
            "csharpier", -- C# formatter
            "xmlformatter", -- XML formatter for C# projects
          },
          -- Enhanced error handling
          auto_update = false, -- Disable auto-update to prevent network errors
          run_on_start = false, -- Don't run on startup to avoid blocking
        })

        -- Defer the installation check to avoid startup blocking
        vim.defer_fn(function()
          if check_network_connectivity() then
            -- Only run installation check if we have network
            pcall(function()
              require("mason-tool-installer").run_on_start()
            end)
          end
        end, 2000) -- Wait 2 seconds after startup
      end)
    end

    -- Add command to manually retry Mason setup when network is available
    vim.api.nvim_create_user_command("MasonRetrySetup", function()
      if check_network_connectivity() then
        vim.notify("🔄 Retrying Mason setup with network connectivity...", vim.log.levels.INFO)
        pcall(function()
          require("mason-tool-installer").run_on_start()
        end)
      else
        vim.notify("❌ Still no network connectivity available", vim.log.levels.WARN)
      end
    end, { desc = "Retry Mason setup when network is available" })
  end,
}