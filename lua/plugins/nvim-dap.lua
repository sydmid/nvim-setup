-- C# Development Configuration
return {
  -- Debug Adapter Protocol (DAP) for debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local map = vim.keymap.set
      local dapui = require("dapui")

      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"

      local netcoredbg_adapter = {
        type = "executable",
        command = mason_path,
        args = { "--interpreter=vscode" },
      }

      dap.adapters.netcoredbg = netcoredbg_adapter -- needed for normal debugging
      dap.adapters.coreclr = netcoredbg_adapter    -- needed for unit test debugging

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            return require("dap-dll-autopicker").build_dll_path()
          end
        },
      }

      vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP: Continue/Start" })
      vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP: Step over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP: Step into" })
      vim.keymap.set("n", "<F8>", dap.step_out, { desc = "DAP: Step out" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP: REPL open" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "DAP: Run last" })

      -- *************************      dap-ui configurations
      -- open the ui as soon as we are debugging
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- https://emojipedia.org/en/stickers/search?q=circle
      vim.fn.sign_define('DapBreakpoint',
        {
          text = '⚪',
          texthl = 'DapBreakpointSymbol',
          linehl = 'DapBreakpoint',
          numhl = 'DapBreakpoint'
        })

      vim.fn.sign_define('DapStopped',
        {
          text = '🔴',
          texthl = 'yellow',
          linehl = 'DapBreakpoint',
          numhl = 'DapBreakpoint'
        })
      vim.fn.sign_define('DapBreakpointRejected',
        {
          text = '⭕',
          texthl = 'DapStoppedSymbol',
          linehl = 'DapBreakpoint',
          numhl = 'DapBreakpoint'
        })

      -- more minimal ui
      dapui.setup({
        expand_lines = true,
        controls = { enabled = false }, -- no extra play/step buttons
        floating = { border = "rounded" },

        -- Set dapui window
        render = {
          max_type_length = 60,
          max_value_lines = 200,
        },

        -- Only one layout: just the "scopes" (variables) list at the bottom
        layouts = {
          {
            elements = {
              { id = "scopes", size = 1.0 }, -- 100% of this panel is scopes
            },
            size = 15,                 -- height in lines (adjust to taste)
            position = "bottom",       -- "left", "right", "top", "bottom"
          },
        },
      })


      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP UI toggle" })

      vim.keymap.set({ "n", "v" }, "<leader>dw", function() dapui.eval(nil, { enter = true }) end,
        { desc = "DAP Add word under cursor to Watches" })
      vim.keymap.set({ "n", "v" }, "Q", function() dapui.eval() end, { desc = "DAP Peek" })

    end,
  },

  -- Testing framework
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "Issafalcon/neotest-dotnet",
      "stevearc/overseer.nvim", -- For task integration
    },
    config = function()
      local map = vim.keymap.set
      local neotest = require("neotest")
      require("neotest").setup({
        adapters = {
          require("neotest-dotnet")({
            dap = { justMyCode = false },
          }),
        },
        consumers = {
          overseer = require("neotest.consumers.overseer"),
        },
        discovery = {
          enabled = false,
        },
        running = {
          concurrent = true,
        },
        summary = {
          enabled = true,
          expand_errors = true,
          follow = true,
          mappings = {
            attach = "a",
            clear_marked = "M",
            clear_target = "T",
            debug = "d",
            debug_marked = "D",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            jumpto = "i",
            mark = "m",
            next_failed = "J",
            output = "o",
            prev_failed = "K",
            run = "r",
            run_marked = "R",
            short = "O",
            stop = "u",
            target = "t",
          },
        },
      })

      -- Neotest keymaps
      vim.keymap.set("n", "<leader>dt", function() neotest.run.run({ strategy = "dap" }) end, { desc = "Debug nearest test" })
      vim.keymap.set("n", "<F6>", function() neotest.run.run({ strategy = "dap" }) end, { desc = "Debug nearest test" })
      
      -- TODO: badan checkeshun kon ye ghaede keybinding e khub bara function bedard bokhora bezar
      vim.keymap.set("n", "<leader>ut", "<cmd>lua require('neotest').run.run()<cr>", { desc = "Run nearest test" })
      vim.keymap.set("n", "<leader>uf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", { desc = "Run file tests" })
      vim.keymap.set("n", "<leader>ud", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",
        { desc = "Debug nearest test" })
      vim.keymap.set("n", "<leader>um", "<cmd>lua require('neotest').summary.toggle()<cr>", { desc = "Toggle test summary" })
      vim.keymap.set("n", "<leader>uo", "<cmd>lua require('neotest').output.open({ enter = true })<cr>",
        { desc = "Show test output" })
    end,
  },

  -- .NET specific test runner
  {
    "Issafalcon/neotest-dotnet",
    lazy = false,
    dependencies = {
      "nvim-neotest/neotest"
    }
  },

}
