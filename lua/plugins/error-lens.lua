-- Error Lens Plugin for Neovim - ThePrimeagen Style
-- Beautiful inline error display similar to VS Code Error Lens extension

return {
  -- Tiny inline diagnostic plugin - ThePrimeagen inspired
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    config = function()
      -- Initialize lsp_lines for better diagnostic display
      require("lsp_lines").setup()

      -- Start with lsp_lines disabled (we'll enable our custom virtual text instead)
      vim.diagnostic.config({
        virtual_lines = false,
      })
    end,
  },

  -- Main Error Lens Implementation
  {
    name = "primeagen-error-lens",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      -- Error Lens Configuration - ThePrimeagen Style
      local M = {}

      -- State management
      M.enabled = true
      M.namespace = vim.api.nvim_create_namespace("error_lens")

      -- Configuration matching your theme
      M.config = {
        enabled = true,
        auto_adjust = true,
        throttle_ms = 50,

        -- Theme-aware colors matching your no-clown-fiesta setup
        colors = {
          error = "#b46958",      -- Red matching your theme
          warn = "#F4BF75",       -- Yellow matching your theme
          info = "#BAD7FF",       -- Blue matching your theme
          hint = "#88afa2",       -- Cyan matching your theme
        },

        -- Icons matching your existing diagnostic setup
        icons = {
          error = " ",
          warn = " ",
          info = " ",
          hint = " "
        },

        -- Prefix configuration
        prefix = {
          error = "■ ",
          warn = "▲ ",
          info = "● ",
          hint = "◆ "
        },

        -- Formatting options
        format = {
          max_width = 80,
          wrap_text = true,
          spacing = 2,          -- spaces between code and diagnostic
          right_align = false,  -- ThePrimeagen style: left-aligned
        }
      }

      -- Setup highlight groups matching your theme
      local function setup_highlights()
        vim.api.nvim_set_hl(0, "ErrorLensError", {
          fg = M.config.colors.error,
          bg = "NONE",
          italic = true,
          bold = false
        })

        vim.api.nvim_set_hl(0, "ErrorLensWarn", {
          fg = M.config.colors.warn,
          bg = "NONE",
          italic = true,
          bold = false
        })

        vim.api.nvim_set_hl(0, "ErrorLensInfo", {
          fg = M.config.colors.info,
          bg = "NONE",
          italic = true,
          bold = false
        })

        vim.api.nvim_set_hl(0, "ErrorLensHint", {
          fg = M.config.colors.hint,
          bg = "NONE",
          italic = true,
          bold = false
        })
      end

      -- Get highlight group for severity
      local function get_hl_group(severity)
        if severity == vim.diagnostic.severity.ERROR then
          return "ErrorLensError"
        elseif severity == vim.diagnostic.severity.WARN then
          return "ErrorLensWarn"
        elseif severity == vim.diagnostic.severity.INFO then
          return "ErrorLensInfo"
        elseif severity == vim.diagnostic.severity.HINT then
          return "ErrorLensHint"
        end
        return "ErrorLensHint"
      end

      -- Get icon for severity
      local function get_icon(severity)
        if severity == vim.diagnostic.severity.ERROR then
          return M.config.icons.error
        elseif severity == vim.diagnostic.severity.WARN then
          return M.config.icons.warn
        elseif severity == vim.diagnostic.severity.INFO then
          return M.config.icons.info
        elseif severity == vim.diagnostic.severity.HINT then
          return M.config.icons.hint
        end
        return M.config.icons.hint
      end

      -- Get prefix for severity
      local function get_prefix(severity)
        if severity == vim.diagnostic.severity.ERROR then
          return M.config.prefix.error
        elseif severity == vim.diagnostic.severity.WARN then
          return M.config.prefix.warn
        elseif severity == vim.diagnostic.severity.INFO then
          return M.config.prefix.info
        elseif severity == vim.diagnostic.severity.HINT then
          return M.config.prefix.hint
        end
        return M.config.prefix.hint
      end

      -- Format diagnostic message
      local function format_message(diagnostic, line_length)
        local message = diagnostic.message or ""
        local prefix = get_prefix(diagnostic.severity)
        local icon = get_icon(diagnostic.severity)

        -- Clean up the message
        message = message:gsub("\n", " "):gsub("\r", "")
        message = message:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

        -- Truncate if too long (ThePrimeagen style - keep it concise)
        local max_width = M.config.format.max_width
        local available_width = max_width - line_length - M.config.format.spacing - #prefix - #icon

        if #message > available_width and available_width > 10 then
          message = message:sub(1, available_width - 3) .. "..."
        end

        return prefix .. message
      end

      -- Clear all error lens decorations for a buffer
      local function clear_error_lens(bufnr)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, 0, -1)
      end

      -- Show error lens for current buffer
      local function show_error_lens(bufnr)
        if not M.enabled then return end

        bufnr = bufnr or vim.api.nvim_get_current_buf()

        -- Skip if buffer is not valid or is a special buffer
        if not vim.api.nvim_buf_is_valid(bufnr) then return end

        local filetype = vim.bo[bufnr].filetype
        local excluded_filetypes = {
          "help", "dashboard", "alpha", "lazy", "mason", "trouble", "oil",
          "NvimTree", "neo-tree", "terminal", "toggleterm", "notify", "noice",
          "TelescopePrompt", "TelescopeResults", "TelescopePreview"
        }

        for _, ft in ipairs(excluded_filetypes) do
          if filetype == ft then return end
        end

        -- Clear existing decorations
        clear_error_lens(bufnr)

        -- Get diagnostics for current buffer (ONLY ERRORS)
        local diagnostics = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
        if not diagnostics or #diagnostics == 0 then return end

        -- Group diagnostics by line
        local diagnostics_by_line = {}
        for _, diagnostic in ipairs(diagnostics) do
          local lnum = diagnostic.lnum
          if not diagnostics_by_line[lnum] then
            diagnostics_by_line[lnum] = {}
          end
          table.insert(diagnostics_by_line[lnum], diagnostic)
        end

        -- Show diagnostics inline
        for lnum, line_diagnostics in pairs(diagnostics_by_line) do
          if vim.api.nvim_buf_is_valid(bufnr) then
            -- Get the line content to calculate spacing
            local line_content = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
            local line_length = #line_content

            -- Sort by severity (errors first)
            table.sort(line_diagnostics, function(a, b)
              return a.severity < b.severity
            end)

            -- Take the most severe diagnostic for this line (ThePrimeagen style - one per line)
            local diagnostic = line_diagnostics[1]
            local message = format_message(diagnostic, line_length)
            local hl_group = get_hl_group(diagnostic.severity)

            -- Create spacing
            local spacing = string.rep(" ", M.config.format.spacing)
            local full_text = spacing .. message

            -- Set virtual text
            pcall(vim.api.nvim_buf_set_extmark, bufnr, M.namespace, lnum, 0, {
              virt_text = {{ full_text, hl_group }},
              virt_text_pos = "eol",
              hl_mode = "combine",
              priority = 100,
            })
          end
        end
      end

      -- Throttled update function
      local update_timer = nil
      local function throttled_update(bufnr)
        if update_timer then
          update_timer:stop()
        end

        update_timer = vim.defer_fn(function()
          show_error_lens(bufnr)
          update_timer = nil
        end, M.config.throttle_ms)
      end

      -- Toggle error lens on/off
      function M.toggle()
        M.enabled = not M.enabled
        local bufnr = vim.api.nvim_get_current_buf()

        if M.enabled then
          show_error_lens(bufnr)
          vim.notify("🔍 Error Lens enabled", vim.log.levels.INFO)
        else
          clear_error_lens(bufnr)
          vim.notify("👁️ Error Lens disabled", vim.log.levels.INFO)
        end
      end

      -- Enable/disable functions
      function M.enable()
        M.enabled = true
        show_error_lens()
        vim.notify("🔍 Error Lens enabled", vim.log.levels.INFO)
      end

      function M.disable()
        M.enabled = false
        clear_error_lens()
        vim.notify("👁️ Error Lens disabled", vim.log.levels.INFO)
      end

      -- Refresh current buffer (for external integrations)
      function M.refresh_current_buffer()
        if M.enabled then
          local bufnr = vim.api.nvim_get_current_buf()
          show_error_lens(bufnr)
        end
      end

      -- Get current status
      function M.is_enabled()
        return M.enabled
      end

      -- LSP Lines toggle functions
      local function toggle_lsp_lines()
        local current_config = vim.diagnostic.config()
        local new_state = not current_config.virtual_lines

        vim.diagnostic.config({
          virtual_lines = new_state,
        })

        if new_state then
          vim.notify("📏 LSP Lines enabled", vim.log.levels.INFO)
        else
          vim.notify("📏 LSP Lines disabled", vim.log.levels.INFO)
        end
      end

      local function enable_lsp_lines()
        vim.diagnostic.config({
          virtual_lines = true,
        })
        vim.notify("📏 LSP Lines enabled", vim.log.levels.INFO)
      end

      local function disable_lsp_lines()
        vim.diagnostic.config({
          virtual_lines = false,
        })
        vim.notify("📏 LSP Lines disabled", vim.log.levels.INFO)
      end

      -- Combined toggle function for both Error Lens and LSP Lines
      local function toggle_all_diagnostics()
        M.toggle()
        toggle_lsp_lines()
      end

      -- Setup function
      function M.setup()
        -- Setup highlights
        setup_highlights()

        -- Ensure highlights persist after colorscheme changes
        vim.api.nvim_create_autocmd("ColorScheme", {
          group = vim.api.nvim_create_augroup("ErrorLensHighlights", { clear = true }),
          callback = setup_highlights,
        })

        -- Auto-update on diagnostic changes
        vim.api.nvim_create_autocmd("DiagnosticChanged", {
          group = vim.api.nvim_create_augroup("ErrorLensUpdate", { clear = true }),
          callback = function(ev)
            throttled_update(ev.buf)
          end,
        })

        -- Update on buffer enter/leave for proper cleanup
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
          group = vim.api.nvim_create_augroup("ErrorLensBuffer", { clear = true }),
          callback = function(ev)
            vim.defer_fn(function()
              if vim.api.nvim_buf_is_valid(ev.buf) then
                show_error_lens(ev.buf)
              end
            end, 100)
          end,
        })

        -- Clean up on buffer leave
        vim.api.nvim_create_autocmd("BufLeave", {
          group = vim.api.nvim_create_augroup("ErrorLensCleanup", { clear = true }),
          callback = function(ev)
            if update_timer then
              update_timer:stop()
              update_timer = nil
            end
          end,
        })

        -- Initial setup for current buffer
        vim.defer_fn(function()
          show_error_lens()
        end, 100)
      end

      -- Commands for manual control
      vim.api.nvim_create_user_command("ErrorLensToggle", M.toggle, { desc = "Toggle Error Lens" })
      vim.api.nvim_create_user_command("ErrorLensEnable", M.enable, { desc = "Enable Error Lens" })
      vim.api.nvim_create_user_command("ErrorLensDisable", M.disable, { desc = "Disable Error Lens" })
      vim.api.nvim_create_user_command("ErrorLensRefresh", M.refresh_current_buffer, { desc = "Refresh Error Lens for current buffer" })
      vim.api.nvim_create_user_command("ErrorLensStatus", function()
        local status = M.enabled and "enabled" or "disabled"
        vim.notify(string.format("Error Lens is %s", status), vim.log.levels.INFO)
      end, { desc = "Show Error Lens status" })

      -- LSP Lines commands
      vim.api.nvim_create_user_command("LspLinesToggle", toggle_lsp_lines, { desc = "Toggle LSP Lines" })
      vim.api.nvim_create_user_command("LspLinesEnable", enable_lsp_lines, { desc = "Enable LSP Lines" })
      vim.api.nvim_create_user_command("LspLinesDisable", disable_lsp_lines, { desc = "Disable LSP Lines" })
      vim.api.nvim_create_user_command("DiagnosticsToggleAll", toggle_all_diagnostics, { desc = "Toggle All Diagnostics" })

      -- Key mappings - ThePrimeagen style
      vim.keymap.set("n", "<leader>el", M.toggle, { desc = "Toggle Error Lens", silent = true })
      vim.keymap.set("n", "<leader>ee", M.enable, { desc = "Enable Error Lens", silent = true })
      vim.keymap.set("n", "<leader>ed", M.disable, { desc = "Disable Error Lens", silent = true })
      vim.keymap.set("n", "<leader>er", M.refresh_current_buffer, { desc = "Refresh Error Lens", silent = true })

      -- LSP Lines keybindings
      vim.keymap.set("n", "<leader>ell", toggle_lsp_lines, { desc = "Toggle LSP Lines", silent = true })
      vim.keymap.set("n", "<leader>ele", enable_lsp_lines, { desc = "Enable LSP Lines", silent = true })
      vim.keymap.set("n", "<leader>eld", disable_lsp_lines, { desc = "Disable LSP Lines", silent = true })

      -- Combined toggle for both systems
      vim.keymap.set("n", "<leader>ea", toggle_all_diagnostics, { desc = "Toggle All Diagnostics", silent = true })

      -- Initialize
      M.setup()

      -- Make globally available for debugging
      _G.ErrorLens = M
    end,
  },
}
