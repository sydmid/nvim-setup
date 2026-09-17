local M = {}

function M.parse(output, _)
  local diagnostics = {}

  -- If no ESLint config found, just return empty diagnostics silently
  if output:find("No ESLint configuration found") then
    return diagnostics
  end

  -- Continue with normal parsing for valid ESLint output
  if output and output ~= "" then
    local decoded = vim.json.decode(output)
    if decoded and decoded[1] then
      local filepath = vim.api.nvim_buf_get_name(0)
      for _, item in ipairs(decoded) do
        if item.filePath == filepath then
          for _, message in ipairs(item.messages) do
            table.insert(diagnostics, {
              lnum = message.line - 1,
              end_lnum = message.endLine and (message.endLine - 1) or nil,
              col = message.column - 1,
              end_col = message.endColumn and (message.endColumn - 1) or nil,
              severity = message.severity == 2 and vim.diagnostic.severity.ERROR
                or message.severity == 1 and vim.diagnostic.severity.WARN
                or vim.diagnostic.severity.INFO,
              message = message.message,
              code = message.ruleId,
              source = "eslint",
            })
          end
        end
      end
    end
  end

  return diagnostics
end

return M
