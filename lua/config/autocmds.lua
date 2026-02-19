local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Yank highlighting handled by vim-highlightedyank plugin (ui.lua)

-- Set up terminal mode mappings for window navigation
augroup("TerminalMappings", { clear = true })
autocmd("TermOpen", {
  group = "TerminalMappings",
  pattern = "*",
  callback = function()
    vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', '[[<Cmd>wincmd h<CR>]]', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', '[[<Cmd>wincmd j<CR>]]', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', '[[<Cmd>wincmd k<CR>]]', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', '[[<Cmd>wincmd l<CR>]]', { noremap = true, silent = true })
  end,
})

-- Set indentation for specific file types
augroup("FileTypeIndent", { clear = true })
autocmd("FileType", {
  group = "FileTypeIndent",
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

-- Ensure cursor blinking persists across all events
-- augroup("CursorBlinking", { clear = true })
-- autocmd({ "VimEnter", "UIEnter", "BufEnter" }, {
--   group = "CursorBlinking",
--   callback = function()
--     vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250"
--   end,
--   desc = "Force cursor blinking configuration",
-- })

-- Fix: reset foldlevel on buffer display to prevent collapsed folds
-- (covers LSP navigation, session restore, file pickers, etc.)
-- Uses multiple deferred calls to beat async treesitter/LSP fold computation.
augroup("TreesitterFoldFix", { clear = true })
autocmd("BufWinEnter", {
  group = "TreesitterFoldFix",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].buftype ~= "" then return end

    local win = vim.api.nvim_get_current_win()

    -- Helper: reset folds on a specific window/buffer if still valid
    local function reset_folds()
      if not vim.api.nvim_win_is_valid(win) then return end
      if not vim.api.nvim_buf_is_valid(buf) then return end
      if vim.api.nvim_win_get_buf(win) ~= buf then return end
      vim.api.nvim_win_call(win, function()
        -- zx = reapply foldlevel (99 = all open) AND reset manual fold states
        -- This undoes any folds that plugins (like origami) may have closed.
        vim.wo.foldlevel = 99
        pcall(vim.cmd, "silent! normal! zx")
      end)
    end

    -- Immediate reset
    reset_folds()
    -- Deferred resets to catch async treesitter parse / LSP fold computation
    vim.defer_fn(reset_folds, 100)
    vim.defer_fn(reset_folds, 400)
  end,
})