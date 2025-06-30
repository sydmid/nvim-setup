-- Treesitter context - shows the current function/class/block context
-- Very useful for large files where you can't see the beginning of blocks
return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },    opts = {
      enable = true,
      max_lines = 0, -- 0 means no limit, dynamically resize based on content
      min_window_height = 0, -- Always show context (set to higher value like 10 to only show in larger windows)
      line_numbers = true,
      multiline_threshold = 1, -- Show context even for single-line functions
      trim_scope = 'outer', -- Which context lines to trim: 'outer' (default) or 'inner'
      mode = 'cursor', -- How to calculate context: 'cursor' (default), 'topline'
      separator = nil, -- Separator between context and content. Use '─' or '▁' or nil to disable
      zindex = 20, -- Z-index for the floating window
      on_attach = nil, -- Optional callback to run when attached

      -- Enhanced patterns for better context detection and reliability
      patterns = {
        -- Enhanced HTML patterns for Angular templates
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

      -- Force HTML context detection
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "html", "htmlangular", "vue", "svelte" },
        group = vim.api.nvim_create_augroup("TreesitterContextHTML", { clear = true }),
        callback = function()
          -- Ensure context is enabled for HTML files
          require("treesitter-context").enable()

          -- Force refresh context display
          vim.defer_fn(function()
            if vim.bo.filetype == "html" or vim.bo.filetype == "htmlangular" then
              -- Trigger a context refresh
              vim.cmd("doautocmd CursorMoved")
            end
          end, 100)
        end,
      })

      -- Set custom highlight groups to match your theme
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("TreesitterContextTheme", { clear = true }),
        callback = function()
          -- Context background - slightly darker than normal background
          vim.api.nvim_set_hl(0, "TreesitterContext", {
            bg = "#0A0A0A",
            fg = "#E1E1E1"
          })

          -- Context line numbers
          vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", {
            bg = "#0A0A0A",
            fg = "#727272"
          })

          -- Context separator (if enabled)
          vim.api.nvim_set_hl(0, "TreesitterContextSeparator", {
            fg = "#404040"
          })

          -- Context bottom border
          vim.api.nvim_set_hl(0, "TreesitterContextBottom", {
            bg = "#0A0A0A",
            underline = true,
            sp = "#404040"
          })
        end,
      })

      -- Apply highlights immediately
      vim.schedule(function()
        vim.cmd("doautocmd ColorScheme")
      end)

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
      })      -- Keymaps for context navigation (moved to <leader>h group)
      vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, {
        silent = true,
        desc = "Jump to context (breadcrumb)"
      })

      -- Context control keymaps in <leader>h group
      vim.keymap.set("n", "<leader>cj", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, {
        silent = true,
        desc = "Jump to context (breadcrumb)"
      })

      vim.keymap.set("n", "<leader>ch", function()
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
        desc = "Toggle treesitter context (robust)"
      })

      vim.keymap.set("n", "<leader>cd", function()
        local tsc = require("treesitter-context")
        local has_parser = pcall(vim.treesitter.get_parser)
        local ft = vim.bo.filetype

        vim.notify(string.format(
          "Context Debug:\n" ..
          "- Enabled: %s\n" ..
          "- Filetype: %s\n" ..
          "- Has parser: %s\n" ..
          "- Buffer lines: %d",
          tsc.enabled(),
          ft,
          has_parser,
          vim.api.nvim_buf_line_count(0)
        ), vim.log.levels.INFO)
      end, {
        desc = "Debug treesitter context"
      })

      -- Force enable context (for troubleshooting)
      vim.keymap.set("n", "<leader>ce", function()
        local tsc = require("treesitter-context")
        tsc.enable()
        vim.schedule(function()
          vim.cmd("doautocmd CursorMoved")
          vim.cmd("redraw!")
          vim.notify("Context force enabled", vim.log.levels.INFO)
        end)
      end, {
        desc = "Force enable treesitter context"
      })

      -- Force disable context (for troubleshooting)
      vim.keymap.set("n", "<leader>cx", function()
        local tsc = require("treesitter-context")
        tsc.disable()
        vim.schedule(function()
          vim.cmd("redraw!")
          vim.notify("Context force disabled", vim.log.levels.INFO)
        end)
      end, {
        desc = "Force disable treesitter context"
      })

      -- Context status and health check
      vim.keymap.set("n", "<leader>cs", function()
        local tsc = require("treesitter-context")
        local bufnr = vim.api.nvim_get_current_buf()
        local ft = vim.bo.filetype
        local has_parser = pcall(vim.treesitter.get_parser, bufnr, ft)
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

        local status_msg = string.format(
          "🔍 Context Status Report:\n\n" ..
          "📊 State: %s\n" ..
          "📄 Filetype: %s\n" ..
          "🌳 Treesitter parser: %s\n" ..
          "📏 Buffer lines: %d\n" ..
          "📍 Cursor line: %d\n" ..
          "🎯 Refresh counter: %s\n\n" ..
          "💡 If context isn't showing:\n" ..
          "   • Try <leader>ce to force enable\n" ..
          "   • Check if treesitter parser exists for filetype\n" ..
          "   • Make sure you're in a file with functions/classes",
          tsc.enabled() and "🟢 ENABLED" or "🔴 DISABLED",
          ft == "" and "none" or ft,
          has_parser and "✅ Available" or "❌ Missing",
          line_count,
          cursor_line,
          vim.g.context_refresh_counter or "0"
        )

        vim.notify(status_msg, vim.log.levels.INFO)
      end, {
        desc = "Context status and health check"
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
      attach_navic = false, -- We'll handle navic attachment ourselves
      create_autocmd = false, -- We'll create our own autocmd
      show_dirname = false, -- Don't show directory name to save space
      show_basename = true, -- Show file basename

      -- Theme configuration to match your no-clown-fiesta theme
      theme = {
        normal = { fg = "#E1E1E1", bg = "#121212" },
        ellipsis = { fg = "#727272" },
        separator = { fg = "#505050" },
        modifier = { fg = "#F4BF75", italic = true },
        dirname = { fg = "#AFAFAF" },
        basename = { fg = "#BAD7FF", bold = true },
        context = {},

        -- Context kinds styling
        context_file = { fg = "#E1E1E1" },
        context_module = { fg = "#88afa2" },
        context_namespace = { fg = "#88afa2" },
        context_package = { fg = "#88afa2" },
        context_class = { fg = "#BAD7FF", bold = true },
        context_method = { fg = "#F4BF75" },
        context_property = { fg = "#AA749F" },
        context_field = { fg = "#AA749F" },
        context_constructor = { fg = "#F4BF75", bold = true },
        context_enum = { fg = "#BAD7FF" },
        context_interface = { fg = "#BAD7FF" },
        context_function = { fg = "#F4BF75" },
        context_variable = { fg = "#E1E1E1" },
        context_constant = { fg = "#FFA557" },
        context_string = { fg = "#C0D684" },
        context_number = { fg = "#FFA557" },
        context_boolean = { fg = "#FFA557" },
        context_array = { fg = "#E1E1E1" },
        context_object = { fg = "#E1E1E1" },
        context_key = { fg = "#AA749F" },
        context_null = { fg = "#727272" },
        context_enum_member = { fg = "#FFA557" },
        context_struct = { fg = "#BAD7FF" },
        context_event = { fg = "#F4BF75" },
        context_operator = { fg = "#E1E1E1" },
        context_type_parameter = { fg = "#88afa2" },
      },

      -- Only show breadcrumbs for certain filetypes
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

      -- Symbols and separators
      symbols = {
        modified = "●",
        ellipsis = "…",
        separator = "",
      },

      -- Show context in a more compact format
      kinds = {
        File = "",
        Module = "",
        Namespace = "",
        Package = "",
        Class = "",
        Method = "",
        Property = "",
        Field = "",
        Constructor = "",
        Enum = "",
        Interface = "",
        Function = "",
        Variable = "",
        Constant = "",
        String = "",
        Number = "",
        Boolean = "",
        Array = "",
        Object = "",
        Key = "",
        Null = "",
        EnumMember = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = "",
      },
    },
    config = function(_, opts)
      require("barbecue").setup(opts)

      -- Set up navic for LSP integration
      local navic = require("nvim-navic")

      -- Attach navic to LSP when available
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("BarbecueNavic", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider then
            navic.attach(client, args.buf)
          end
        end,
      })

      -- Toggle breadcrumbs (moved to <leader>h group)
    --   vim.keymap.set("n", "<leader>hb", function()
    --     local config = require("barbecue.config")
    --     require("barbecue.ui").toggle()
    --     vim.notify(
    --       config.user.show and "Breadcrumbs enabled" or "Breadcrumbs disabled",
    --       vim.log.levels.INFO
    --     )
    --   end, {
    --     desc = "Toggle breadcrumbs bar"
    --   })

    end,
  },
}
