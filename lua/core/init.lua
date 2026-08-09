-- Stable startup boundary for the refactored configuration.
-- Migrate one module at a time from lua/config into lua/core, then update init.lua.
local M = {}

function M.setup()
  require("core.options").setup()
  require("core.commands").setup()
  require("core.keymaps").setup()
  require("core.autocmds").setup()
end

return M
