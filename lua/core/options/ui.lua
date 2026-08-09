local M = {}

function M.setup()
  -- File explorers that replace netrw should disable it before plugin startup.
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
end

return M
