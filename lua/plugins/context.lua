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

      -- Context control keymaps
      vim.keymap.set("n", "<leader>ck", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, {
        silent = true,
        desc = "Jump to context (breadcrumb)"
      })

      vim.keymap.set("n", "<leader>th", function()
        local tsc = require("treesitter-context")
        tsc.toggle()
        vim.notify(
          tsc.enabled() and "Context enabled" or "Context disabled",
          vim.log.levels.INFO
        )
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