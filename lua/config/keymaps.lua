local map = vim.keymap.set
-- System clipboard keymaps (macOS style)
map({ "n", "v" }, "<D-c>", '"+y', { desc = "Copy to system clipboard", silent = true })
map({ "n", "v" }, "<D-x>", '"+x', { desc = "Cut to system clipboard", silent = true })
map({ "n", "v", "i" }, "<D-v>", function()
  if vim.fn.mode() == "i" then
    return '<C-r>+'
  else
    return '"+p'
  end
end, { desc = "Paste from system clipboard", expr = true, silent = true })
--------------------------------------------- Handy Motions
map({ "n", "v" }, "H", "b", { desc = "Previous word", silent = true })
map({ "n", "v" }, "L", "e", { desc = "Next word", silent = true })
map({ "n", "v" }, "<D-h>", "_", { desc = "Start of line", silent = true })
map({ "n", "v" }, "<D-l>", "$", { desc = "End of line", silent = true })
map("i", "<D-h>", "<C-o>_", { desc = "Start of line", silent = true })
map("i", "<D-l>", "<C-o>$", { desc = "End of line", silent = true })

map("n", "c", '"_c', { desc = "c: Change without yanking" })
map("n", "x", '"_x', { desc = "x: Delete char without yanking" })
map({ "n", "v" }, "d", '"_d', { desc = "d: Delete without yanking" })
map("n", "D", '"_D', { desc = "D: Delete to EOL without yanking" })
map("n", "Y", "y$", { desc = "Y: Yank to EOL" })
--------------------------------------------- Comments Impls
map("n", "<D-/>", function()
  require("Comment.api").toggle.linewise.current()
  vim.cmd("normal! j") -- move down a line
end, { silent = true, desc = "Toggle comment line and move down" })

map("v", "<D-/>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
  { silent = true, desc = "Toggle comment (visual)" })

--------------------------------------------- Finding Impls
vim.keymap.set("x", "/", function()
  -- Yank the selected text
  vim.cmd("normal! y")
  -- Escape any special characters in the yanked text for the search
  local text = vim.fn.getreg('"')
  text = vim.fn.escape(text, [[\/]])
  -- Start search
  vim.fn.feedkeys("/" .. text .. "\n", "n")
end, { noremap = true, silent = true })

vim.keymap.set("x", "<D-f>", function()
  -- Yank the selected text
  vim.cmd("normal! y")
  -- Escape any special characters in the yanked text for the search
  local text = vim.fn.getreg('"')
  text = vim.fn.escape(text, [[\/]])
  -- Start search
  vim.fn.feedkeys("/" .. text .. "\n", "n")
end, { noremap = true, silent = true })


--------------------------------------------- Buffer management commands (which-key compatible)
map("n", "<leader>bD", "<cmd>%bd|e#|bd#<CR>", { desc = "Delete other buffers" })
-- Reset current buffer (reload from disk, discard changes)
map("n", "<leader>br", function()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    vim.notify("Cannot reset buffer: No file associated", vim.log.levels.WARN)
    return
  end

  local modified = vim.api.nvim_buf_get_option(0, 'modified')
  if modified then
    local choice = vim.fn.confirm(
      "Buffer has unsaved changes. Reset anyway?",
      "&Yes\n&No",
      2
    )
    if choice ~= 1 then
      return
    end
  end

  vim.cmd("edit!")
end, { desc = "Reset buffer (reload from disk)" })

map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete other buffers" })

-- Terminal Impls
map({ "n", "i", "v", "t" }, "<D-`>", function()
  require("snacks").terminal.toggle()
end, { desc = "Toggle terminal" })

-- Improved redo
map({ "n", "v" }, "U", "<C-r>", { desc = "Redo", silent = true })

vim.keymap.set('n', '<C-Tab>', ':bnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-S-Tab>', ':bprevious<CR>', { noremap = true, silent = true })

-- Code formatting
map({ "n", "x" }, "<leader>fd", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "general format file" })

map("n", "<leader>hh", ":lua require('harpoon.mark').add_file()<CR>", { desc = "Add to harpoon" })

map("n", "<leader>r", ":lua vim.lsp.buf.rename()<CR>", { desc = "Rename symbol" })

