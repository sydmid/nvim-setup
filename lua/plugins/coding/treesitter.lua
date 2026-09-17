return {
  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile", "BufReadPre" },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        lazy = false, -- Make sure this is loaded early
        priority = 100, -- High priority to ensure it's loaded before keymaps
      },
      "windwp/nvim-ts-autotag",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        modules = {},
        sync_install = false,
        ignore_install = {},
        auto_install = true,
        ensure_installed = {
          "c",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "javascript",
          "typescript",
          "python",
          "rust",
          "go",
          "bash",
          "json",
          "dockerfile",
          "gitignore",
          "html",
          "css",
          "markdown",
          "markdown_inline",
          "c_sharp", -- C# syntax highlighting
          "razor",
        },
        -- enable autotagging (w/ nvim-ts-autotag plugin)
        autotag = {
          enable = true,
        },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            -- scope_incremental = "<C-s>",
            node_decremental = "<C-backspace>",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = false, -- disable jump list population for increased speed
            goto_next_start = {},
            goto_next_end = {},
            goto_previous_start = {},
            goto_previous_end = {},
          },
        },
      })
    end,
  },
}
