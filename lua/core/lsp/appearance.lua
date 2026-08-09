local M = {}

M.retro_border = {
  { "┌", "LspFloatRetro" },
  { "─", "LspFloatRetro" },
  { "┐", "LspFloatRetro" },
  { "│", "LspFloatRetro" },
  { "┘", "LspFloatRetro" },
  { "─", "LspFloatRetro" },
  { "└", "LspFloatRetro" },
  { "│", "LspFloatRetro" },
}

function M.apply_highlights()
  vim.api.nvim_set_hl(0, "LspFloatRetro", { fg = "#7aa89f", bold = true })
end

function M.setup_colorscheme_hook()
  M.apply_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = M.apply_highlights })
end

return M