-- Implements VS Code's gotoNextPreviousMember.nextMember and previousMember functionality
local goto_next_member = function()
  -- Safely try to require the module
  local ok, move_module = pcall(require, "nvim-treesitter.textobjects.move")
  if not ok then
    -- Module not available yet, silently fail
    return
  end

  -- Now use the module safely
  local success = pcall(function()
    move_module.goto_next_start("@function.outer")
  end)

  -- Only try class if function fails
  if not success then
    pcall(function()
      move_module.goto_next_start("@class.outer")
    end)
  end
end

local goto_prev_member = function()
  -- Safely try to require the module
  local ok, move_module = pcall(require, "nvim-treesitter.textobjects.move")
  if not ok then
    -- Module not available yet, silently fail
    return
  end

  -- Now use the module safely
  local success = pcall(function()
    move_module.goto_previous_start("@function.outer")
  end)

  -- Only try class if function fails
  if not success then
    pcall(function()
      move_module.goto_previous_start("@class.outer")
    end)
  end
end

map({ "n", "v" }, "g]", goto_next_member, { desc = "Next code block", silent = true, noremap = true })
map({ "n", "v" }, "g[", goto_prev_member, { desc = "Previous code block", silent = true, noremap = true })

-- Insert mode mappings
map("i", ";;", "<ESC>A;<ESC>", { desc = "Add semicolon at end", silent = true })
map("i", ",,", "<ESC>A,<ESC>", { desc = "Add comma at the end", silent = true })
map("i", ">>", "<ESC>la => <ESC>i", { desc = "Add arrow function", silent = true })

-- Visual mode mappings
map("v", "<", "<gv", { desc = "Indent left and keep selection", silent = true })
map("v", ">", ">gv", { desc = "Indent right and keep selection", silent = true })

-- Prevent yanked text being overwritten when pasting
vim.keymap.set("v", "p", '"_dP', { noremap = true })

-- Examples of non-main filetypes
local ignored_filetypes = {
  "NvimTree",
  "TelescopePrompt",
  "TelescopeResults",
  "lazy",
  "packer",
  "qf", -- quickfix
  "netrw",
  "help",
  "oil",
  "alpha",
  "snacks_terminal", -- Snacks terminal
}
-- Buftypes to ignore
local ignored_buftypes = {
  "nofile",
  "prompt",
  "terminal",
  "help",
}
local function is_main_buffer(bufnr)
  -- Check if buffer is valid
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  -- Safely get buffer options with pcall
  local ft_ok, ft = pcall(function()
    return vim.bo[bufnr].filetype
  end)
  local bt_ok, bt = pcall(function()
    return vim.bo[bufnr].buftype
  end)

  -- If we can't get the buffer properties, it's not a main buffer
  if not ft_ok or not bt_ok then
    return false
  end

  -- Get buffer name safely
  local name_ok, name = pcall(vim.api.nvim_buf_get_name, bufnr)
  local buf_name = name_ok and name or ""

  return not vim.tbl_contains(ignored_filetypes, ft) and not vim.tbl_contains(ignored_buftypes, bt) and buf_name ~= ""
end

-- Helper function to check if a window is actually visible and accessible
local function is_window_visible(win)
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end

  -- Check if window is in current tabpage
  local current_tabpage = vim.api.nvim_get_current_tabpage()
  local win_tabpage = vim.api.nvim_win_get_tabpage(win)
  if current_tabpage ~= win_tabpage then
    return false
  end

  -- Check window configuration
  local config = vim.api.nvim_win_get_config(win)

  -- Skip floating windows that might be hidden or minimized
  if config.relative ~= "" then
    -- Check if floating window has reasonable dimensions
    if config.width and config.height and (config.width < 5 or config.height < 3) then
      return false
    end
  end

  -- Check if window is part of current layout (not minimized/hidden)
  local all_wins = vim.api.nvim_tabpage_list_wins(current_tabpage)
  return vim.tbl_contains(all_wins, win)
end

