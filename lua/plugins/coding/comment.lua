return {
  -- Commenting
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      -- import comment plugin safely
      local comment = require("Comment")

      local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

      -- enable comment
      comment.setup({
        padding = true,
        sticky = true,
        ignore = "^$", -- ignore empty lines
        mappings = {
          basic = true,
          extra = true,
        },
        toggler = {
          line = "gcc",
          block = "gbc",
        },
        opleader = {
          line = "gc",
          block = "gb",
        },
        extra = {
          above = "gcO",
          below = "gco",
          eol = "gcA",
        },
        -- for commenting tsx, jsx, svelte, html files
        pre_hook = ts_context_commentstring.create_pre_hook(),
        post_hook = function() end, -- empty function instead of nil
      })

      vim.keymap.set("n", "<D-/>", function()
        require("Comment.api").toggle.linewise.current()
        vim.cmd("normal! j")
      end, { silent = true, desc = "Toggle comment line and move down" })

      vim.keymap.set(
        "v",
        "<D-/>",
        "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
        { silent = true, desc = "Toggle comment (visual)" }
      )
    end,
  },
}
