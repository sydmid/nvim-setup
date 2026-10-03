return {
  "seblyng/roslyn.nvim",
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = function()
    return {
      exe = "roslyn",
      config = {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        filetypes = { "cs", "razor" },
        settings = {
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles",
          },
        },
      },
    }
  end,
}
