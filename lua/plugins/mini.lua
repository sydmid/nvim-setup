return {
  -- Mini Nvim
  { "echasnovski/mini.nvim", version = false },
  -- Icons
  { "echasnovski/mini.icons", version = false, config = true },
  -- Comments
  {
    "echasnovski/mini.comment",
    version = false,
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      -- disable the autocommand from ts-context-commentstring
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })

      local miniComment = require("mini.comment")
      miniComment.setup({
        -- tsx, jsx, html , svelte comment support
        options = {
          custom_commentstring = function()
            return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
          end,
        },
      })

      vim.keymap.set("n", "<D-/>", function()
        -- Save current position
        local start_row, start_col = unpack(vim.api.nvim_win_get_cursor(0))

        -- Toggle comment
        miniComment.toggle_lines(start_row, start_row)

        -- Move down one line
        local next_row = math.min(start_row + 1, vim.api.nvim_buf_line_count(0))
        vim.api.nvim_win_set_cursor(0, { next_row, start_col })
      end, { silent = true, desc = "Toggle comment line and move down" })

      vim.keymap.set("x", "<D-/>", "gc", { remap = true, silent = true, desc = "Toggle comment (visual)" })
    end,
  },
  -- File explorer (this works properly with oil unlike nvim-tree)
  -- {
  --     'echasnovski/mini.files',
  --     config = function()
  --         local MiniFiles = require("mini.files")
  --         MiniFiles.setup({
  --             mappings = {
  --                 go_in = "<CR>", -- Map both Enter and L to enter directories or open files
  --                 go_in_plus = "L",
  --                 go_out = "-",
  --                 go_out_plus = "H",
  --             },
  --         })
  --         vim.keymap.set("n", "<leader>ee", "<cmd>lua MiniFiles.open()<CR>", { desc = "Toggle mini file explorer" }) -- toggle file explorer
  --         vim.keymap.set("n", "<leader>ef", function()
  --             MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
  --             MiniFiles.reveal_cwd()
  --         end, { desc = "Toggle into currently opened file" })
  --     end,
  -- },
  -- Surround
  {
    "echasnovski/mini.surround",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- Add custom surroundings to be used on top of builtin ones. For more
      -- information with examples, see `:h MiniSurround.config`.
      custom_surroundings = nil,

      -- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
      highlight_duration = 300,

      -- Module mappings. Use `''` (empty string) to disable one.
      -- INFO:
      -- saiw surround with no whitespace
      -- saw surround with whitespace
      mappings = {
        add = "sa", -- Add surrounding in Normal and Visual modes
        delete = "sd", -- Delete surrounding
        find = "sf", -- Find surrounding (to the right)
        find_left = "sF", -- Find surrounding (to the left)
        highlight = "sh", -- Highlight surrounding
        replace = "sc", -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },

      -- Number of lines within which surrounding is searched
      n_lines = 20,

      -- Whether to respect selection type:
      -- - Place surroundings on separate lines in linewise mode.
      -- - Place surroundings on each line in blockwise mode.
      respect_selection_type = false,

      -- How to search for surrounding (first inside current line, then inside
      -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
      -- 'cover_or_nearest', 'next', 'prev', 'nearest'. For more details,
      -- see `:h MiniSurround.config`.
      search_method = "cover",

      -- Whether to disable showing non-error feedback
      silent = false,
    },
  },
  -- Get rid of whitespace
  {
    "echasnovski/mini.trailspace",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local miniTrailspace = require("mini.trailspace")

      miniTrailspace.setup({
        only_in_normal_buffers = true,
      })
      vim.keymap.set("n", "<leader>cw", function()
        miniTrailspace.trim()
      end, { desc = "Erase Whitespace" })

      -- Ensure highlight never reappears by removing it on CursorMoved
      vim.api.nvim_create_autocmd("CursorMoved", {
        pattern = "*",
        callback = function()
          require("mini.trailspace").unhighlight()
        end,
      })
    end,
  },
  -- Split & join
  {
    "echasnovski/mini.splitjoin",
    config = function()
      local miniSplitJoin = require("mini.splitjoin")
      miniSplitJoin.setup({
        mappings = { toggle = "" }, -- Disable default mapping
      })
      vim.keymap.set({ "n", "x" }, "sj", function()
        miniSplitJoin.join()
      end, { desc = "Join arguments" })
      vim.keymap.set({ "n", "x" }, "sk", function()
        miniSplitJoin.split()
      end, { desc = "Split arguments" })
    end,
  },
  -- Extra mini functionality
  {
    "echasnovski/mini.extra",
    version = "*",
    config = function()
      require("mini.extra").setup()
    end,
  },
  -- Better textobjects
  {
    "echasnovski/mini.ai",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function()
      local ai = require("mini.ai")
      ai.setup({
        custom_textobjects = {
          B = require("mini.extra").gen_ai_spec.buffer(),
          F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          o = ai.gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
        },
        search_method = "cover",
      })
    end,
  },
  -- Align text interactively
  {
    "echasnovski/mini.align",
    config = function()
      require("mini.align").setup()
    end,
  },
  -- Go forward/backward with square brackets
  {
    "echasnovski/mini.bracketed",
    config = function()
      require("mini.bracketed").setup()
    end,
  },
  -- Autopairs
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    config = function()
      require("mini.pairs").setup({
        modes = { insert = true, command = true, terminal = false },
      })
    end,
  },
  -- Highlight word under cursor
  {
    "echasnovski/mini.cursorword",
    version = "*",
    config = function()
      require("mini.cursorword").setup()
    end,
  },
  -- Move any selection in any direction
  {
    "echasnovski/mini.move",
    version = "*",
    config = function()
      require("mini.move").setup({
        options = { reindent_linewise = false },
      })
    end,
  },
  -- Text edit operators
  {
    "echasnovski/mini.operators",
    version = "*",
    config = function()
      require("mini.operators").setup()
    end,
  },
  -- Highlight patterns (TODOs, colors, etc.)
  {
    "echasnovski/mini.hipatterns",
    version = "*",
    config = function()
      local hipatterns = require("mini.hipatterns")
      hipatterns.setup({
        highlighters = {
          -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
          fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
          hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
          todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
          note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

          -- Highlight hex color strings (`#rrggbb`) using that color
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })
    end,
  },
  -- Keybinding hints (replaces which-key)
  {
    "echasnovski/mini.clue",
    version = "*",
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
        },

        window = {
          delay = 500,
          config = {
            width = "auto",
            border = "rounded",
          },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          { mode = "n", keys = "<Leader>a", desc = "+AI" },
          { mode = "x", keys = "<Leader>a", desc = "+AI" },
          { mode = "n", keys = "<Leader>d", desc = "+Debug" },
          { mode = "x", keys = "<Leader>d", desc = "+Debug" },
          { mode = "n", keys = "<Leader>e", desc = "+Error Lens/Explorer" },
          { mode = "x", keys = "<Leader>e", desc = "+Error Lens/Explorer" },
          { mode = "n", keys = "<Leader>b", desc = "+Buffer" },
          { mode = "x", keys = "<Leader>b", desc = "+Buffer" },
          { mode = "n", keys = "<Leader>c", desc = "+Context/Code-Actions" },
          { mode = "x", keys = "<Leader>c", desc = "+Context/Code-Actions" },
          { mode = "n", keys = "<Leader>f", desc = "+File/Find" },
          { mode = "x", keys = "<Leader>f", desc = "+File/Find" },
          { mode = "n", keys = "<Leader>g", desc = "+Git/Goto" },
          { mode = "x", keys = "<Leader>g", desc = "+Git/Goto" },
          { mode = "n", keys = "<Leader>gc", desc = "+Conflicts" },
          { mode = "x", keys = "<Leader>gc", desc = "+Conflicts" },
          { mode = "n", keys = "<Leader>h", desc = "+Hunks/Git-Stage" },
          { mode = "x", keys = "<Leader>h", desc = "+Hunks/Git-Stage" },
          { mode = "n", keys = "<Leader>j", desc = "+Jump" },
          { mode = "x", keys = "<Leader>j", desc = "+Jump" },
          { mode = "n", keys = "<Leader>k", desc = "+Jump/Flash" },
          { mode = "x", keys = "<Leader>k", desc = "+Jump/Flash" },
          { mode = "n", keys = "<Leader>l", desc = "+LSP" },
          { mode = "x", keys = "<Leader>l", desc = "+LSP" },
          { mode = "n", keys = "<Leader>p", desc = "+Peek/Preview" },
          { mode = "x", keys = "<Leader>p", desc = "+Peek/Preview" },
          { mode = "n", keys = "<Leader>r", desc = "+Rename/Refactor" },
          { mode = "x", keys = "<Leader>r", desc = "+Rename/Refactor" },
          { mode = "n", keys = "<Leader>s", desc = "+Snacks" },
          { mode = "x", keys = "<Leader>s", desc = "+Snacks" },
          { mode = "n", keys = "<Leader>t", desc = "+Toggles" },
          { mode = "x", keys = "<Leader>t", desc = "+Toggles" },
          { mode = "n", keys = "<Leader>u", desc = "+Test/Utils" },
          { mode = "x", keys = "<Leader>u", desc = "+Test/Utils" },
          { mode = "n", keys = "<Leader>v", desc = "+Visual/View" },
          { mode = "x", keys = "<Leader>v", desc = "+Visual/View" },
          { mode = "n", keys = "<Leader>x", desc = "+Diagnostics/Trouble" },
          { mode = "x", keys = "<Leader>x", desc = "+Diagnostics/Trouble" },
          { mode = "n", keys = "<Leader>z", desc = "+Fold" },
          { mode = "x", keys = "<Leader>z", desc = "+Fold" },

          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
      })
    end,
  },
  -- Diff overlay and visualizations
  {
    "echasnovski/mini.diff",
    version = "*",
    config = function()
      require("mini.diff").setup()
      vim.keymap.set("n", "<leader>go", "<cmd>lua MiniDiff.toggle_overlay()<CR>", { desc = "Toggle mini.diff overlay" })
    end,
  },
  -- Track and reuse file visits
  {
    "echasnovski/mini.visits",
    version = "*",
    config = function()
      require("mini.visits").setup()
      vim.keymap.set(
        "n",
        "<leader>vv",
        "<cmd>lua MiniVisits.add_label('core')<CR>",
        { desc = "Add 'core' label (mini.visits)" }
      )
      vim.keymap.set(
        "n",
        "<leader>vV",
        "<cmd>lua MiniVisits.remove_label('core')<CR>",
        { desc = "Remove 'core' label (mini.visits)" }
      )
      vim.keymap.set("n", "<leader>vl", "<cmd>lua MiniVisits.add_label()<CR>", { desc = "Add label (mini.visits)" })
      vim.keymap.set(
        "n",
        "<leader>vL",
        "<cmd>lua MiniVisits.remove_label()<CR>",
        { desc = "Remove label (mini.visits)" }
      )
    end,
  },
}
