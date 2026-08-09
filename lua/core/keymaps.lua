local M = {}

function M.setup()
  require("core.keymaps.general").setup()
  require("core.keymaps.buffers").setup()
  require("core.keymaps.search").setup()
  require("core.keymaps.windows").setup()
  require("core.keymaps.files").setup()
end

return M