-- -- Tab key toggles between main buffer and auxiliary buffers (excluding terminal mode for autocomplete)
map("n", "<Tab>", function()
  local current = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()

  -- Track the last known main and auxiliary buffers/windows
  if not vim.g.last_main_win then
    vim.g.last_main_win = nil
    vim.g.last_aux_win = nil
  end

  -- If in a main buffer, focus on last auxiliary buffer if it's visible
  if is_main_buffer(current) then
    if vim.g.last_aux_win and is_window_visible(vim.g.last_aux_win) then
      local aux_buf = vim.api.nvim_win_get_buf(vim.g.last_aux_win)
      -- Double-check that the auxiliary window still contains a non-main buffer
      if not is_main_buffer(aux_buf) then
        vim.g.last_main_win = current_win
        vim.api.nvim_set_current_win(vim.g.last_aux_win)
        return
      end
    end

    -- Find any visible auxiliary buffer to focus
    local visible_aux_windows = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if is_window_visible(win) and win ~= current_win then
        local buf = vim.api.nvim_win_get_buf(win)
        if not is_main_buffer(buf) then
          table.insert(visible_aux_windows, win)
        end
      end
    end

    -- Focus on the first visible auxiliary window found
    if #visible_aux_windows > 0 then
      vim.g.last_main_win = current_win
      vim.g.last_aux_win = visible_aux_windows[1]
      vim.api.nvim_set_current_win(visible_aux_windows[1])
      return
    end
    -- No auxiliary windows visible, provide feedback
    vim.notify("No auxiliary windows open", vim.log.levels.INFO, { timeout = 1000 })
  else
    -- If in auxiliary buffer, go back to last main buffer if it's visible
    if vim.g.last_main_win and is_window_visible(vim.g.last_main_win) then
      local main_buf = vim.api.nvim_win_get_buf(vim.g.last_main_win)
      -- Double-check that the main window still contains a main buffer
      if is_main_buffer(main_buf) then
        vim.g.last_aux_win = current_win
        vim.api.nvim_set_current_win(vim.g.last_main_win)
        return
      end
    end

    -- Find any visible main buffer
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if is_window_visible(win) and win ~= current_win then
        local buf = vim.api.nvim_win_get_buf(win)
        if is_main_buffer(buf) then
          vim.g.last_aux_win = current_win
          vim.g.last_main_win = win
          vim.api.nvim_set_current_win(win)
          return
        end
      end
    end

    -- No main windows found, provide feedback
    vim.notify("No main windows available", vim.log.levels.INFO, { timeout = 1000 })
  end
end, { desc = "Toggle between main and auxiliary buffers", silent = true })

vim.keymap.set({ "n", "t" }, "<D-b>", function()
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current_win)

  -- First handle symbols-outline specially before other operations
  pcall(function()
    if package.loaded["symbols-outline"] then
      -- Try to properly close the outline
      require("symbols-outline").close_outline()

      -- Small delay to ensure symbols-outline is fully closed
      vim.defer_fn(function()
        -- Clean up any lingering symbols-outline windows
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.api.nvim_buf_is_valid(buf) then
            local name_ok, name = pcall(vim.api.nvim_buf_get_name, buf)
            if name_ok and name:match("symbols%-outline") then
              pcall(vim.api.nvim_win_close, win, true)
            end
          end
        end
      end, 10)
    end
  end)

  -- Create a list of buffers to close
  local buffers_to_close = {}

  -- First pass: identify buffers to close (avoiding symbols-outline and treesitter-context)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      -- Skip the current buffer if it's a main buffer
      if bufnr ~= current_buf or not is_main_buffer(current_buf) then
        if not is_main_buffer(bufnr) then
          local name_ok, buf_name = pcall(vim.api.nvim_buf_get_name, bufnr)

          -- Skip symbols-outline buffer which needs special handling
          -- Skip treesitter-context buffer (sticky header)
          local should_skip = false

          if name_ok and (buf_name:match("symbols%-outline") or buf_name:match("treesitter%-context")) then
            should_skip = true
          end

          -- Additional check for treesitter-context by buffer properties
          if not should_skip then
            local ft_ok, ft = pcall(function() return vim.bo[bufnr].filetype end)
            if ft_ok and ft == "treesitter-context" then
              should_skip = true
            end
          end

          -- Check if buffer is used by any floating windows (likely treesitter-context)
          if not should_skip then
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
                local win_config = vim.api.nvim_win_get_config(win)
                -- Skip buffers in floating windows with zindex (treesitter-context uses zindex)
                if win_config.relative ~= "" and win_config.zindex and win_config.zindex >= 20 then
                  should_skip = true
                  break
                end
              end
            end
          end

          if not should_skip then
            table.insert(buffers_to_close, bufnr)
          end
        end
      end
    end
  end

  -- Second pass: close the buffers
  for _, bufnr in ipairs(buffers_to_close) do
    -- Use pcall to handle any errors that might occur during closing
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  end

  -- If we were in a non-main buffer, focus back to a main buffer
  if not is_main_buffer(current_buf) then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if is_main_buffer(buf) then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end
