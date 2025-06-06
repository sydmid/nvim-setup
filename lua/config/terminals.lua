-- Terminal management for multiple services
-- Provides functionality to run multiple services in separate terminal buffers
-- and switch between them easily

local M = {}

-- Store terminal buffers and their metadata
local terminals = {}

-- Configuration
local config = {
  terminal_size = 20,
  direction = "float", -- can be "horizontal", "vertical", "float", or "tab"
  float_opts = {
    border = "curved",
    winblend = 0,
    highlights = {
      border = "Normal",
      background = "Normal",
    },
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    row = math.floor(vim.o.lines * 0.1),
    col = math.floor(vim.o.columns * 0.1),
  },
}

-- Service definitions with proper names and icons
local service_configs = {
  web = { name = "Web Server", icon = "🌐", desc = "Frontend development server" },
  api = { name = "API Server", icon = "🔗", desc = "Backend API service" },
  database = { name = "Database", icon = "🗃️", desc = "Database service" },
  worker = { name = "Worker", icon = "⚙️", desc = "Background worker" },
  test = { name = "Tests", icon = "🧪", desc = "Test runner" },
  build = { name = "Build", icon = "🔨", desc = "Build system" },
  dev = { name = "Dev Server", icon = "💻", desc = "Development server" },
  logs = { name = "Logs", icon = "📋", desc = "Application logs" },
  monitor = { name = "Monitor", icon = "📊", desc = "System monitor" },
  default = { name = "Terminal", icon = "🧰", desc = "Default terminal" },
}

-- Get unique terminal ID based on name
local function get_terminal_id_for_name(name)
  -- Create a hash-like ID based on the name to ensure uniqueness
  local id = 0
  for i = 1, #name do
    id = id + string.byte(name, i)
  end
  -- Add a base offset to avoid conflicts with other terminal IDs
  return 1000 + (id % 8999) -- Range: 1000-9999
end

-- Run a command in a named terminal
function M.run_in_terminal(name, cmd, opts)
  opts = opts or {}

  -- If terminal already exists, close it first
  if terminals[name] then
    M.close_terminal(name)
  end

  local Terminal = require("toggleterm.terminal").Terminal
  local term_id = get_terminal_id_for_name(name)

  -- Get service configuration or use defaults
  local service_config = service_configs[name] or service_configs.default
  local display_name = service_config.icon .. " " .. service_config.name
  local window_title = display_name .. " (" .. cmd .. ")"

  local term = Terminal:new({
    id = term_id,
    cmd = cmd,
    direction = opts.direction or config.direction,
    size = opts.size or config.terminal_size,
    float_opts = opts.float_opts or config.float_opts,
    display_name = display_name,
    close_on_exit = false,
    on_open = function(term)
      vim.cmd("startinsert!")

      -- Set terminal buffer name for identification
      local buffer_name = "Terminal: " .. service_config.name
      vim.api.nvim_buf_set_name(term.bufnr, buffer_name)

      -- Set window title
      if vim.fn.has('nvim-0.10') == 1 then
        vim.api.nvim_buf_set_var(term.bufnr, "term_title", window_title)
      end

      -- Set up terminal buffer-specific settings
      vim.api.nvim_buf_set_option(term.bufnr, "scrolloff", 0)

      -- Disable ToggleTerm's auto-scroll behavior
      vim.api.nvim_buf_set_option(term.bufnr, "scrollback", -1)

      -- Variable to track if cursor should follow output (locked/unlocked)
      vim.b[term.bufnr].terminal_follow_output = true

      -- Store the last known cursor position for locked mode
      vim.b[term.bufnr].locked_cursor_pos = nil

      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})

      -- Add Esc to exit terminal mode and auto-lock cursor for examination
      vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>",
        "<C-\\><C-n>:lua require('config.terminals').auto_lock_for_examination(" .. term.bufnr .. ")<CR>",
        {noremap = true, silent = true, desc = "Exit terminal mode and lock for examination"})

      -- Add key to toggle cursor following (lock/unlock scrolling)
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<leader>tl",
        ":lua require('config.terminals').toggle_follow_output(" .. term.bufnr .. ")<CR>",
        {noremap = true, silent = true, desc = "Toggle follow output"})

      -- Add key to jump to end and re-enable following
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "G",
        "G:lua require('config.terminals').unlock_cursor_and_follow(" .. term.bufnr .. ")<CR>",
        {noremap = true, silent = true, desc = "Go to end and unlock cursor"})

      -- Add terminal mode keymap for toggle functionality
      vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<D-`>",
        "<C-\\><C-n>:lua require('config.terminals').toggle_terminal('" .. name .. "')<CR>",
        {noremap = true, silent = true})

      -- Also add normal mode keymap for when user switches to normal mode
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<D-`>",
        ":lua require('config.terminals').toggle_terminal('" .. name .. "')<CR>",
        {noremap = true, silent = true})

      -- Set up autocmd to handle terminal output and cursor behavior
      local augroup = vim.api.nvim_create_augroup("TerminalCursorControl_" .. term.bufnr, { clear = true })

      -- Handle terminal content changes (when new lines are added)
      -- Only auto-scroll when in terminal mode, not when user is navigating in normal mode
      vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
        group = augroup,
        buffer = term.bufnr,
        callback = function()
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(term.bufnr) then return end

            local win = vim.fn.bufwinid(term.bufnr)
            if win == -1 then return end

            -- Only handle if current window is the terminal window
            if vim.api.nvim_get_current_win() ~= win then return end

            -- Check current mode - only auto-scroll in terminal mode
            local mode = vim.api.nvim_get_mode().mode
            if mode == "t" then
              -- In terminal mode: always follow output (user is typing commands)
              local line_count = vim.api.nvim_buf_line_count(term.bufnr)
              vim.api.nvim_win_set_cursor(win, {line_count, 0})
            end
            -- In normal mode: never auto-scroll, let user navigate freely
          end)
        end,
      })
    end,
    on_close = function()
      terminals[name] = nil
    end,
  })

  terminals[name] = {
    terminal = term,
    id = term_id,
    cmd = cmd,
    name = name,
    bufnr = nil, -- Will be set when terminal is opened
  }

  term:open()

  -- Store the buffer number after opening
  vim.defer_fn(function()
    if term and term.bufnr and terminals[name] then
      terminals[name].bufnr = term.bufnr
    end
  end, 100) -- Small delay to ensure buffer is created

  return term
