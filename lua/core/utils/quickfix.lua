local M = {}

--- Shortens path segments for compact display in quickfix
---@param path string
---@return string
local function shorten_path(path)
  if not path or path == "" then
    return ""
  end

  local sep = package.config:sub(1, 1)
  local parts = vim.split(path, sep, { trimempty = true })
  if #parts <= 1 then
    return path
  end

  local shortened = {}
  for i, part in ipairs(parts) do
    if i == 1 or i == #parts then
      table.insert(shortened, part)
    elseif part:sub(1, 1) == "." then
      table.insert(shortened, part:sub(1, 2))
    else
      table.insert(shortened, part:sub(1, 1))
    end
  end

  return table.concat(shortened, sep)
end

--- Custom quickfix text formatting function
---@param info table Quickfix text function parameter from Neovim
---@return string[]
function M.quickfixtextfunc(info)
  local items
  if info.quickfix == 1 then
    items = vim.fn.getqflist({ id = info.id, items = 0 }).items
  else
    items = vim.fn.getloclist(info.winid, { id = info.id, items = 0 }).items
  end

  local lines = {}
  for i = info.start_idx, info.end_idx do
    local item = items[i]
    if not item then
      table.insert(lines, "")
    else
      local buf = item.bufnr
      local filename = ""
      if buf > 0 and vim.api.nvim_buf_is_valid(buf) then
        filename = vim.api.nvim_buf_get_name(buf)
        if filename ~= "" then
          filename = vim.fn.fnamemodify(filename, ":~:.")
        end
      end

      if filename == "" and item.user_data then
        filename = tostring(item.user_data)
      end

      local short_name = shorten_path(filename)
      local lnum = item.lnum or 0
      local col = item.col or 0
      local text = item.text or ""

      local line = string.format("%s|%d col %d| %s", short_name, lnum, col, text)
      table.insert(lines, line)
    end
  end

  return lines
end

return M
