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

-- DISABLED: Remove whitespace on save
-- augroup("TrimWhitespace", { clear = true })
-- autocmd("BufWritePre", {
--   group = "TrimWhitespace",
--   pattern = "*",
--   command = ":%s/\\s\\+$//e",
-- })

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

-- HTML-specific folding configuration
-- Fix for HTML folding not working with treesitter
autocmd("FileType", {
  pattern = "html",
  callback = function()
    -- Ensure folding is enabled
    vim.wo.foldenable = true

    -- Enhanced HTML folding using treesitter with fallback
    vim.defer_fn(function()
      -- Check if treesitter parser is available and working
      local has_parser = pcall(vim.treesitter.get_parser, 0, "html")
      local has_queries = pcall(vim.treesitter.query.get, "html", "folds")

      if has_parser and has_queries then
        -- Use treesitter folding
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.enhanced_html_foldexpr()"
        vim.notify("HTML: Using enhanced treesitter folding", vim.log.levels.DEBUG)
      else
        -- Fallback to indent-based folding
        vim.wo.foldmethod = "indent"
        vim.wo.foldlevel = 99  -- Start with all folds open
        vim.notify("HTML: Using indent-based folding (treesitter unavailable)", vim.log.levels.DEBUG)
      end

      -- Set appropriate fold levels for HTML (start with all folds open)
      vim.wo.foldlevel = 99
      vim.opt.foldlevelstart = 99  -- Use vim.opt for global options

      -- Enhanced fold text for HTML
      vim.wo.foldtext = "v:lua.html_fold_text()"
    end, 50)
  end,
})

-- Custom fold text function for HTML
function _G.html_fold_text()
  local line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart + 1

  -- Clean up the line (remove extra spaces)
  line = line:gsub("^%s*", ""):gsub("%s*$", "")

  -- Extract tag name for better display
  local tag = line:match("<(%w+)")
  if tag then
    return string.format("󰗀 <%s...> (%d lines)", tag, line_count)
  else
    return string.format("󰘍 %s... (%d lines)", line:sub(1, 50), line_count)
  end
end

-- Enhanced fold expression for HTML that combines treesitter with manual fixes
function _G.enhanced_html_foldexpr()
  local line = vim.v.lnum

  -- Try treesitter first
  local ts_status, ts_fold = pcall(function()
    return vim.treesitter.foldexpr(line)
  end)

  if ts_status and ts_fold and ts_fold ~= "0" then
    return ts_fold
  end

  -- Manual folding logic for HTML when treesitter fails
  local line_content = vim.fn.getline(line)
  local prev_line = line > 1 and vim.fn.getline(line - 1) or ""
  local next_line = vim.fn.getline(line + 1) or ""

  -- Increase fold level for opening tags
  if line_content:match("<%s*[^/][^>]*>%s*$") and not line_content:match("<%s*[^/][^>]*/>") then
    -- Self-closing tags don't increase fold level
    if not line_content:match("<%s*[^>]*/%s*>") then
      return "a1"
    end
  end

  -- Decrease fold level for closing tags
  if line_content:match("<%s*/%s*[^>]*>") then
    return "s1"
  end

  -- HTML doctype and html tag handling
  if line_content:match("<!DOCTYPE") then
    return "0"
  end

  -- Default fold level
  return "="
end

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