end, { desc = "Close non-main buffers", silent = true })

map({ "n", "v" }, "<D-m>", ":MaximizerToggle<CR>", { desc = "Toggle Maximize/minimize", silent = true })
map("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
map("i", "kj", "<ESC>", { desc = "Exit insert mode with kj" })
-- map("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
-- map("n", "<esc>", ":noh<return><esc>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<Esc>", function()
  -- Get current buffer details
  local current = vim.api.nvim_get_current_buf()

  -- Get current buffer filetype safely
  local ft_ok, current_ft = pcall(function()
    return vim.bo[current].filetype
  end)

  -- Special handling: Let telescope handle its own Esc mappings
  -- Don't intercept Esc for telescope buffers
  if ft_ok and (current_ft == "TelescopePrompt" or current_ft == "TelescopeResults") then
    -- Do nothing - let telescope's attach_mappings handle Esc
    return
  end

  -- Only redirect focus if we're in an auxiliary buffer in normal mode
  if not is_main_buffer(current) then
    -- If in auxiliary buffer, go back to last main buffer if exists
    if vim.g.last_main_win and vim.api.nvim_win_is_valid(vim.g.last_main_win) then
      vim.g.last_aux_win = vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(vim.g.last_main_win)
      return
    end

    -- Otherwise find any main buffer
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if is_main_buffer(buf) then
        vim.g.last_aux_win = vim.api.nvim_get_current_win()
        vim.g.last_main_win = win
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  else
    -- Check if there are any LSP hover windows that should be closed first
    local hover_windows_closed = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local ok, config = pcall(vim.api.nvim_win_get_config, win)
      if ok and config.relative ~= "" then
        -- Check if this is an LSP hover window by checking window title or buffer name
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, 1, false)

        -- Skip treesitter-context windows (they have zindex >= 20)
        if not (config.zindex and config.zindex >= 20) then
          -- Check if it's likely an LSP hover window
          local is_hover_window = config.title and (
            config.title:match("Documentation") or
            config.title:match("Signature") or
            config.title:match("Hover")
          )

          if is_hover_window or (buf_lines[1] and buf_lines[1]:match("^#")) then
            pcall(vim.api.nvim_win_close, win, true)
            hover_windows_closed = true
          else
            -- Close other floating windows (signature help, etc.)
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end
    end

    -- If we closed any hover windows, don't clear search highlight
    if not hover_windows_closed then
      -- Clear search highlight
      vim.cmd("nohlsearch")
    end
  end
end, { desc = "Clear highlights or focus main buffer from auxiliary", silent = true })

-- Flash.nvim (EasyMotion replacement)
map("n", "<leader>k", ":lua require('flash').jump()<CR>", { desc = "Flash jump", silent = true })
map(
  "n",
  "<leader>j",
  ":lua require('flash').jump({search = {forward = true, wrap = false, multi_window = false}})<CR>",
  { desc = "Flash forward" }
)

-- File Explorer (NERDTree replacement)
map({ "n", "v" }, "<D-s>", ":NvimTreeFindFileToggle<CR>", {
  desc = "Toggle NvimTree and reveal current file",
  silent = true,
})

-- Diagnostics with Telescope
map({ "n", "t" }, "<D-6>", function()
  require("telescope.builtin").diagnostics({
    bufnr = 0,               -- Current buffer only
    theme = "ivy",           -- Use ivy theme for a beautiful compact container
    initial_mode = "normal", -- Start in normal mode instead of insert mode
    layout_config = {
      height = 0.5,          -- Take 50% of screen height for better visibility
      preview_cutoff = 120,
    },
    -- Enhanced diagnostic display
    severity_sort = true, -- Group by severity (errors first)
    no_sign = false,      -- Show diagnostic signs
    line_width = "full",  -- Full line width for better readability
    previewer = true,     -- Enable preview for context
    show_line = true,     -- Show line numbers
    attach_mappings = function(prompt_bufnr, map_func)
      local actions = require("telescope.actions")
      -- Override ESC to close telescope instead of going to normal mode
      map_func("i", "<Esc>", actions.close)
      map_func("n", "<Esc>", actions.close)
      map_func("n", "q", actions.close)
      return true
    end,
  })
end, { desc = "Show buffer diagnostics in telescope", silent = true })

-- Harpoon quick menu
map({ "n", "v" }, "<D-3>", function()
  require("harpoon.ui").toggle_quick_menu()
end, { desc = "Toggle Harpoon menu", silent = true })

-- Buffer-only Git Navigation (]c,) -- Remember [c is for jump to context
-- Function to navigate git changes only within current buffer
local function buffer_git_navigation(direction)
  local gitsigns = package.loaded.gitsigns
  if not gitsigns then
    vim.notify("Gitsigns not loaded", vim.log.levels.WARN)
    return
  end

  -- Simple navigation within current buffer only
  if direction == "next" then
    gitsigns.next_hunk()
  else
    gitsigns.prev_hunk()
  end
end

-- Normal + Visual mode
map({ "n", "v" }, "<D-S-j>", function()
  -- If in visual mode, move the entire selected block
  if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' or vim.fn.mode() == '\22' then
    -- Get the line numbers of the selection
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local last_line = vim.fn.line("$")

    -- Check if we're already at the end of the buffer
    if end_line >= last_line then
      return "<Esc>gv" -- Just maintain the selection
    end

    return ":'<,'>m '>+1<CR>gv=gv"
  else
    -- In normal mode, check if at last line
    if vim.fn.line(".") == vim.fn.line("$") then
      return "" -- Do nothing if at last line
    end
    -- Keep current single line behavior
    return ":m .+1<CR>=="
  end
end, { desc = "Move line/block down", expr = true, silent = true })

map({ "n", "v" }, "<D-S-k>", function()
  -- If in visual mode, move the entire selected block
  if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' or vim.fn.mode() == '\22' then
    -- Get the line numbers of the selection
    local start_line = vim.fn.line("'<")

    -- Check if we're already at the start of the buffer
    if start_line <= 1 then
      return "<Esc>gv" -- Just maintain the selection
    end

    return ":'<,'>m '<-2<CR>gv=gv"
  else
    -- In normal mode, check if at first line
    if vim.fn.line(".") == 1 then
      return "" -- Do nothing if at first line
    end
    -- Keep current single line behavior
    return ":m .-2<CR>=="
  end
end, { desc = "Move line/block up", expr = true, silent = true })

-- In insert mode (preserve cursor)
map("i", "<D-S-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down", silent = true }) -- Move line down
map("i", "<D-S-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up", silent = true })   -- Move line up

