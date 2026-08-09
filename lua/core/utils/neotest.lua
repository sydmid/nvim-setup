local M = {
  adapters = {},
  opts = {},
}

local function merge_opts(opts)
  if not opts then
    return
  end

  -- Keep existing nested settings when another language registers later.
  M.opts = vim.tbl_deep_extend("keep", M.opts, opts)
end

function M.register_adapter(name, adapter, opts)
  M.adapters[name] = adapter
  merge_opts(opts)

  local neotest = require("neotest")
  local adapter_list = {}
  for _, registered_adapter in pairs(M.adapters) do
    table.insert(adapter_list, registered_adapter)
  end

  neotest.setup(vim.tbl_deep_extend("force", M.opts, {
    adapters = adapter_list,
  }))
end

return M
