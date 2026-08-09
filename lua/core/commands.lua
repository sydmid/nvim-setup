local M = {}

function M.setup()
  if vim.fn.exists(":W") ~= 2 then
    vim.api.nvim_create_user_command("W", "write", {})
  end
end

return M