-- window management
map("n", "|", "<C-w>v", { desc = "Split window vertically" })         -- split window vertically
map("n", "_", "<C-w>s", { desc = "Split window horizontally" })       -- split window horizontally
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
-- tab management
map("n", "<D-t>", "<cmd>tabnew<CR>", { desc = "Open new tab" })       -- open new tab
-- Tab navigation (vi-style, most common among pros)
map("n", "gt", ":tabnext<CR>", { desc = "Next tab" })
map("n", "gT", ":tabprevious<CR>", { desc = "Previous tab" })
-- Window resizing (professional addition)
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Smart find and replace function
local function get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local line = vim.fn.getline(start_pos[2])
  local start_col = start_pos[3]
  local end_col = end_pos[3]

  -- Visual block mode needs special handling
  if vim.fn.visualmode() == "\22" then -- Ctrl+V (block) visualmode
    -- Get lines between start and end position
    local lines = {}
    for line_num = start_pos[2], end_pos[2] do
      local line_text = vim.fn.getline(line_num)
      -- For each line, extract the characters in the block selection
      local sub = string.sub(line_text, start_col, end_col)
      table.insert(lines, sub)
    end
    return table.concat(lines, "\n")
  end

  if start_pos[2] ~= end_pos[2] then
    -- Multiline selection - use a different approach
    local lines = vim.fn.getline(start_pos[2], end_pos[2])
    -- Ensure lines is a table
    if type(lines) == "string" then
      lines = { lines }
    end
    if #lines > 0 then
      lines[1] = string.sub(lines[1], start_col)
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
      return table.concat(lines, "\n")
    end
    return ""
  end

  return string.sub(line, start_col, end_col)
end

-- Smart find and replace mapping
vim.keymap.set("x", "<D-r>", function()
  local selection = get_visual_selection()
  if selection and selection ~= "" then
    vim.api.nvim_input("<Esc>:%s/" .. vim.fn.escape(selection, "/\\[]^$.*") .. "//gc<Left><Left><Left>")
  end
end, { desc = "Find and replace selected text", silent = true })

