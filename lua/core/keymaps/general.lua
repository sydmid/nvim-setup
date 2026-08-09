local M = {}

function M.setup()
  local map = vim.keymap.set

  map({ "n", "v" }, "<D-c>", '"+y', { desc = "Copy to system clipboard", silent = true })
  map({ "n", "v" }, "<D-x>", '"+x', { desc = "Cut to system clipboard", silent = true })
  map({ "n", "v", "i" }, "<D-v>", function()
    if vim.fn.mode() == "i" then
      return "<C-r>+"
    end
    return '"+p'
  end, { desc = "Paste from system clipboard", expr = true, silent = true })

  map({ "n", "v" }, "H", "b", { desc = "Previous word", silent = true })
  map({ "n", "v" }, "L", "e", { desc = "Next word", silent = true })
  map({ "n", "v" }, "<D-h>", "_", { desc = "Start of line", silent = true })
  map({ "n", "v" }, "<D-l>", "$", { desc = "End of line", silent = true })
  map("i", "<D-h>", "<C-o>_", { desc = "Start of line", silent = true })
  map("i", "<D-l>", "<C-o>$", { desc = "End of line", silent = true })

  map({ "n", "v" }, "c", '"_c', { desc = "c: Change without yanking" })
  map("n", "x", '"_x', { desc = "x: Delete char without yanking" })
  map({ "n", "v" }, "d", '"_d', { desc = "d: Delete without yanking" })
  map("n", "D", '"_D', { desc = "D: Delete to EOL without yanking" })
  map("n", "Y", "y$", { desc = "Y: Yank to EOL" })

  map({ "n", "v" }, "U", "<C-r>", { desc = "Redo", silent = true })
  map("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename symbol" })

  local function goto_next_member()
    local ok, move_module = pcall(require, "nvim-treesitter.textobjects.move")
    if not ok then
      return
    end

    local success = pcall(function()
      move_module.goto_next_start("@function.outer")
    end)

    if not success then
      pcall(function()
        move_module.goto_next_start("@class.outer")
      end)
    end
  end

  local function goto_prev_member()
    local ok, move_module = pcall(require, "nvim-treesitter.textobjects.move")
    if not ok then
      return
    end

    local success = pcall(function()
      move_module.goto_previous_start("@function.outer")
    end)

    if not success then
      pcall(function()
        move_module.goto_previous_start("@class.outer")
      end)
    end
  end

  map({ "n", "v" }, "g]", goto_next_member, { desc = "Next code block", silent = true, noremap = true })
  map({ "n", "v" }, "g[", goto_prev_member, { desc = "Previous code block", silent = true, noremap = true })

  map("i", ";;", "<ESC>A;<ESC>", { desc = "Add semicolon at end", silent = true })
  map("i", ",,", "<ESC>A,<ESC>", { desc = "Add comma at the end", silent = true })
  map("i", ">>", "<ESC>la => <ESC>i", { desc = "Add arrow function", silent = true })
  map("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
  map("i", "kj", "<ESC>", { desc = "Exit insert mode with kj" })

  map("v", "<", "<gv", { desc = "Indent left and keep selection", silent = true })
  map("v", ">", ">gv", { desc = "Indent right and keep selection", silent = true })
  map("v", "p", '"_dP', { noremap = true })

  map({ "n", "v" }, "<S-j>", "5gj", { desc = "Move down 5 display lines", noremap = true, silent = true })
  map({ "n", "v" }, "<S-k>", "5gk", { desc = "Move up 5 display lines", noremap = true, silent = true })

  map("n", "<esc>", ":noh<return><esc>", { desc = "Clear search highlight" })
  map({ "n", "x" }, "<leader>fd", function()
    require("conform").format({ lsp_fallback = true })
  end, { desc = "general format file" })
end

return M
