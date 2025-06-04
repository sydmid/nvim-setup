local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Remove whitespace on save
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  command = ":%s/\\s\\+$//e",
})

-- Set up terminal mode mappings for window navigation
autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', '[[<Cmd>wincmd h<CR>]]', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', '[[<Cmd>wincmd j<CR>]]', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', '[[<Cmd>wincmd k<CR>]]', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', '[[<Cmd>wincmd l<CR>]]', { noremap = true, silent = true })
  end,
})

-- Set indentation for specific file types
autocmd("FileType", {
  pattern = { "lua", "javascript", "typescript", "json", "html", "css" },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.shiftwidth = 2
  end,
})

-- Auto-reload files when changed on disk
autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})

-- Save and restore folds
local fold_group = vim.api.nvim_create_augroup("RememberFolds", { clear = true })

-- Save folds when leaving a buffer
autocmd("BufWinLeave", {
  group = fold_group,
  pattern = "*.*",
  command = "mkview",
})

-- Restore folds when entering a buffer
autocmd("BufWinEnter", {
  group = fold_group,
  pattern = "*.*",
  command = "silent! loadview",
})

-- -- Arabic language support - auto-detect Arabic files
-- local arabic_group = vim.api.nvim_create_augroup("ArabicDetection", { clear = true })
-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   group = arabic_group,
--   pattern = { "*.ar", "*.arabic" },
--   callback = function()
--     vim.cmd("Arabic")
--     vim.notify("Arabic mode enabled automatically for Arabic file", vim.log.levels.INFO)
--   end,
--   desc = "Auto-enable Arabic mode for Arabic files",
-- })

-- -- Also try to detect files with high percentage of Arabic content
-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   group = arabic_group,
--   callback = function()
--     local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
--     local arabic_chars = 0
--     local total_chars = 0

--     for _, line in ipairs(lines) do
--       for _, c in utf8.codes(line) do
--         total_chars = total_chars + 1
--         -- Check if character is in Arabic Unicode range (0x0600-0x06FF)
--         if c >= 0x0600 and c <= 0x06FF then
--           arabic_chars = arabic_chars + 1
--         end
--       end
--     end

--     -- If more than 30% of characters are Arabic, enable Arabic mode
--     if total_chars > 0 and (arabic_chars / total_chars) > 0.3 then
--       vim.cmd("Arabic")
--       vim.notify("Arabic mode enabled automatically (detected Arabic content)", vim.log.levels.INFO)
--     end
--   end,
--   desc = "Auto-detect files with Arabic content",
-- })