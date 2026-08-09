local M = {
  severity_state = {
    [vim.diagnostic.severity.ERROR] = true,
    [vim.diagnostic.severity.WARN] = false,
    [vim.diagnostic.severity.INFO] = false,
    [vim.diagnostic.severity.HINT] = false,
  },
}

M.sign_icons = {
  [vim.diagnostic.severity.ERROR] = " ",
  [vim.diagnostic.severity.WARN] = " ",
  [vim.diagnostic.severity.INFO] = " ",
  [vim.diagnostic.severity.HINT] = " ",
}

function M.virtual_text_format(diagnostic)
  local source = diagnostic.source and (" [" .. diagnostic.source .. "]") or ""
  return string.format("%s %s%s", "", diagnostic.message, source)
end

function M.float_format(diagnostic)
  local severity_map = {
    [vim.diagnostic.severity.ERROR] = "ERROR",
    [vim.diagnostic.severity.WARN] = "WARN",
    [vim.diagnostic.severity.INFO] = "INFO",
    [vim.diagnostic.severity.HINT] = "HINT",
  }
  local severity = severity_map[diagnostic.severity] or "UNKNOWN"
  local code = diagnostic.code and string.format(" [%s]", diagnostic.code) or ""
  return string.format("%s: %s%s", severity, diagnostic.message, code)
end

function M.configure_defaults()
  vim.diagnostic.config({
    virtual_text = {
      severity = { min = vim.diagnostic.severity.ERROR },
      spacing = 4,
      prefix = "●",
      format = M.virtual_text_format,
    },
    signs = {
      severity = { min = vim.diagnostic.severity.ERROR },
      text = M.sign_icons,
    },
    underline = false,
    update_in_insert = false,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
      format = M.float_format,
    },
  })
end

function M.active_severities()
  local severities = {}
  for severity, active in pairs(M.severity_state) do
    if active then
      table.insert(severities, severity)
    end
  end
  return severities
end

function M.apply_severity_visibility()
  local active = M.active_severities()
  if #active == 0 then
    vim.diagnostic.config({ virtual_text = false, signs = false })
  else
    vim.diagnostic.config({
      virtual_text = {
        severity = active,
        spacing = 4,
        prefix = "●",
        format = M.virtual_text_format,
      },
      signs = { severity = active, text = M.sign_icons },
    })
  end
end

function M.reset_severity_defaults()
  M.severity_state = {
    [vim.diagnostic.severity.ERROR] = true,
    [vim.diagnostic.severity.WARN] = false,
    [vim.diagnostic.severity.INFO] = false,
    [vim.diagnostic.severity.HINT] = false,
  }
  M.apply_severity_visibility()
end

return M
