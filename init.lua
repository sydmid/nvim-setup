-- Core startup must run before lazy.nvim so leaders and defaults are ready.
require("core").setup()
require("config.lazy")