end

-- Focus on a specific terminal by name
function M.focus_terminal(name)
  if not terminals[name] then
    vim.notify("Terminal '" .. name .. "' not found. Run it first.", vim.log.levels.WARN)
    return false
  end

  local term_data = terminals[name]
  if term_data.terminal then
    -- If terminal is not open, open it
    if not term_data.terminal:is_open() then
      term_data.terminal:open()
    else
      -- If already open, just focus on it
      term_data.terminal:focus()
    end

    -- Always enter insert mode after focusing
    vim.defer_fn(function()
      if term_data.bufnr and vim.api.nvim_get_current_buf() == term_data.bufnr then
        vim.cmd("startinsert!")
      end
    end, 50) -- Small delay to ensure focus is complete

    return true
  end

  return false
end

-- Close a specific terminal
function M.close_terminal(name)
  if terminals[name] then
    if terminals[name].terminal then
      terminals[name].terminal:close()
    end
    terminals[name] = nil
    return true
  end
  return false
end

-- Toggle a terminal (open if closed, close if open)
function M.toggle_terminal(name)
  if not terminals[name] then
    vim.notify("Terminal '" .. name .. "' not found. Run it first.", vim.log.levels.WARN)
    return false
  end

  local term_data = terminals[name]
  if term_data.terminal then
    local was_open = term_data.terminal:is_open()
    term_data.terminal:toggle()

    -- If terminal was closed and is now open, enter insert mode
    if not was_open and term_data.terminal:is_open() then
      vim.defer_fn(function()
        if vim.api.nvim_get_current_buf() == term_data.bufnr then
          vim.cmd("startinsert!")
        end
      end, 50) -- Small delay to ensure terminal is fully opened
    end

    return true
  end

  return false
end

