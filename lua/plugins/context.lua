-- Treesitter context - shows the current function/class/block context
-- Very useful for large files where you can't see the beginning of blocks
return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      enable = true,
      max_lines = 0,           -- 0 means no limit, dynamically resize based on content
      min_window_height = 0,   -- Always show context (set to higher value like 10 to only show in larger windows)
      line_numbers = true,
      multiline_threshold = 1, -- Show context even for single-line functions
      trim_scope = 'outer',    -- Which context lines to trim: 'outer' (default) or 'inner'
      mode = 'cursor',         -- How to calculate context: 'cursor' (default), 'topline'
      separator = nil,         -- Separator between context and content. Use '─' or '▁' or nil to disable
      zindex = 20,             -- Z-index for the floating window
      on_attach = nil,         -- Optional callback to run when attached

      patterns = {
        html = {
          'element',
          'start_tag',
          'self_closing_tag',
          'script_element',
          'style_element',
          'attribute',
        },
        -- Angular TypeScript files
        typescript = {
          'class_declaration',
          'method_definition',
          'function_declaration',
          'arrow_function',
          'if_statement',
          'for_statement',
          'while_statement',
          'try_statement',
          'object_pattern',
        },
        -- JavaScript files
        javascript = {
          'function_declaration',
          'arrow_function',
          'method_definition',
          'if_statement',
          'for_statement',
          'while_statement',
          'try_statement',
          'object_pattern',
        },
        -- Lua files (for nvim config)
        lua = {
          'function_declaration',
          'local_function',
          'method_index',
          'if_statement',
          'for_statement',
          'while_statement',
          'repeat_statement',
        },
        -- Make sure other languages work well too
        default = {
          'class',
          'function',
          'method',
          'for',
          'while',
          'if',
          'switch',
          'case',
          'try',
        },
      },
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)

      -- Enhanced context refresh mechanism for better reliability
      local refresh_timer = nil
      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        group = vim.api.nvim_create_augroup("TreesitterContextRefresh", { clear = true }),
        callback = function()
          local tsc = require("treesitter-context")
          if tsc.enabled() then
            -- Cancel any pending refresh
            if refresh_timer then
              vim.fn.timer_stop(refresh_timer)
            end

            -- Schedule a refresh with debouncing
            refresh_timer = vim.fn.timer_start(50, function()
              if tsc.enabled() then
                vim.schedule(function()
                  vim.cmd("doautocmd CursorMoved")
                  vim.cmd("redraw!")
                end)
              end
              refresh_timer = nil
            end)
          end
        end,
      })

      -- Separate autocmd for cursor movement with less aggressive refresh
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = vim.api.nvim_create_augroup("TreesitterContextCursor", { clear = true }),
        callback = function()
          local tsc = require("treesitter-context")
          if tsc.enabled() then
            -- Only refresh on significant cursor movement (every 5th movement)
            local context_refresh_counter = vim.g.context_refresh_counter or 0
            context_refresh_counter = context_refresh_counter + 1
            vim.g.context_refresh_counter = context_refresh_counter

            if context_refresh_counter % 5 == 0 then
              vim.schedule(function()
                if tsc.enabled() then
                  vim.cmd("redraw!")
                end
              end)
            end
          end
        end,
      })

      -- Ensure context is properly displayed after buffer changes
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWinEnter" }, {
        group = vim.api.nvim_create_augroup("TreesitterContextBufferSetup", { clear = true }),
        callback = function()
          local tsc = require("treesitter-context")
          if tsc.enabled() then
            vim.schedule(function()
              -- Force context refresh for new buffers
              vim.cmd("doautocmd CursorMoved")
              vim.defer_fn(function()
                vim.cmd("redraw!")
              end, 100)
            end)
          end
        end,
      })

      -- Context control keymaps in <leader>h group
      vim.keymap.set("n", "<leader>ck", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, {
        silent = true,
        desc = "Jump to context (breadcrumb)"
      })

      vim.keymap.set("n", "<leader>th", function()
        local tsc = require("treesitter-context")

        -- Store current state before toggling
        local was_enabled = tsc.enabled()

        -- Perform the toggle
        tsc.toggle()

        -- Force a refresh after a short delay to ensure state consistency
        vim.defer_fn(function()
          local current_state = tsc.enabled()

          -- If the state didn't change as expected, force the toggle again
          if current_state == was_enabled then
            tsc.toggle()
            current_state = tsc.enabled()
          end

          -- Force a complete refresh of the context display
          if current_state then
            -- When enabling, force multiple refresh attempts
            tsc.enable() -- Ensure it's really enabled
            vim.cmd("doautocmd CursorMoved")

            vim.schedule(function()
              -- Additional refresh attempts
              vim.cmd("doautocmd CursorMoved")
              vim.cmd("redraw!")

              -- Final validation and force enable if needed
              vim.defer_fn(function()
                if not tsc.enabled() then
                  tsc.enable()
                  vim.cmd("doautocmd CursorMoved")
                  vim.cmd("redraw!")
                end
              end, 100)
            end)
          else
            -- When disabling, ensure it's completely hidden
            tsc.disable() -- Ensure it's really disabled
            vim.schedule(function()
              vim.cmd("redraw!")
            end)
          end

          -- Notify the final state
          vim.notify(
            current_state and "Context enabled" or "Context disabled",
            vim.log.levels.INFO
          )
        end, 50) -- Small delay to allow the toggle to complete
      end, {
        desc = "[t]oggle treesitter context [h]eader"
      })
    end,
  },

  -- Enhanced breadcrumbs bar (VS Code style)
  -- Shows the full context path in the winbar
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- Show breadcrumbs in the winbar (top of each window)
      attach_navic = false,  -- We'll handle navic attachment ourselves
      create_autocmd = true, -- We'll create our own autocmd
      show_dirname = true,
      show_basename = true, -- Show file basename

      exclude_filetypes = {
        "help",
        "startify",
        "dashboard",
        "packer",
        "neogitstatus",
        "NvimTree",
        "Trouble",
        "alpha",
        "lir",
        "Outline",
        "spectre_panel",
        "toggleterm",
        "TelescopePrompt",
        "TelescopeResults",
        "lazy",
        "oil",
      },
    },
  },
}