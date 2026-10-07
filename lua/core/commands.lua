local M = {}

function M.setup()
  if vim.fn.exists(":W") ~= 2 then
    vim.api.nvim_create_user_command("W", "write", {})
  end

  vim.api.nvim_create_user_command("Beacon", function(opts)
    local beacon = require("core.utils.beacon")
    local arg = opts.args
    if arg == "toggle" then
      beacon.toggle()
    else
      beacon.start()
    end
  end, {
    nargs = "?",
    desc = "Trigger or toggle cursor position beacon visual indicator",
  })
end

return M
