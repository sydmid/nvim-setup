local M = {}

M.config = {
  steps = 8,
  interval = 80,
  enabled = true,
}

local timer = nil
local ns = vim.api.nvim_create_namespace("beacon_indicator")

--- Trigger cursor beacon visual indicator
---@param win? integer
function M.start(win)
  if not M.config.enabled then
    return
  end

  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(win)
  local line_idx = cursor[1] - 1
  local col_idx = cursor[2]

  local line_text = (vim.api.nvim_buf_get_lines(buf, line_idx, line_idx + 1, false) or {})[1] or ""

  -- Clear previous beacon extmarks
  pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)

  local fg_hl = vim.api.nvim_get_hl(0, { name = "Function", link = false }).fg
    or vim.api.nvim_get_hl(0, { name = "Cursor", link = false }).fg
    or 13749703

  local bg_hl = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false }).bg
    or vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
    or 2039582

  local function hex(val)
    if type(val) == "number" then
      return string.format("#%06x", val)
    end
    return "#89b4fa"
  end

  local from_hex = hex(fg_hl)
  local to_hex = hex(bg_hl)

  local from_r = tonumber(from_hex:sub(2, 3), 16) or 137
  local from_g = tonumber(from_hex:sub(4, 5), 16) or 180
  local from_b = tonumber(from_hex:sub(6, 7), 16) or 250

  local to_r = tonumber(to_hex:sub(2, 3), 16) or 30
  local to_g = tonumber(to_hex:sub(4, 5), 16) or 30
  local to_b = tonumber(to_hex:sub(6, 7), 16) or 46

  local current_step = 0

  if timer then
    timer:stop()
    if not timer:is_closing() then
      timer:close()
    end
    timer = nil
  end

  timer = (vim.uv or vim.loop).new_timer()
  if not timer then
    return
  end

  timer:start(
    0,
    M.config.interval,
    vim.schedule_wrap(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        if timer then
          timer:stop()
          timer:close()
          timer = nil
        end
        return
      end

      if current_step >= M.config.steps then
        pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)
        if timer then
          timer:stop()
          timer:close()
          timer = nil
        end
        return
      end

      local ratio = current_step / (M.config.steps - 1)
      local r = math.floor(from_r + (to_r - from_r) * ratio)
      local g = math.floor(from_g + (to_g - from_g) * ratio)
      local b = math.floor(from_b + (to_b - from_b) * ratio)
      local hl_color = string.format("#%02x%02x%02x", r, g, b)

      local group_name = string.format("BeaconStep%d", current_step)
      vim.api.nvim_set_hl(0, group_name, { bg = hl_color, default = false })

      pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)

      -- Add extmark around cursor
      local start_col = math.max(0, col_idx)
      local end_col = math.min(#line_text, col_idx + 1)
      if start_col == end_col then
        end_col = start_col + 1
      end

      pcall(vim.api.nvim_buf_set_extmark, buf, ns, line_idx, start_col, {
        end_col = end_col,
        hl_group = group_name,
        priority = 200,
      })

      current_step = current_step + 1
    end)
  )
end

function M.toggle()
  M.config.enabled = not M.config.enabled
  vim.notify("Beacon " .. (M.config.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
end

return M
