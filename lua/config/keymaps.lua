local map = vim.keymap.set
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
  vim.notify("Buffer reset from disk", vim.log.levels.INFO)
end, { desc = "Reset buffer (reload from disk)" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete other buffers" })

vim.keymap.set("x", "<D-f>", function()
	-- Yank the selected text
	vim.cmd("normal! y")
	-- Escape any special characters in the yanked text for the search
	local text = vim.fn.getreg('"')
	text = vim.fn.escape(text, [[\/]])
	-- Start search
	vim.fn.feedkeys("/" .. text .. "\n", "n")
end, { noremap = true, silent = true })
map("n", "\\r", ":source ~/.config/nvim/init.lua<CR>", { desc = "Reload config" })
map("n", "<D-`>", function()
  local terminals = require('config.terminals')
  terminals.toggle_or_create_terminal("default", "fish")
end, { desc = "Toggle terminal" })

-- Terminal mode keymaps for better terminal interaction
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<D-`>", function()
  -- Exit terminal mode and toggle the terminal
  vim.cmd("stopinsert")
  local terminals = require('config.terminals')
  terminals.toggle_or_create_terminal("default", "fish")
end, { desc = "Toggle terminal from terminal mode" })


map({"n","v"}, "H", "b", { desc = "Previous word", silent = true })
map({"n","v"}, "L", "e", { desc = "Next word", silent = true })
map({"n","v"}, "<D-h>", "_", { desc = "Start of line", silent = true })
map({"n","v"}, "<D-l>", "$", { desc = "End of line", silent = true })
map("i", "<D-h>", "<C-o>_", { desc = "Start of line", silent = true })
map("i", "<D-l>", "<C-o>$", { desc = "End of line", silent = true })

-- Improved redo
map("n", "U", "<C-r>", { desc = "Redo", silent = true })

-- Jump list navigation (fix Ctrl+i being overridden by Tab mapping)
-- Ctrl+o (backward) works by default, but Ctrl+i (forward) is overridden by the Tab mapping
map("n", "<C-i>", "<C-i>", { desc = "Jump forward in jump list", silent = true })

-- Deletion without yanking
map("n", "c", '"_c', { desc = "c: Change without yanking" })
map("n", "x", '"_x', { desc = "x: Delete char without yanking" })
map("n", "d", '"_d', { desc = "d: Delete without yanking" })
map("n", "D", '"_D', { desc = "D: Delete to EOL without yanking" })
map("v", "d", '"_d', { desc = "d: Delete without yanking" })


-- Alternative formats that might work in different terminals
vim.keymap.set('n', '<C-Tab>', ':bnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-S-Tab>', ':bprevious<CR>', { noremap = true, silent = true })

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
			lsp_format = "fallback",
			timeout_ms = 1000,
		})
	end
end, { desc = "Format document" })

-- Harpoon mappings
map("n", "<leader>hh", ":lua require('harpoon.mark').add_file()<CR>", { desc = "Add to harpoon" })

map("n", "<leader>1", ":lua require('harpoon.ui').nav_file(1)<CR>", { desc = "Navigate to harpoon 1" })
map("n", "<leader>2", ":lua require('harpoon.ui').nav_file(2)<CR>", { desc = "Navigate to harpoon 2" })
map("n", "<leader>3", ":lua require('harpoon.ui').nav_file(3)<CR>", { desc = "Navigate to harpoon 3" })
map("n", "<leader>4", ":lua require('harpoon.ui').nav_file(4)<CR>", { desc = "Navigate to harpoon 4" })
map("n", "<leader>5", ":lua require('harpoon.ui').nav_file(5)<CR>", { desc = "Navigate to harpoon 5" })


-- Additional IDE-like actions
map("n", "<leader>tr", ":lua require('trouble').toggle()<CR>", { desc = "Toggle trouble" })
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
map("i", ",,", "<ESC>A,<ESC>", { desc = "Add comma at the end", silent = true })
-- map("i", ",,", "<ESC>la, <ESC>", { desc = "Add comma", silent = true })
map("i", ">>", "<ESC>la => <ESC>i", { desc = "Add arrow function", silent = true })

-- Visual mode mappings
map("v", "<", "<gv", { desc = "Indent left and keep selection", silent = true })
map("v", ">", ">gv", { desc = "Indent right and keep selection", silent = true })


-- Global marks with g prefix to avoid conflicts
map("n", "gma", "mA", { desc = "Set global mark A" })
map("n", "gmb", "mB", { desc = "Set global mark B" })
map("n", "gma", "`A", { desc = "Go to global mark A" })
map("n", "gmb", "`B", { desc = "Go to global mark B" })

-- Miscellaneous
map({ "n", "i", "v" }, "<D-s>", "<Cmd>w<CR>", { noremap = true, silent = true })

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

-- -- Tab key toggles between main buffer and auxiliary buffers
map({"n","t"}, "<Tab>", function()
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
map("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
map("n", "Y", "^vg_y", { desc = "Yank line contents" })
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

-- Diagnostics with Telescope
map("n", "<D-6>", function()
	require("telescope.builtin").diagnostics({
		bufnr = 0, -- Current buffer only
		theme = "ivy", -- Use ivy theme for a beautiful compact container
        initial_mode = "normal", -- Start in normal mode instead of insert mode
		layout_config = {
			height = 0.5, -- Take 50% of screen height for better visibility
			preview_cutoff = 120,
		},
		-- Enhanced diagnostic display
		severity_sort = true, -- Group by severity (errors first)
		no_sign = false, -- Show diagnostic signs
		line_width = "full", -- Full line width for better readability
		previewer = true, -- Enable preview for context
		show_line = true, -- Show line numbers
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

-- Buffers with Telescope
map("n", "<D-2>", function()
	require("telescope.builtin").buffers({
		theme = "ivy", -- Consistent theme with diagnostics
		initial_mode = "normal", -- Start in normal mode instead of insert mode
		layout_config = {
			height = 0.5,
			preview_cutoff = 120,
		},
		-- Enhanced buffer display
		show_all_buffers = true,
		sort_mru = true, -- Sort by most recently used
		sort_lastused = true,
		previewer = true,
		attach_mappings = function(prompt_bufnr, map_func)
			local actions = require("telescope.actions")
			-- Override ESC to close telescope instead of going to normal mode
			map_func("i", "<Esc>", actions.close)
			map_func("n", "<Esc>", actions.close)
			map_func("n", "q", actions.close)
			return true
		end,
	})
end, { desc = "Show buffers in telescope", silent = true })

-- Harpoon quick menu
map("n", "<D-3>", function()
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

-- Workspace Git Navigation with Telescope (]C, [C)
-- Function for workspace-wide git change navigation
local function workspace_git_navigation(direction)
	local telescope_builtin = require("telescope.builtin")
	if not telescope_builtin then
		vim.notify("Telescope not available for workspace git navigation", vim.log.levels.WARN)
		return
	end

	-- Get current project root for scoping
	local cwd = vim.fn.getcwd()
	local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")[1]
	local project_root = (vim.v.shell_error == 0 and git_root) or cwd

	telescope_builtin.git_status({
		prompt_title = direction == "next" and "󰊢 Next Git Changes - " .. vim.fn.fnamemodify(project_root, ":t") or "󰊢 Previous Git Changes - " .. vim.fn.fnamemodify(project_root, ":t"),
		initial_mode = "normal",
		theme = "ivy",
		layout_config = { height = 0.6 },
		cwd = project_root,
		attach_mappings = function(prompt_bufnr, map)
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			-- Enter to open file at first change
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if selection then
					vim.cmd("edit " .. selection.value)
					-- Jump to first/last hunk in the opened file
					vim.defer_fn(function()
						local gitsigns = package.loaded.gitsigns
						if gitsigns then
							if direction == "next" then
								pcall(gitsigns.next_hunk)
							else
								-- For previous, go to last hunk
								pcall(function()
									-- Move to end of file then find previous hunk
									vim.cmd("normal! G")
									gitsigns.prev_hunk()
								end)
							end
						end
					end, 100)
				end
			end)

			return true
		end,
	})
end

-- Buffer-only git navigation (]c,) - Remember !!! c[ is for jump to context
vim.keymap.set("n", "]c", function()
	buffer_git_navigation("next")
end, { desc = "Next git change (buffer only)", silent = true })

-- Workspace git navigation (]C, [C)
vim.keymap.set("n", "]C", function()
	workspace_git_navigation("next")
end, { desc = "Next git change (workspace)", silent = true })

vim.keymap.set("n", "[C", function()
	workspace_git_navigation("prev")
end, { desc = "Previous git change (workspace)", silent = true })

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
map("n", "|", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
map("n", "_", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
-- tab management
map("n", "<D-n>", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
map("n", "<D-]>", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
map("n", "<D-[>", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab

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

-- Terminal management system using the terminals.lua module
-- Load the terminal management module
local terminals = require('config.terminals')

-- Service terminals (moved to 't' group - numbers 1-9)
map("n", "<leader>t1", function() terminals.run_in_terminal("web", "just web") end, { desc = "Run web service" })
map("n", "<leader>t2", function() terminals.run_in_terminal("api", "just api") end, { desc = "Run API service" })
map("n", "<leader>t3", function() terminals.run_in_terminal("database", "just db") end, { desc = "Run database" })
map("n", "<leader>t4", function() terminals.run_in_terminal("worker", "just worker") end, { desc = "Run worker" })
map("n", "<leader>t5", function() terminals.run_in_terminal("test", "just test") end, { desc = "Run tests" })
map("n", "<leader>t6", function() terminals.run_in_terminal("build", "just build") end, { desc = "Run build" })
map("n", "<leader>t7", function() terminals.run_in_terminal("dev", "just dev") end, { desc = "Run dev server" })
map("n", "<leader>t8", function() terminals.run_in_terminal("logs", "just logs") end, { desc = "View logs" })
map("n", "<leader>t9", function() terminals.run_in_terminal("monitor", "just monitor") end, { desc = "Run monitor" })

-- Terminal focus keymaps (ta = terminal a, tb = terminal b, etc.)
map("n", "<leader>ta", function() terminals.focus_terminal("web") end, { desc = "Focus web terminal" })
map("n", "<leader>tb", function() terminals.focus_terminal("api") end, { desc = "Focus API terminal" })
map("n", "<leader>tc", function() terminals.focus_terminal("database") end, { desc = "Focus database terminal" })
map("n", "<leader>td", function() terminals.focus_terminal("worker") end, { desc = "Focus worker terminal" })
map("n", "<leader>te", function() terminals.focus_terminal("test") end, { desc = "Focus test terminal" })
map("n", "<leader>tg", function() terminals.focus_terminal("build") end, { desc = "Focus build terminal" })
map("n", "<leader>ti", function() terminals.focus_terminal("dev") end, { desc = "Focus dev terminal" })
map("n", "<leader>tl", function() terminals.focus_terminal("logs") end, { desc = "Focus logs terminal" })
map("n", "<leader>tm", function() terminals.focus_terminal("monitor") end, { desc = "Focus monitor terminal" })

-- Terminal cycling and management
map("n", "<leader>tn", function() terminals.cycle_terminals("next") end, { desc = "Next terminal" })
map("n", "<leader>tp", function() terminals.cycle_terminals("previous") end, { desc = "Previous terminal" })
map("n", "<leader>ts", terminals.terminal_picker, { desc = "Select terminal (Telescope)" })
map("n", "<leader>tr", function()
  local name = vim.fn.input("Terminal name to restart: ")
  if name ~= "" then terminals.restart_terminal(name) end
end, { desc = "Restart terminal" })
map("n", "<leader>tk", terminals.kill_all_terminals, { desc = "Kill all terminals" })
map("n", "<leader>tq", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local terminals_module = require('config.terminals')
  local active_terminals = terminals_module.list_terminals()

  for _, term_data in ipairs(active_terminals) do
    if term_data.bufnr == current_buf then
      terminals_module.close_terminal(term_data.name)
      return
    end
  end
  vim.notify("Current buffer is not a managed terminal", vim.log.levels.WARN)
end, { desc = "Close current terminal" })

-- Debug cursor state for troubleshooting
map("n", "<leader>tD", function() terminals.debug_cursor_state() end, { desc = "Debug terminal cursor state" })

-- Register terminal commands with which-key
vim.defer_fn(function()
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.add({
      { "<leader>t", group = "Terminal" },
      { "<leader>tf", desc = "Toggle floating terminal" },
      { "<leader>tv", desc = "Toggle vertical terminal" },
      { "<leader>th", desc = "Toggle horizontal terminal" },
      { "<leader>ts", desc = "Select terminal (Telescope)" },
      { "<leader>tn", desc = "Next terminal" },
      { "<leader>tp", desc = "Previous terminal" },
      { "<leader>tr", desc = "Restart terminal" },
      { "<leader>tk", desc = "Kill all terminals" },
      { "<leader>tq", desc = "Close current terminal" },

      -- Service terminals (moved to 't' prefix with numbers)
      { "<leader>t1", desc = "🌐 Run Web Server" },
      { "<leader>t2", desc = "🔗 Run API Server" },
      { "<leader>t3", desc = "🗃️ Run Database" },
      { "<leader>t4", desc = "⚙️ Run Worker" },
      { "<leader>t5", desc = "🧪 Run Tests" },
      { "<leader>t6", desc = "🔨 Run Build" },
      { "<leader>t7", desc = "💻 Run Dev Server" },
      { "<leader>t8", desc = "📋 View Logs" },
      { "<leader>t9", desc = "📊 Run Monitor" },

      -- Terminal focus
      { "<leader>ta", desc = "🌐 Focus Web Terminal" },
      { "<leader>tb", desc = "🔗 Focus API Terminal" },
      { "<leader>tc", desc = "🗃️ Focus Database Terminal" },
      { "<leader>td", desc = "⚙️ Focus Worker Terminal" },
      { "<leader>te", desc = "🧪 Focus Test Terminal" },
      { "<leader>tg", desc = "🔨 Focus Build Terminal" },
      { "<leader>ti", desc = "💻 Focus Dev Terminal" },
      { "<leader>tl", desc = "📋 Focus Logs Terminal" },
      { "<leader>tm", desc = "📊 Focus Monitor Terminal" },
      { "<leader>tx", desc = "󰈈 Toggle cursor follow (lock/unlock)" },
      { "<leader>tL", desc = "󰌾 Lock cursor (disable auto-scroll)" },
      { "<leader>tU", desc = "󰚰 Unlock cursor (enable auto-scroll)" },
      { "<leader>tD", desc = "󰃤 Debug terminal cursor state" },

      -- Basic toggle terminal (moved to Cmd+`)
      { "<D-`>", desc = "󰆍 Toggle terminal" },

      -- Tab/Workspace management
      { "<leader>w", group = "Workspace/Tabs" },
      { "<leader>wo", desc = "󰓩 Open new tab" },
      { "<leader>wx", desc = "󰅖 Close current tab" },
      { "<leader>wn", desc = "󰒭 Go to next tab" },
      { "<leader>wp", desc = "󰒮 Go to previous tab" },
      { "<leader>wf", desc = "󰏫 Open current buffer in new tab" },

      -- Harpoon (original configuration)
      { "<leader>1", desc = "󰼏 Navigate to harpoon 1" },
      { "<leader>2", desc = "󰼐 Navigate to harpoon 2" },
      { "<leader>3", desc = "󰼑 Navigate to harpoon 3" },
      { "<leader>4", desc = "󰼒 Navigate to harpoon 4" },
      { "<leader>5", desc = "󰼓 Navigate to harpoon 5" },
    })
  end
end, 100)

-- Terminal cursor control for live logs (avoiding conflict with <leader>tl for logs focus)
map("n", "<leader>tx", function() terminals.toggle_follow_output() end, { desc = "Toggle cursor follow (lock/unlock)" })
map("n", "<leader>tL", function() terminals.lock_cursor() end, { desc = "Lock cursor (disable auto-scroll)" })
map("n", "<leader>tU", function() terminals.unlock_cursor() end, { desc = "Unlock cursor (enable auto-scroll)" })

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

-- Configure word boundaries to treat hyphens as separators
vim.opt.iskeyword:remove("-")

-- Smart buffer deletion with confirmation for modified buffers
local function smart_buffer_delete()
  local current_buf = vim.api.nvim_get_current_buf()

  -- Check if buffer is valid and loaded
  if not vim.api.nvim_buf_is_valid(current_buf) or not vim.api.nvim_buf_is_loaded(current_buf) then
    return
  end

  local modified = vim.api.nvim_buf_get_option(current_buf, 'modified')
  local bufname = vim.api.nvim_buf_get_name(current_buf)
  local filename = vim.fn.fnamemodify(bufname, ':t')

  if filename == '' then
    filename = '[No Name]'
  end

  if modified then
    local choice = vim.fn.confirm(
      'Buffer "' .. filename .. '" has unsaved changes. Save before closing?',
      '&Save and close\n&Discard changes\n&Cancel',
      1
    )

    if choice == 1 then
      -- Save and close - use pcall to handle any formatting errors gracefully
      local ok, err = pcall(function()
        vim.cmd('write')
      end)
      if ok then
        vim.cmd('bdelete')
      else
        vim.notify('Error saving file: ' .. tostring(err), vim.log.levels.ERROR)
      end
    elseif choice == 2 then
      -- Discard changes and close
      vim.cmd('bdelete!')
    end
    -- choice == 3 or 0 means cancel, do nothing
  else
    -- Buffer not modified, safe to delete
    vim.cmd('bdelete')
  end
end

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

-- Map the smart buffer delete function to <leader>bd
map("n", "<D-w>", smart_buffer_delete, { desc = "Close buffer (with confirmation if modified)", noremap = true, silent = true })
map("n", "<leader>bd", smart_buffer_delete, { desc = "Smart delete buffer", silent = true })
map({ "n", "i", "v" }, "<D-S-s>", save_all_modified, { desc = "Save all modified buffers", noremap = true, silent = true })

-- Background mode selector keymap
map("n", "<leader>tt", function()
	_G.telescope_background_picker()
end, { desc = "🎨 Select background mode", silent = true })



-- Indentation management keymaps (spaces over tabs best practices)
-- Show invisible characters (spaces, tabs, line endings)
map("n", "<leader>ci", function()
  -- Toggle visual-whitespace for better visual mode support
  local ok, visual_whitespace = pcall(require, "visual-whitespace")
  if ok then
    visual_whitespace.toggle()
  else
    -- Fallback to basic list toggle if plugin not available
    if vim.wo.list then
      vim.wo.list = false
      vim.notify("Hidden invisible characters", vim.log.levels.INFO)
    else
      vim.wo.list = true
      vim.notify("Showing invisible characters", vim.log.levels.INFO)
    end
  end
end, { desc = "Toggle invisible characters" })

-- Visual whitespace toggle alternative keymap
map({ 'n', 'v' }, "<leader>vw", function()
  local ok, visual_whitespace = pcall(require, "visual-whitespace")
  if ok then
    visual_whitespace.toggle()
    vim.notify("Visual whitespace toggled", vim.log.levels.INFO)
  else
    vim.notify("Visual whitespace plugin not loaded", vim.log.levels.WARN)
  end
end, { desc = "Toggle visual whitespace visibility" })

-- Quick indentation adjustment
map("n", "<leader>c2", function()
  vim.bo.tabstop = 2
  vim.bo.softtabstop = 2
  vim.bo.shiftwidth = 2
  vim.bo.expandtab = true
  vim.cmd("retab")
  vim.notify("Set indentation to 2 spaces", vim.log.levels.INFO)
end, { desc = "Set 2-space indentation" })

map("n", "<leader>c4", function()
  vim.bo.tabstop = 4
  vim.bo.softtabstop = 4
  vim.bo.shiftwidth = 4
  vim.bo.expandtab = true
  vim.cmd("retab")
  vim.notify("Set indentation to 4 spaces", vim.log.levels.INFO)
end, { desc = "Set 4-space indentation" })

-- Code Runner - Run code snippets and files
map("n", "<leader>sr", "<cmd>RunCode<CR>", { desc = "Run code in current buffer" })
map("v", "<leader>sr", "<cmd>RunCode<CR>", { desc = "Run selected code" })

-- Notification filtering toggle
map("n", "<leader>un", function()
  _G.toggle_notification_filter()
end, { desc = "Toggle notification filter (errors only)" })
-- Normal mode: ⌘+/ (comment line and move down)
map("n", "<D-/>", function()
	require("Comment.api").toggle.linewise.current()
	vim.cmd("normal! j") -- move down a line
end, { silent = true, desc = "Toggle comment line and move down" })

map("v", "<D-/>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { silent = true, desc = "Toggle comment (visual)" })