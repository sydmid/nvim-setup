local M = {}

function M.format(self, content, range)
  -- Simple indentation logic for zsh files
  local lines = vim.split(content, "\n")
  local indented = {}
  local indent_level = 0
  local indent_size = 2

  for _, line in ipairs(lines) do
    local trimmed = vim.trim(line)

    -- Check for closing markers to decrease indent first
    if
      trimmed:match("^fi$")
      or trimmed:match("^done$")
      or trimmed:match("^}$")
      or trimmed:match("^esac$")
      or trimmed:match("^%)$")
    then
      indent_level = math.max(0, indent_level - 1)
    end

    -- Add appropriate indent
    local indent = string.rep(" ", indent_level * indent_size)
    table.insert(indented, indent .. trimmed)

    -- Check for opening markers to increase indent
    if
      trimmed:match("^if ")
      or trimmed:match("then$")
      or trimmed:match("^for ")
      or trimmed:match("do$")
      or trimmed:match("^while ")
      or trimmed:match("^{$")
      or trimmed:match("^case ")
      or trimmed:match("^function ")
      or trimmed:match("%([ ]*%)[ ]*{[ ]*$")
    then
      indent_level = indent_level + 1
    end
  end

  return table.concat(indented, "\n")
end

return M
