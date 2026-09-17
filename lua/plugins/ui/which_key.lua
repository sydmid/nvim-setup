return {
  -- Mini.icons for better which-key icon support
  {
    "echasnovski/mini.icons",
    version = false,
    config = true,
  },
  -- Show keys
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
    end,
    config = function()
      local wk = require("which-key")

      wk.setup({
        plugins = {
          marks = true,
          registers = true,
          presets = {
            operators = false,
            motions = false,
            text_objects = false,
            windows = false,
            nav = false,
            z = false,
            g = false,
          },
        },
        icons = {
          breadcrumb = "»",
          separator = "|",
          group = "+",
        },
        layout = {
          height = { min = 4, max = 25 },
          width = { min = 20, max = 50 },
          spacing = 3,
          -- align = "center",
        },
        show_help = false,
      })

      -- Register all the key groups
      wk.add({
        -- AI/Avante group with streamlined commands
        { "<leader>a", group = "AI" },
        { "<leader>ai", desc = "Ask input" },
        { "<leader>af", desc = "Focus chat" },
        { "<leader>al", desc = "Clear chat" },
        -- Native Avante history features
        { "<leader>ah", desc = "Avante history" },
        { "[a", desc = "Chat history selector" },
        { "]a", desc = "Chat history selector" },
        -- Code assistance (visual mode)
        { "<leader>ae", desc = "Explain code" },
        { "<leader>at", desc = "Generate tests" },
        { "<leader>ar", desc = "Review code" },
        { "<leader>ad", desc = "Add docs" },
        { "<leader>ao", desc = "Optimize code" },
        -- Git integration
        { "<leader>ac", desc = "Commit message" },
        -- Other groups
        { "<leader>d", group = "Debug" },
        { "<leader>e", group = "Error Lens/Explorer" },
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Context/Code-Actions" },
        { "<leader>f", group = "File/Find" },
        { "<leader>g", group = "Git/Goto" },
        { "<leader>gc", group = "Conflicts" },
        { "<leader>h", group = "Hunks/Git-Stage" },
        { "<leader>j", group = "Jump" },
        { "<leader>k", group = "Jump/Flash" },
        { "<leader>l", group = "LSP" },
        { "<leader>p", group = "Peek/Preview" },
        { "<leader>r", group = "Rename/Refactor" },
        { "<leader>s", group = "Snacks" },
        { "<leader>t", group = "Toggles" },
        { "<leader>u", group = "Test/Utils" },
        { "<leader>v", group = "Visual/View" },
        { "<leader>x", group = "Diagnostics/Trouble" },
        { "<leader>z", group = "Fold" },
      })
    end,
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show()
        end,
        desc = "Show keymaps",
      },
    },
  },
}
