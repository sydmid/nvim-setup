-- Bookmarks plugin (like VS Code's bookmarks)
-- Store original require at the module level
local orig_require = require

return {
  "tomasky/bookmarks.nvim",
  lazy = false, -- Load immediately to ensure keybindings work
  priority = 100, -- High priority to load early
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required dependency
  },
  config = function()
    local bookmarks = require("bookmarks")

    -- Setup with proper configuration options
    bookmarks.setup({
      -- Save bookmarks to file on VimLeave
      save_file = vim.fn.expand("$HOME/.local/share/nvim/bookmarks"),
      -- Use the sign column
      sign_priority = 8,
      -- Keywords for annotations
      keywords = {
        ["@t"] = "☑️ ", -- Task
        ["@w"] = "⚠️ ", -- Warning
        ["@f"] = "⛏ ", -- Fix
        ["@n"] = " "    -- Note
      },
      -- Sign appearance
      signs = {
        add = { hl = "BookMarksAdd", text = "🔵", numhl = "BookMarksAddNr", linehl = "BookMarksAddLn" },
        ann = { hl = "BookMarksAnn", text = "🟢", numhl = "BookMarksAnnNr", linehl = "BookMarksAnnLn" },
      },
      -- Mappings
      on_attach = function()
        -- We'll set up mappings manually
      end
    })

    -- Set up custom colors for bookmark signs
    vim.api.nvim_set_hl(0, "BookMarksAdd", { fg = "#4A90E2" }) -- Blue circle for regular bookmarks
    vim.api.nvim_set_hl(0, "BookMarksAnn", { fg = "#50C878" }) -- Green circle for annotated bookmarks

    -- Set up mappings to match VSCode and register with which-key using v3 format
    local keymaps = {
      { "<leader>mm", function() require("bookmarks").bookmark_toggle() end, desc = "Toggle Bookmark" },
      { "<D-S-]>", function() require("bookmarks").bookmark_next() end, desc = "Next Bookmark" },
      { "<D-S-[>", function() require("bookmarks").bookmark_prev() end, desc = "Previous Bookmark" },
      { "<leader>ml", function() require("bookmarks").bookmark_list() end, desc = "List Bookmarks" },
      { "<leader>mc", function() require("bookmarks").bookmark_clean() end, desc = "Clear Bookmarks" },
      { "<leader>ma", function() require("bookmarks").bookmark_ann() end, desc = "Annotate Bookmark" },
    }

    -- Apply keymaps
    for _, keymap in ipairs(keymaps) do
      vim.keymap.set("n", keymap[1], keymap[2], { desc = keymap.desc, silent = true })
    end

    -- Register with which-key using v3 format
    local wk = require("which-key")
    wk.add({
      { '<leader>m', group = 'Bookmarks' },
      { '<leader>ml', desc = "List Bookmarks" },
      { '<leader>ma', desc = "Annotate Bookmark" },
      { '<leader>mc', desc = "Clear Bookmarks" },
    })
  end,
}
