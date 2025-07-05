-- AutoSession - Automatic session management for Neovim
-- Provides seamless automatic session save/restore with intelligent directory handling
return {
  {
    "rmagatti/auto-session",
    lazy = false, -- Load immediately to ensure session management works on startup
    priority = 50, -- High priority but after core plugins

    init = function()
      -- Set recommended sessionoptions early to avoid warnings
      vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    end,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      -- Core session management with optimized auto-save settings
      enabled = true,
      root_dir = vim.fn.stdpath("data") .. "/sessions/",
      auto_save = true, -- Enable automatic saving for seamless workflow
      auto_restore = true, -- Auto-restore last session for better user experience
      auto_create = true, -- Automatically create sessions

      -- Optimized auto-save behavior for best practices
      auto_save_on_exit = true, -- Save session when exiting Neovim
      auto_save_enabled = true, -- Global auto-save toggle
      save_extra_cmds = {
        "tabdo windo w", -- Save all files before session save
      },

      -- Directory filtering for better workflow
      suppressed_dirs = {
        "~/",
        "~/Projects",
        "~/Downloads",
        "~/Desktop",
        "~/Documents",
        "/tmp",
        "/",
        "/Users",
        "/usr",
        "/opt",
        "/System",
      },

      -- Session behavior configuration optimized for automatic saving
      auto_restore_last_session = false, -- Don't auto-restore to avoid confusion
      git_use_branch_name = true, -- Include git branch in session name for better organization
      git_auto_restore_on_branch_change = false, -- Don't auto-restore on branch change (can be disruptive)
      lazy_support = true, -- Wait for Lazy.nvim to finish loading

      -- Auto-save timing and conditions
      auto_save_on_bufenter = false, -- Don't save on every buffer enter (too aggressive)
      auto_save_on_bufleave = false, -- Don't save on buffer leave (too frequent)
      auto_save_on_vimleave = true, -- Save when leaving Vim (essential)
      auto_save_on_focuslost = true, -- Save when Neovim loses focus (good practice)

      -- Window and buffer handling
      close_unsupported_windows = true, -- Clean up non-file windows before saving
      bypass_save_filetypes = {
        "alpha",
        "dashboard",
        "gitcommit",
        "gitrebase",
        "help",
        "lazy",
        "mason",
        "notify",
        "oil",
        "TelescopePrompt",
        "trouble",
        "NvimTree",
        "neo-tree",
        "terminal",
        "toggleterm",
        "qf",
        "quickfix",
        "netrw",
        "diff",
      },

      -- Smart argument handling for automatic session saving
      args_allow_single_directory = true, -- Allow session management when opening a directory
      args_allow_files_auto_save = function()
        -- Smart auto-save logic when launched with file arguments
        local supported_buffers = 0
        local buffers = vim.api.nvim_list_bufs()

        for _, buf in ipairs(buffers) do
          if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
            local path = vim.api.nvim_buf_get_name(buf)
            if vim.fn.filereadable(path) ~= 0 then
              supported_buffers = supported_buffers + 1
            end
          end
        end

        -- Save session if we have 2 or more supported buffers (indicates a working session)
        return supported_buffers >= 2
      end,

      -- Error handling and recovery
      continue_restore_on_error = true,
      show_auto_restore_notif = true, -- Show notifications for better awareness

      -- Session cleanup (14 days retention)
      purge_orphaned_sessions = true,
      auto_purge_on_load = true, -- Automatically clean up old sessions
      purge_orphaned_sessions_on_start = false, -- Don't purge on startup (can be slow)

      -- Logging
      log_level = "warn", -- Reduce noise while still catching issues

      -- Session lens (Telescope integration)
      session_lens = {
        load_on_setup = true, -- Initialize Telescope integration
        picker_opts = {
          -- Telescope theme configuration
          theme = "dropdown",
          layout_config = {
            width = 0.8,
            height = 0.6,
          },
          -- Enhanced preview and selection
          previewer = false, -- Sessions don't need preview
          initial_mode = "normal", -- Start in normal mode for easier navigation
        },
        mappings = {
          delete_session = { "i", "<C-D>" },
          alternate_session = { "i", "<C-S>" },
          copy_session = { "i", "<C-Y>" },
        },
        session_control = {
          control_dir = vim.fn.stdpath("data") .. "/auto_session/",
          control_filename = "session_control.json",
        },
      },

      -- Command hooks for integration with other plugins
      pre_save_cmds = {
        -- Close oil.nvim before saving (prevents session corruption)
        function()
          local oil_ok, oil = pcall(require, "oil")
          if oil_ok then
            oil.close()
          end
        end,
        -- Close any floating windows that might interfere
        "lua for _, win in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_win_get_config(win).relative ~= '' then vim.api.nvim_win_close(win, false) end end",
      },

      post_restore_cmds = {
        -- Refresh oil if it was open
        function()
          -- Re-detect file types after session restore
          vim.cmd("filetype detect")
        end,
      },

      -- Handle cwd changes intelligently
      cwd_change_handling = false, -- Disable automatic cwd change handling (can be confusing)

      -- Optional: If you want to enable cwd change handling, use this instead:
      -- cwd_change_handling = {
      --   restore_upcoming_session = false, -- Don't auto-restore when changing directories
      --   pre_cwd_changed_hook = function()
      --     -- Optional: Close specific windows before directory change
      --   end,
      --   post_cwd_changed_hook = function()
      --     -- Optional: Refresh statusline or other components
      --     local lualine_ok, lualine = pcall(require, "lualine")
      --     if lualine_ok then
      --       lualine.refresh()
      --     end
      --   end,
      -- },
    },

    keys = {
      -- Minimal session management keybindings
      { "<leader>ss", "<cmd>SessionSave<cr>", desc = "Save session" },
      { "<leader>sr", "<cmd>SessionRestore<cr>", desc = "Restore session" },
    },

    config = function(_, opts)
      require("auto-session").setup(opts)

      -- Integration with your existing Which-Key groups
      local wk_ok, wk = pcall(require, "which-key")
      if wk_ok then
        wk.add({
          { "<leader>s", group = "󰅩 Session/Split", desc = "Session management and split commands" },
          { "<leader>w", group = "󰓩 Workspace/Tabs", desc = "Workspace and tab management" },
        })
      end

      -- Custom highlights for session lens if using your theme
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- Ensure session picker follows your theme
          vim.api.nvim_set_hl(0, "TelescopeSessionTitle", { link = "TelescopeTitle" })
          vim.api.nvim_set_hl(0, "TelescopeSessionNormal", { link = "TelescopeNormal" })
        end,
      })

      -- Enhanced notifications for session operations
      vim.api.nvim_create_autocmd("User", {
        pattern = "AutoSessionSavePost",
        callback = function(data)
          local session_name = data.data.session_name or "current session"
          vim.notify("💾 Session saved: " .. session_name, vim.log.levels.INFO)
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "AutoSessionRestorePost",
        callback = function(data)
          local session_name = data.data.session_name or "session"
          vim.notify("🔄 Session restored: " .. session_name, vim.log.levels.INFO)

          -- Optional: Refresh components after restore
          vim.schedule(function()
            vim.cmd("doautoall BufRead")
          end)
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "AutoSessionDeletePost",
        callback = function(data)
          local session_name = data.data.session_name or "session"
          vim.notify("🗑️ Session deleted: " .. session_name, vim.log.levels.WARN)
        end,
      })

      -- Additional automatic save triggers for best practices
      vim.api.nvim_create_autocmd("FocusLost", {
        group = vim.api.nvim_create_augroup("AutoSessionFocusSave", { clear = true }),
        callback = function()
          -- Only save if we're in a real project directory with meaningful content
          local cwd = vim.fn.getcwd()
          local suppressed = {
            vim.fn.expand("~"),
            vim.fn.expand("~/Projects"),
            vim.fn.expand("~/Downloads"),
            vim.fn.expand("~/Desktop"),
            vim.fn.expand("~/Documents"),
            "/tmp",
            "/",
            "/Users",
          }

          for _, dir in ipairs(suppressed) do
            if cwd == dir then
              return -- Skip saving in suppressed directories
            end
          end

          -- Check if we have meaningful buffers open
          local meaningful_buffers = 0
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
              local name = vim.api.nvim_buf_get_name(buf)
              if name ~= "" and vim.fn.filereadable(name) == 1 then
                meaningful_buffers = meaningful_buffers + 1
              end
            end
          end

          if meaningful_buffers >= 1 then
            -- Save all modified files first
            vim.cmd("silent! wall")
            -- Then save session
            vim.schedule(function()
              pcall(require("auto-session").save_session)
            end)
          end
        end,
      })

      -- Auto-save on timer (every 5 minutes when idle)
      local save_timer = vim.loop.new_timer()
      local function start_autosave_timer()
        if save_timer then
          save_timer:start(300000, 300000, vim.schedule_wrap(function() -- 5 minutes = 300000ms
            -- Only save if Neovim has been idle and we have meaningful content
            local cwd = vim.fn.getcwd()
            local suppressed = {
              vim.fn.expand("~"),
              vim.fn.expand("~/Projects"),
              vim.fn.expand("~/Downloads"),
              vim.fn.expand("~/Desktop"),
              vim.fn.expand("~/Documents"),
              "/tmp",
              "/",
              "/Users",
            }

            for _, dir in ipairs(suppressed) do
              if cwd == dir then
                return
              end
            end

            -- Check for meaningful buffers
            local meaningful_buffers = 0
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
                local name = vim.api.nvim_buf_get_name(buf)
                if name ~= "" and vim.fn.filereadable(name) == 1 then
                  meaningful_buffers = meaningful_buffers + 1
                end
              end
            end

            if meaningful_buffers >= 1 then
              pcall(require("auto-session").save_session)
            end
          end))
        end
      end

      -- Start the timer
      start_autosave_timer()

      -- Clean up timer on exit
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          if save_timer then
            save_timer:stop()
            save_timer:close()
          end
        end,
      })
    end,
  },
}
