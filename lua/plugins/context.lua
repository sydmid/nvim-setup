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

      -- Patterns for different filetypes to improve context detection
      patterns = {
        -- Enhanced HTML patterns for Angular templates
        html = {
          'element',
          'start_tag',
          'self_closing_tag',
          'script_element',
          'style_element',
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
      end)      -- Keymaps for context navigation (moved to <leader>h group)
      vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, {
        silent = true,
        desc = "Jump to context (breadcrumb)"
      })

      -- Context control keymaps in <leader>h group
      vim.keymap.set("n", "<leader>hc", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, {
        silent = true,
        desc = "Jump to context (breadcrumb)"
      })

      vim.keymap.set("n", "<leader>ht", function()
        local tsc = require("treesitter-context")
        tsc.toggle()
        vim.notify(
          tsc.enabled() and "Context enabled" or "Context disabled",
          vim.log.levels.INFO
        )
      end, {
        desc = "Toggle treesitter context"
      })

      vim.keymap.set("n", "<leader>hd", function()
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

      -- Register with which-key
      vim.defer_fn(function()
        local wk_ok, wk = pcall(require, "which-key")
        if wk_ok then
          wk.add({
            { "<leader>h", group = "Headers/Hunks/Help" },
            { "<leader>hc", desc = "Jump to context" },
            { "<leader>ht", desc = "Toggle context headers" },
            { "<leader>hd", desc = "Debug context" },
          })
        end
      end, 100)
    end,
  },
}
