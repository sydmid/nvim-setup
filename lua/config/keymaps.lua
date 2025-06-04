local map = vim.keymap.set

-- Set default scrolloff to 5 globally
vim.o.scrolloff = 5

-- Leader key is set in init.lua

-- NAVIGATION GUIDE: BRACKETS REPLACED WITH LEADER KEYS
-- To make bracket navigation ([ and ]) instant without delays, we've replaced all
-- bracket-based keymaps with leader key alternatives:
--
-- Git navigation:
--   <leader>gC - Next git change (was ]c)
--   <leader>gc - Previous git change (was [c)
--
-- Diagnostic navigation:
--   <leader>dj - Next diagnostic (was ]e or <D-S-]>) - ALSO: CMD+] (<D-]>)
--   <leader>dk - Previous diagnostic (was [e or <D-S-[>) - ALSO: CMD+[ (<D-[>)
--
-- Hunks navigation (gitsigns):
--   <leader>hj - Next hunk (was ]h)
--   <leader>hk - Previous hunk (was [h)
--
-- Todo comments:
--   <leader>tj - Next todo comment (was ]t)
--   <leader>tk - Previous todo comment (was [t)
--
-- Bookmarks (VSCode-style):
--   <leader>m  - Toggle bookmark
--   <D-S-]>    - Jump to next bookmark (Shift+CMD+])
--   <D-S-[>    - Jump to previous bookmark (Shift+CMD+[)
--   <leader>ml - List all bookmarks
--   <leader>ma - Add annotation to bookmark
--   <leader>mc - Clear bookmarks in current buffer
--
-- Code block navigation using treesitter (VS Code gotoNextPreviousMember style):
--   g] - Next code block (functions, methods, classes, properties, etc.)
--   g[ - Previous code block (functions, methods, classes, properties, etc.)
--   (Works in both normal and visual modes, just like in VS Code)
--   (Highly optimized for instant response with zero delay)

-- better find in document
vim.keymap.set("x", "/", function()
	-- Yank the selected text
	vim.cmd("normal! y")
	-- Escape any special characters in the yanked text for the search
	local text = vim.fn.getreg('"')
	text = vim.fn.escape(text, [[\/]])
	-- Start search
	vim.fn.feedkeys("/" .. text .. "\n", "n")
end, { noremap = true, silent = true })

-- Buffer management commands (which-key compatible)
map("n", "<leader>bb", "<cmd>e #<CR>", { desc = "Switch to other buffer" })
map("n", "<leader>`", "<cmd>e #<CR>", { desc = "Switch to other buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Delete other buffers" })
map("n", "<leader>bD", "<cmd>bdelete!<CR>", { desc = "Delete buffer and window" })

-- Register buffer commands with which-key explicitly
vim.defer_fn(function()
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.register({
      ["<leader>b"] = { name = "Buffer" },
      ["<leader>bb"] = { "<cmd>e #<CR>", "Switch to other buffer" },
      ["<leader>bd"] = { "<cmd>bdelete<CR>", "Delete buffer" },
      ["<leader>bo"] = { "<cmd>%bd|e#|bd#<CR>", "Delete other buffers" },
      ["<leader>bD"] = { "<cmd>bdelete!<CR>", "Delete buffer and window" },
    })
  end
end, 100)

vim.keymap.set("x", "<D-f>", function()
	-- Yank the selected text
	vim.cmd("normal! y")
	-- Escape any special characters in the yanked text for the search
	local text = vim.fn.getreg('"')
	text = vim.fn.escape(text, [[\/]])
	-- Start search
	vim.fn.feedkeys("/" .. text .. "\n", "n")
end, { noremap = true, silent = true })
-- vim.keymap.set("x", "/", function()
-- 	-- Yank the selected text
-- 	vim.cmd("normal! y")
-- 	-- Escape any special characters in the yanked text for the search
-- 	local text = vim.fn.getreg('"')
-- 	text = vim.fn.escape(text, [[\/]])
-- 	-- Start search
-- 	vim.fn.feedkeys("/" .. text .. "\n", "n")
-- end, { noremap = true, silent = true })
-- File navigation
map("n", "\\e", ":e ~/.config/nvim/init.lua<CR>", { desc = "Edit init.lua" })
map("n", "\\r", ":source ~/.config/nvim/init.lua<CR>", { desc = "Reload config" })
map("n", "<leader>t", ":ToggleTerm<CR>", { desc = "Toggle terminal" })

-- Better navigation
map("v", "<S-J>", "5gj", { desc = "Move down 5 lines", silent = true })
map("v", "<S-K>", "5gk", { desc = "Move up 5 lines", silent = true })
map("n", "<S-J>", "5gj", { desc = "Move down 5 lines", silent = true })
map("n", "<S-K>", "5gk", { desc = "Move up 5 lines", silent = true })

map("n", "<D-j>", ":set scrolloff=0<CR>5j5<C-e>:set scrolloff=5<CR>", { noremap = true, silent = true })
map("n", "<D-k>", ":set scrolloff=0<CR>5k5<C-y>:set scrolloff=5<CR>", { noremap = true, silent = true })

map({"n","v"}, "H", "b", { desc = "Previous word", silent = true })
map({"n","v"}, "L", "e", { desc = "Next word", silent = true })
map({"n","v"}, "<D-h>", "_", { desc = "Start of line", silent = true })
map({"n","v"}, "<D-l>", "$", { desc = "End of line", silent = true })

-- Improved redo
map("n", "U", "<C-r>", { desc = "Redo", silent = true })

-- Deletion without yanking
map("n", "<leader>dd", "d", { desc = "Delete with yanking" })
map("n", "c", '"_c', { desc = "c: Change without yanking" })
map("n", "x", '"_x', { desc = "x: Delete char without yanking" })
map("n", "d", '"_d', { desc = "d: Delete without yanking" })
map("n", "D", '"_D', { desc = "D: Delete to EOL without yanking" })
map("v", "d", '"_d', { desc = "d: Delete without yanking" })

-- Code formatting
map("n", "<leader>fd", function()
	local conform = require("conform")

	-- Get the current buffer's filename
	local filename = vim.api.nvim_buf_get_name(0)

	-- Special handling for .zshrc and similar files
	if filename:match("%.zshrc$") or
	   filename:match("%.zsh_") or
	   filename:match("%.bashrc$") or
	   filename:match("%.bash_") then
		-- Save cursor position
		local cursor_pos = vim.api.nvim_win_get_cursor(0)

		-- Handle shell files that might have complex parameter expansions
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local result = {}
		local indent_level = 0
		local indent_size = 2

		for _, line in ipairs(lines) do
			local trimmed = vim.trim(line)

			-- Check for closing markers to decrease indent first
			if trimmed:match("^fi$")
				or trimmed:match("^done$")
				or trimmed:match("^}$")
				or trimmed:match("^esac$")
				or trimmed:match("^%)$") then
				indent_level = math.max(0, indent_level - 1)
			end

			-- Add appropriate indent or preserve empty lines
			if #trimmed > 0 then
				local indent = string.rep(" ", indent_level * indent_size)
				table.insert(result, indent .. trimmed)
			else
				table.insert(result, "")  -- Preserve empty line without indentation
			end

			-- Check for opening markers to increase indent
			if trimmed:match("^if ")
				or trimmed:match("then$")
				or trimmed:match("^for ")
				or trimmed:match("do$")
				or trimmed:match("^while ")
				or trimmed:match("^{$")
				or trimmed:match("^case ")
				or trimmed:match("^function ")
				or trimmed:match("%([ ]*%)[ ]*{[ ]*$") then
				indent_level = indent_level + 1
			end
		end

		-- Replace buffer content with formatted content
		vim.api.nvim_buf_set_lines(0, 0, -1, false, result)

		-- Restore cursor position
		vim.api.nvim_win_set_cursor(0, cursor_pos)

		vim.notify("Applied custom shell formatting", vim.log.levels.INFO)
	else
		-- Use conform for regular formatting
		conform.format({
			lsp_fallback = true,
			async = false,
			timeout_ms = 1000,
		})
	end
end, { desc = "Format document" })

-- Structure view (similar to IDE structure tool)
-- map("n", "<D-o>", ":SymbolsOutline<CR>", { desc = "Toggle structure view", silent = true })

-- LSP keymaps have been moved to lua/plugins/lsp/lspconfig.lua
-- This centralizes all LSP functionality and ensures keymaps are only active
-- when an LSP server is actually attached to the current buffer

-- Harpoon mappings
map("n", "<leader>a1", ":lua require('harpoon.mark').add_file()<CR>", { desc = "Add to harpoon" })
map("n", "<leader>a2", ":lua require('harpoon.mark').add_file(2)<CR>", { desc = "Add to harpoon 2" })
map("n", "<leader>a3", ":lua require('harpoon.mark').add_file(3)<CR>", { desc = "Add to harpoon 3" })
map("n", "<leader>a4", ":lua require('harpoon.mark').add_file(4)<CR>", { desc = "Add to harpoon 4" })
map("n", "<leader>a5", ":lua require('harpoon.mark').add_file(5)<CR>", { desc = "Add to harpoon 5" })

map("n", "<leader>1", ":lua require('harpoon.ui').nav_file(1)<CR>", { desc = "Navigate to harpoon 1" })
map("n", "<leader>2", ":lua require('harpoon.ui').nav_file(2)<CR>", { desc = "Navigate to harpoon 2" })
map("n", "<leader>3", ":lua require('harpoon.ui').nav_file(3)<CR>", { desc = "Navigate to harpoon 3" })
map("n", "<leader>4", ":lua require('harpoon.ui').nav_file(4)<CR>", { desc = "Navigate to harpoon 4" })
map("n", "<leader>5", ":lua require('harpoon.ui').nav_file(5)<CR>", { desc = "Navigate to harpoon 5" })

map('n', '<C-Tab>', ":bn<CR>", { noremap = true, silent = true })
map('n', '<C-S-Tab>', ":bp<CR>", { noremap = true, silent = true })

-- Eagerly load harpoon modules at startup to ensure instant response
-- This is more effective than the previous lazy-loading approach
vim.defer_fn(function()
  -- Pre-require all harpoon modules at startup
  local harpoon = require('harpoon')
  local ui = require('harpoon.ui')
  local mark = require('harpoon.mark')

  -- Set up an optimized toggle function that doesn't need to load modules on each call
  vim.keymap.set('n', '<leader>h', function()
    ui.toggle_quick_menu()
  end, { noremap = true, silent = true, nowait = true, desc = "Harpoon Menu" })
end, 100) -- Small delay to prioritize critical startup tasks first

-- Backup keybinding in case eager loading fails
map('n', '<leader>hh', function()
  require("harpoon.ui").toggle_quick_menu()
end, { noremap = true, silent = true, nowait = true, desc = "Harpoon Menu (fallback)" })

map("n", "<leader>aa", ":lua require('harpoon.mark').add_file()<CR>", { desc = "Add to harpoon" })

-- Additional IDE-like actions
-- map("n", "<leader>db", ":lua require('dap').toggle_breakpoint()<CR>", { desc = "Toggle breakpoint" })
map("n", "<leader>tr", ":lua require('trouble').toggle()<CR>", { desc = "Toggle trouble" })
map("n", "<leader>nf", ":NvimTreeFindFile<CR>", { desc = "Find in file explorer" })
map("n", "<leader>r", ":lua vim.lsp.buf.rename()<CR>", { desc = "Rename symbol" })

-- Method and property navigation - Optimized for performance
-- Implements VS Code's gotoNextPreviousMember.nextMember and previousMember functionality

-- Use lazy loading to avoid startup errors
-- Instead of: local ts_move = require("nvim-treesitter.textobjects.move")

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
map("i", ",,", "<ESC>la, <ESC>", { desc = "Add comma", silent = true })
map("i", ">>", "<ESC>la => ,<ESC>f,i", { desc = "Add arrow function", silent = true })

-- Visual mode mappings
map("v", "<", "<gv", { desc = "Indent left and keep selection", silent = true })
map("v", ">", ">gv", { desc = "Indent right and keep selection", silent = true })

-- Folding mappings
map("n", "zf", "zf", { desc = "Create fold" })
map("n", "zd", "zd", { desc = "Delete fold" })
map("n", "zo", "zo", { desc = "Open fold" })
map("n", "zO", "zO", { desc = "Open all folds" })
map("n", "zc", "zc", { desc = "Close fold" })
map("n", "zC", "zC", { desc = "Close all folds" })
map("n", "za", "za", { desc = "Toggle fold" })
map("n", "zR", "zR", { desc = "Open all folds" })
map("n", "zM", "zM", { desc = "Close all folds" })
map("n", "<leader>z", "za", { desc = "Toggle fold under cursor" })
map("n", "<leader>Z", function()
	if vim.wo.foldenable then
		vim.wo.foldenable = false
	else
		vim.wo.foldenable = true
	end
end, { desc = "Toggle folding" })

-- Global marks with g prefix to avoid conflicts
map("n", "gma", "mA", { desc = "Set global mark A" })
map("n", "gmb", "mB", { desc = "Set global mark B" })
map("n", "gma", "`A", { desc = "Go to global mark A" })
map("n", "gmb", "`B", { desc = "Go to global mark B" })

-- Fuzzy finding (Telescope equivalents)
-- map({ "n", "v" }, "<D-p>", function()
-- 	require("telescope.builtin").find_files({
-- 		sort_mru = true,
-- 		sorter = require("telescope.sorters").get_fuzzy_file(),
-- 		previewer = true, -- Enable file preview
-- 		layout_config = {
-- 			height = 0.8, -- Increase height for better visibility
-- 			width = 0.9,
-- 			preview_width = 0.5, -- Allocate half the width to preview
-- 		},
-- 	})
-- end, { desc = "telescope find files sorted by proximity and recency", silent = true })

-- Separate normal and visual mode mappings for D-S-f
map("n", "<D-S-f>", ":Telescope live_grep<CR>", { desc = "telescope find string in all files", silent = true })
map("v", "<D-S-f>", function()
	-- Yank the selected text to the unnamed register
	vim.cmd("normal! y")
	-- Get the yanked text
	local selected_text = vim.fn.getreg('"')
	-- Escape special characters
	selected_text = selected_text:gsub("([%[%]%^%$%(%)])", "\\%1")
	-- Call telescope with the selected text as the default search term
	require("telescope.builtin").live_grep({ default_text = selected_text })
end, { desc = "telescope find selected text in all files", silent = true })

-- Enhanced search function that searches for word under cursor
local function search_word_under_cursor()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		-- If no word under cursor, fall back to regular search
		vim.api.nvim_feedkeys("/", "n", false)
	else
		-- Search for the word using vim's search functionality
		-- Use \< and \> for whole word matching (vim best practice)
		local search_pattern = "\\<" .. vim.fn.escape(word, "\\") .. "\\>"
		vim.fn.setreg("/", search_pattern)
		vim.cmd("normal! n")
		-- Enable search highlighting
		vim.opt.hlsearch = true
	end
end

map("n", "<D-f>", search_word_under_cursor, { desc = "search word under cursor in current file", silent = true })

-- Miscellaneous
map({ "n", "i", "v" }, "<D-s>", "<Cmd>w<CR>", { noremap = true, silent = true })
map({ "n", "i", "v" }, "<D-S-s>", "<Cmd>wa<CR>", { noremap = true, silent = true })
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

-- -- Tab key toggles between main buffer and auxiliary buffers
map("n", "<Tab>", function()
	local current = vim.api.nvim_get_current_buf()

	-- Track the last known main and auxiliary buffers/windows
	if not vim.g.last_main_win then
		vim.g.last_main_win = nil
		vim.g.last_aux_win = nil
	end

	-- If in a main buffer, focus on last auxiliary buffer if exists
	if is_main_buffer(current) then
		if vim.g.last_aux_win and vim.api.nvim_win_is_valid(vim.g.last_aux_win) then
			vim.g.last_main_win = vim.api.nvim_get_current_win()
			vim.api.nvim_set_current_win(vim.g.last_aux_win)
			return
		end

		-- Otherwise find any auxiliary buffer to focus
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if not is_main_buffer(buf) then
				vim.g.last_main_win = vim.api.nvim_get_current_win()
				vim.g.last_aux_win = win
				vim.api.nvim_set_current_win(win)
				return
			end
		end
	else
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
	end
end, { desc = "Toggle between main and auxiliary buffers", silent = true })

vim.keymap.set("n", "<D-b>", function()
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

	-- First pass: identify buffers to close (avoiding symbols-outline)
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			-- Skip the current buffer if it's a main buffer
			if bufnr ~= current_buf or not is_main_buffer(current_buf) then
				if not is_main_buffer(bufnr) then
					local name_ok, buf_name = pcall(vim.api.nvim_buf_get_name, bufnr)
					-- Skip symbols-outline buffer which needs special handling
					if not (name_ok and buf_name:match("symbols%-outline")) then
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

map({ "n", "v" }, "<D-S-t>", ":silent! %bd!|e#|bd#<CR>", {
	desc = "Force close all buffers except current",
	silent = true,
})

map({ "n", "v" }, "<D-m>", ":MaximizerToggle<CR>", { desc = "Toggle Maximize/minimize", silent = true })
map("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
map("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
map("n", "'", "`", { desc = "Go to mark" })
map("n", "Y", "^vg_y", { desc = "Yank line contents" })
-- map("n", "<esc>", ":noh<return><esc>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<Esc>", function()
	-- Get current buffer details
	local current = vim.api.nvim_get_current_buf()

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
		-- Clear search highlight
		vim.cmd("nohlsearch")

		-- Close floating windows (hover, signature help, etc.)
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local ok, config = pcall(vim.api.nvim_win_get_config, win)
			if ok and config.relative ~= "" then
				pcall(vim.api.nvim_win_close, win, true)
			end
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
map("n", "<D-1>", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer", silent = true })
-- map({ "n", "v" }, "<D-1>", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer", silent = true })
map({ "n", "v" }, "<D-e>", ":NvimTreeFindFile<CR>", { desc = "Reveal current file in tree", silent = true })

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
      return "<Esc>gv"  -- Just maintain the selection
    end

    return ":'<,'>m '>+1<CR>gv=gv"
  else
    -- In normal mode, check if at last line
    if vim.fn.line(".") == vim.fn.line("$") then
      return ""  -- Do nothing if at last line
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
      return "<Esc>gv"  -- Just maintain the selection
    end

    return ":'<,'>m '<-2<CR>gv=gv"
  else
    -- In normal mode, check if at first line
    if vim.fn.line(".") == 1 then
      return ""  -- Do nothing if at first line
    end
    -- Keep current single line behavior
    return ":m .-2<CR>=="
  end
end, { desc = "Move line/block up", expr = true, silent = true })

-- In insert mode (preserve cursor)
map("i", "<D-S-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down", silent = true }) -- Move line down
map("i", "<D-S-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up", silent = true }) -- Move line up

-- window management
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

map("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
map("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
map("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
map("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

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

-- Arabic language support
vim.keymap.set("n", "<leader>ar", function()
	if _G.toggle_arabic then
		_G.toggle_arabic()
	else
		vim.notify("Arabic support is not loaded", vim.log.levels.WARN)
	end
end, { desc = "Toggle Arabic mode" })

-- Toggle Arabic keyboard mapping in insert mode
vim.keymap.set("i", "<C-^>", function()
	if vim.bo.keymap == "arabic" then
		vim.bo.keymap = ""
		vim.notify("Arabic keymap disabled", vim.log.levels.INFO)
	else
		vim.bo.keymap = "arabic"
		vim.notify("Arabic keymap enabled", vim.log.levels.INFO)
	end
end, { desc = "Toggle Arabic keymap" })

-- Buffer navigation with Cmd+Left/Right arrows (similar to IDE tab navigation)
map("n", "<D-Left>", ":bprevious<CR>", { desc = "Navigate to previous buffer", silent = true })
map("n", "<D-Right>", ":bnext<CR>", { desc = "Navigate to next buffer", silent = true })
