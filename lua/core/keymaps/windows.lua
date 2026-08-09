local M = {}

local function move_line_down()
  if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
    local end_line = vim.fn.line("'>")
    if end_line >= vim.fn.line("$") then
      return "<Esc>gv"
    end
    return ":'<,'>m '>+1<CR>gv=gv"
  end

  if vim.fn.line(".") == vim.fn.line("$") then
    return ""
  end
  return ":m .+1<CR>=="
end

local function move_line_up()
  if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
    local start_line = vim.fn.line("'<")
    if start_line <= 1 then
      return "<Esc>gv"
    end
    return ":'<,'>m '<-2<CR>gv=gv"
  end

  if vim.fn.line(".") == 1 then
    return ""
  end
  return ":m .-2<CR>=="
end

function M.setup()
  local map = vim.keymap.set

  map({ "n", "v" }, "<D-S-j>", move_line_down, { desc = "Move line/block down", expr = true, silent = true })
  map({ "n", "v" }, "<D-S-k>", move_line_up, { desc = "Move line/block up", expr = true, silent = true })
  map("i", "<D-S-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down", silent = true })
  map("i", "<D-S-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up", silent = true })

  map("n", "|", "<C-w>v", { desc = "Split window vertically" })
  map("n", "_", "<C-w>s", { desc = "Split window horizontally" })
  map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
  map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
  map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
  map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
  map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

  map("n", "<leader>k", ":lua require('flash').jump()<CR>", { desc = "Flash jump", silent = true })
  map(
    "n",
    "<leader>j",
    ":lua require('flash').jump({search = {forward = true, wrap = false, multi_window = false}})<CR>",
    { desc = "Flash forward" }
  )
end

return M
