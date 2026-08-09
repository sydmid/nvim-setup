local M = {}

function M.setup()
  local augroup = vim.api.nvim_create_augroup
  local autocmd = vim.api.nvim_create_autocmd

  local terminal_group = augroup("TerminalMappings", { clear = true })
  autocmd("TermOpen", {
    group = terminal_group,
    pattern = "*",
    callback = function(args)
      local opts = { buffer = args.buf, noremap = true, silent = true }
      vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
      vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
      vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
      vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
    end,
  })

  local indent_group = augroup("FileTypeIndent", { clear = true })
  autocmd("FileType", {
    group = indent_group,
    pattern = { "lua", "javascript", "typescript", "json", "html", "css" },
    callback = function()
      vim.bo.tabstop = 2
      vim.bo.softtabstop = 2
      vim.bo.shiftwidth = 2
    end,
  })

  autocmd({ "FocusGained", "BufEnter" }, {
    pattern = "*",
    command = "checktime",
  })

  local folds_group = augroup("TreesitterFoldFix", { clear = true })
  autocmd("BufWinEnter", {
    group = folds_group,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      if vim.bo[buf].buftype ~= "" then
        return
      end

      local win = vim.api.nvim_get_current_win()
      local function reset_folds()
        if not vim.api.nvim_win_is_valid(win) then
          return
        end
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        if vim.api.nvim_win_get_buf(win) ~= buf then
          return
        end

        vim.api.nvim_win_call(win, function()
          vim.wo.foldlevel = 99
          pcall(vim.cmd, "silent! normal! zx")
        end)
      end

      reset_folds()
      vim.defer_fn(reset_folds, 100)
      vim.defer_fn(reset_folds, 400)
    end,
  })
end

return M
