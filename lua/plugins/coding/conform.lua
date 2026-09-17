return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        -- Add debugging and notifications
        log_level = vim.log.levels.WARN,
        notify_on_error = true,
        notify_no_formatters = false,
        async = true,

        -- Explicitly disable default format on save
        default_format_opts = {
          lsp_format = "never",
        },

        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          svelte = { "prettier" },
          css = { "prettier" },
          html = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          graphql = { "prettier" },
          liquid = { "prettier" },
          lua = { "stylua" },
          python = { "ruff_format", "ruff_organize_imports" },
          sh = { "shfmt" },
          bash = { "shfmt" },
          zsh = { "shfmt_zsh", "zsh_indent" }, -- Try shfmt_zsh first, fallback to custom indenter
          cs = { "my_csharpier" }, -- C# formatting
          csproj = { "my_csharpier" }, -- C# formatting
        },
        formatters = {
          -- Modern Python formatting with Ruff
          ruff_format = {
            command = "ruff",
            args = {
              "format",
              "--stdin-filename",
              "$FILENAME",
              "-",
            },
            stdin = true,
          },
          ruff_organize_imports = {
            command = "ruff",
            args = {
              "--select",
              "I",
              "--fix",
              "--stdin-filename",
              "$FILENAME",
              "-",
            },
            stdin = true,
          },
          my_csharpier = {
            command = "csharpier",
            args = {
              "format",
              "--write-stdout",
            },
            to_stdin = true,
          },
          shfmt = {
            prepend_args = { "-i", "2", "-ci" }, -- 2-space indentation and indent switch cases
          },
          shfmt_zsh = {
            command = "shfmt",
            args = { "-i", "2", "-ci", "--language-dialect", "bash" }, -- Use bash dialect for zsh files
            stdin = true,
          },
          zsh_indent = {
            -- Custom formatter for zsh files that have complex parameter expansions
            format = require("core.utils.zsh_indent").format,
          },
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>mp", function()
        conform.format({
          lsp_format = "fallback",
          timeout_ms = 1000,
        })
      end, { desc = "Format file or range (in visual mode)" })

      -- Add conform info command for debugging
      vim.keymap.set("n", "<leader>ci", "<cmd>ConformInfo<cr>", { desc = "Show Conform info" })
    end,
  },
}
