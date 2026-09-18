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

  -- Toggle focus between editor and NvimTree with Tab
  map("n", "<Tab>", function()
    local buftype = vim.bo.buftype
    local filetype = vim.bo.filetype

    -- Exclude terminals (e.g. standard terminal, snacks_terminal)
    if buftype == "terminal" or filetype == "snacks_terminal" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-i>", true, false, true), "n", true)
      return
    end

    if filetype == "NvimTree" then
      -- If inside NvimTree, go to previous window
      vim.cmd("wincmd p")
    else
      -- Check if NvimTree is open in the current tab
      local is_nvimtree_open = false
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "NvimTree" then
          is_nvimtree_open = true
          break
        end
      end

      if is_nvimtree_open then
        -- If in normal editor and NvimTree is open, focus NvimTree
        vim.cmd("NvimTreeFocus")
      else
        -- If NvimTree is not open, fallback to default normal mode Tab (<C-i> jump forward)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-i>", true, false, true), "n", true)
      end
    end
  end, { desc = "Toggle focus between editor and NvimTree", silent = true })
end

return M