-- Find and replace in normal mode (opens dialog when nothing is selected)
vim.keymap.set("n", "<D-r>", function()
  vim.ui.input({ prompt = "Search pattern: " }, function(search_pattern)
    if search_pattern and search_pattern ~= "" then
      vim.ui.input({ prompt = "Replace with: " }, function(replace_with)
        if replace_with ~= nil then -- Can be empty string
          local confirm = "c"
          vim.ui.input({ prompt = "Confirm each replacement? (y/n): " }, function(answer)
            if answer and string.lower(answer) == "n" then
              confirm = ""
            end
            vim.cmd(
              ":%s/"
              .. vim.fn.escape(search_pattern, "/\\[]^$.*")
              .. "/"
              .. vim.fn.escape(replace_with, "/\\[]^$.*")
              .. "/g"
              .. confirm
            )
          end)
        end
      end)
    end
  end)
end, { desc = "Find and replace dialog", silent = true })

-- Save all modified buffers only
local function save_all_modified()
  local modified_count = 0
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'modified') then
      local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
      if buftype == '' then -- Only save normal file buffers
        local ok, err = pcall(function()
          vim.api.nvim_buf_call(buf, function()
            vim.cmd('write')
          end)
        end)
        if ok then
          modified_count = modified_count + 1
        else
          local bufname = vim.api.nvim_buf_get_name(buf)
          local filename = vim.fn.fnamemodify(bufname, ':t')
          vim.notify('Error saving ' .. filename .. ': ' .. tostring(err), vim.log.levels.WARN)
        end
      end
    end
  end

  if modified_count > 0 then
    vim.notify('Saved ' .. modified_count .. ' modified buffer(s)', vim.log.levels.INFO)
  else
    vim.notify('No modified buffers to save', vim.log.levels.INFO)
  end
end

map({ "n", "i", "v" }, "<D-S-s>", save_all_modified,
  { desc = "Save all modified buffers", noremap = true, silent = true })

-- Background mode selector keymap
map("n", "<leader>tt", function()
  _G.telescope_background_picker()
end, { desc = "Select background mode", silent = true })

-- Toggle whitespace display
map("n", "<leader>tw", function()
  if vim.opt.list:get() then
    vim.opt.list = false
    vim.notify("Whitespace display: OFF", vim.log.levels.INFO)
  else
    vim.opt.list = true
    vim.notify("Whitespace display: ON", vim.log.levels.INFO)
  end
end, { desc = "Toggle whitespace display", silent = true })

-- Code Runner - Run code snippets and files
map("n", "<leader>cr", "<cmd>RunCode<CR>", { desc = "Run code in current buffer" })
map("v", "<leader>cr", "<cmd>RunCode<CR>", { desc = "Run selected code" })

-- command + enter combinations for insert blank line top and bottom
-- Insert a blank line below (Cmd + Enter) in insert mode
vim.keymap.set("i", "<D-CR>", function()
  return "<Esc>o" -- exit insert, open line below, stay in insert
end, { expr = true, silent = true })

-- Insert a blank line above (Cmd + Shift + Enter) in insert mode
vim.keymap.set("i", "<D-S-CR>", function()
  return "<Esc>O" -- exit insert, open line above, stay in insert
end, { expr = true, silent = true })

-- Disable Shift+j and Shift+k in normal mode
vim.keymap.set({ "n", "v" }, "<S-j>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<S-k>", "<Nop>", { noremap = true, silent = true })

-- Oil.nvim keymaps
vim.keymap.set("n", "<BS>", "<CMD>Oil<CR>", { desc = "Open parent directory with Oil" })

-- Open workspace root in Oil
vim.keymap.set("n", "<S-BS>", function()
  -- Use Neovim's LSP workspaceFolders or fallback to current working dir
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  local root = nil
  for _, client in ipairs(clients) do
    if client.config.root_dir then
      root = client.config.root_dir
      break
    end
  end
  if not root then
    root = vim.fn.getcwd()
  end
  require("oil").open(root)
end, { desc = "Open workspace root with Oil" })
-- Spectre
vim.keymap.set('n', '<leader>R', '<cmd>lua require("spectre").toggle()<CR>', {
  desc = "Toggle Spectre"
})
vim.keymap.set('n', '<leader>rw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
  desc = "Search current word"
})
vim.keymap.set('v', '<leader>rw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
  desc = "Search current word"
})
vim.keymap.set('n', '<leader>rp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
  desc = "Search on current file"
})