-- Toggle or create a terminal (create if doesn't exist, toggle if exists)
function M.toggle_or_create_terminal(name, cmd, opts)
  if terminals[name] then
    -- Terminal exists, toggle it
    return M.toggle_terminal(name)
  else
    -- Terminal doesn't exist, create it
    return M.run_in_terminal(name, cmd, opts)
  end
end

-- List all active terminals
function M.list_terminals()
  local active_terminals = {}
  for name, term_data in pairs(terminals) do
    table.insert(active_terminals, {
      name = name,
      cmd = term_data.cmd,
      id = term_data.id,
      bufnr = term_data.bufnr,
      is_open = term_data.terminal and term_data.terminal:is_open() or false,
    })
  end
  return active_terminals
end

-- Show terminal picker using Telescope
function M.terminal_picker()
  local active_terminals = M.list_terminals()

  if #active_terminals == 0 then
    vim.notify("No active terminals found.", vim.log.levels.INFO)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "󰆍 Active Terminals",
    finder = finders.new_table({
      results = active_terminals,
      entry_maker = function(entry)
        local status = entry.is_open and "󰐊 " or "󰚭 "
        local service_config = service_configs[entry.name] or service_configs.default
        local display_name = service_config.icon .. " " .. service_config.name
        return {
          value = entry,
          display = string.format("%s%s (%s)", status, display_name, entry.cmd),
          ordinal = entry.name .. " " .. entry.cmd .. " " .. service_config.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          M.focus_terminal(selection.value.name)
        end
      end)

      -- Map 'd' to close terminal
      map("i", "<C-d>", function()
        local selection = action_state.get_selected_entry()
        if selection then
          M.close_terminal(selection.value.name)
          -- Refresh the picker
          local current_picker = action_state.get_current_picker(prompt_bufnr)
          current_picker:refresh(finders.new_table({
            results = M.list_terminals(),
            entry_maker = function(entry)
              local status = entry.is_open and "󰐊 " or "󰚭 "
              return {
                value = entry,
                display = string.format("%s%s (%s)", status, entry.name, entry.cmd),
                ordinal = entry.name .. " " .. entry.cmd,
              }
            end,
          }), { reset_prompt = true })
        end
      end)

      return true
    end,
  }):find()
end

-- Cycle through terminals
function M.cycle_terminals(direction)
  local active_terminals = M.list_terminals()
  if #active_terminals == 0 then
    vim.notify("No active terminals found.", vim.log.levels.INFO)
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local current_terminal = nil
  local current_index = 1

  -- Find current terminal
  for i, term_data in ipairs(active_terminals) do
    if terminals[term_data.name] and terminals[term_data.name].bufnr == current_buf then
      current_terminal = term_data.name
      current_index = i
      break
    end
  end

  -- Calculate next index
  local next_index
  if direction == "next" then
    next_index = current_index % #active_terminals + 1
  else -- previous
    next_index = current_index == 1 and #active_terminals or current_index - 1
  end

  local next_terminal = active_terminals[next_index]
  M.focus_terminal(next_terminal.name)
end

-- Kill all terminals
function M.kill_all_terminals()
  local count = 0
  for name, _ in pairs(terminals) do
    M.close_terminal(name)
    count = count + 1
  end
  vim.notify(string.format("Closed %d terminals.", count), vim.log.levels.INFO)
end

-- Restart a terminal with the same command
function M.restart_terminal(name)
  if not terminals[name] then
    vim.notify("Terminal '" .. name .. "' not found.", vim.log.levels.WARN)
    return false
  end

  local cmd = terminals[name].cmd
  M.close_terminal(name)
  vim.defer_fn(function()
    M.run_in_terminal(name, cmd)
  end, 100) -- Small delay to ensure cleanup

  return true
end

-- Auto-lock cursor when exiting terminal mode for examination
function M.auto_lock_for_examination(bufnr)
  if not bufnr then
    bufnr = vim.api.nvim_get_current_buf()
  end

  -- Lock cursor at current position so user can navigate freely
  local win = vim.fn.bufwinid(bufnr)
  if win ~= -1 then
    local cursor_pos = vim.api.nvim_win_get_cursor(win)
    vim.b[bufnr].locked_cursor_pos = cursor_pos
    vim.b[bufnr].terminal_follow_output = false
    -- Silent operation - no notification since this happens automatically
  end
end

-- Lock cursor at current position (disable auto-scroll on new output)
function M.lock_cursor_at_position(bufnr)
  if not bufnr then
    bufnr = vim.api.nvim_get_current_buf()
  end

  -- Get current cursor position
  local win = vim.fn.bufwinid(bufnr)
  if win ~= -1 then
    local cursor_pos = vim.api.nvim_win_get_cursor(win)
    vim.b[bufnr].locked_cursor_pos = cursor_pos
    vim.b[bufnr].terminal_follow_output = false
    vim.notify("Auto-scroll disabled. Terminal will not jump to new output. Use G to re-enable.", vim.log.levels.INFO)
  end
end

-- Unlock cursor and jump to end (used with G command)
function M.unlock_cursor_and_follow(bufnr)
  if not bufnr then
    bufnr = vim.api.nvim_get_current_buf()
  end

  vim.b[bufnr].terminal_follow_output = true
  vim.b[bufnr].locked_cursor_pos = nil

  -- Jump to end
  local win = vim.fn.bufwinid(bufnr)
  if win ~= -1 then
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_win_set_cursor(win, {line_count, 0})
  end

  vim.notify("Cursor unlocked, following output", vim.log.levels.INFO)
end

-- Enhanced toggle follow output with position tracking
function M.toggle_follow_output(bufnr)
  if not bufnr then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local current_state = vim.b[bufnr].terminal_follow_output

  if current_state then
    -- Switching to locked mode - save current position
    M.lock_cursor_at_position(bufnr)
  else
    -- Switching to follow mode - clear locked position and jump to end
    M.unlock_cursor_and_follow(bufnr)
  end
end

-- Check if current buffer is following output
function M.is_following_output(bufnr)
  if not bufnr then
    bufnr = vim.api.nvim_get_current_buf()
  end
  return vim.b[bufnr].terminal_follow_output == true
end

-- Lock cursor position (disable auto-scroll)
function M.lock_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  M.lock_cursor_at_position(bufnr)
end

-- Unlock cursor position (enable auto-scroll)
function M.unlock_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  M.unlock_cursor_and_follow(bufnr)
end

-- Debug function to check terminal cursor state
function M.debug_cursor_state()
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  print("=== Terminal Cursor Debug ===")
  print("Buffer:", bufnr)
  print("Window:", win)
  print("Buffer type:", vim.bo[bufnr].buftype)
  print("Following output:", vim.b[bufnr].terminal_follow_output)
  print("Locked position:", vim.inspect(vim.b[bufnr].locked_cursor_pos))

  local cursor_pos = vim.api.nvim_win_get_cursor(win)
  print("Current cursor:", cursor_pos[1], cursor_pos[2])
  print("Buffer lines:", vim.api.nvim_buf_line_count(bufnr))
  print("Window valid:", vim.api.nvim_win_is_valid(win))
  print("========================")
end

-- Setup function for configuration
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

return M
