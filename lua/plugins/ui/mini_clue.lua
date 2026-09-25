return {
  -- Mini.icons
  {
    "echasnovski/mini.icons",
    version = false,
    config = true,
  },
  -- Show keys
  {
    "echasnovski/mini.clue",
    version = false,
    event = "VeryLazy",
    config = function()
      local miniclue = require("mini.clue")
      miniclue.setup({
        triggers = {
          -- Leader triggers
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },

          -- Built-in completion
          { mode = "i", keys = "<C-x>" },

          -- `g` key
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },

          -- Marks
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },

          -- Registers
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },

          -- Window commands
          { mode = "n", keys = "<C-w>" },

          -- `z` key
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },

          -- `[` and `]` key
          { mode = "n", keys = "[" },
          { mode = "n", keys = "]" },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),

          -- AI/Avante group with streamlined commands
          { mode = "n", keys = "<leader>a", desc = "+AI" },
          { mode = "n", keys = "<leader>ai", desc = "Ask input" },
          { mode = "n", keys = "<leader>af", desc = "Focus chat" },
          { mode = "n", keys = "<leader>al", desc = "Clear chat" },
          -- Native Avante history features
          { mode = "n", keys = "<leader>ah", desc = "Avante history" },
          { mode = "n", keys = "[a", desc = "Chat history selector" },
          { mode = "n", keys = "]a", desc = "Chat history selector" },
          -- Code assistance (visual mode)
          { mode = "n", keys = "<leader>ae", desc = "Explain code" },
          { mode = "n", keys = "<leader>at", desc = "Generate tests" },
          { mode = "n", keys = "<leader>ar", desc = "Review code" },
          { mode = "n", keys = "<leader>ad", desc = "Add docs" },
          { mode = "n", keys = "<leader>ao", desc = "Optimize code" },
          -- Git integration
          { mode = "n", keys = "<leader>ac", desc = "Commit message" },
          -- Other groups
          { mode = "n", keys = "<leader>d", desc = "+Debug" },
          { mode = "n", keys = "<leader>e", desc = "+Error Lens/Explorer" },
          { mode = "n", keys = "<leader>b", desc = "+Buffer" },
          { mode = "n", keys = "<leader>c", desc = "+Context/Code-Actions" },
          { mode = "n", keys = "<leader>f", desc = "+File/Find" },
          { mode = "n", keys = "<leader>g", desc = "+Git/Goto" },
          { mode = "n", keys = "<leader>gc", desc = "+Conflicts" },
          { mode = "n", keys = "<leader>h", desc = "+Hunks/Git-Stage" },
          { mode = "n", keys = "<leader>j", desc = "+Jump" },
          { mode = "n", keys = "<leader>k", desc = "+Jump/Flash" },
          { mode = "n", keys = "<leader>l", desc = "+LSP" },
          { mode = "n", keys = "<leader>p", desc = "+Peek/Preview" },
          { mode = "n", keys = "<leader>r", desc = "+Rename/Refactor" },
          { mode = "n", keys = "<leader>s", desc = "+Snacks" },
          { mode = "n", keys = "<leader>t", desc = "+Toggles" },
          { mode = "n", keys = "<leader>u", desc = "+Test/Utils" },
          { mode = "n", keys = "<leader>v", desc = "+Visual/View" },
          { mode = "n", keys = "<leader>x", desc = "+Diagnostics/Trouble" },
          { mode = "n", keys = "<leader>z", desc = "+Fold" },
        },
        window = {
            delay = 500,
        }
      })
    end,
  },
}
