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
      local dapui = require("dapui")
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
      end

      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"
      local adapter_command = vim.fn.executable(mason_path) == 1 and mason_path or "netcoredbg"

      if vim.fn.executable(adapter_command) ~= 1 then
        vim.notify("netcoredbg not found. Install it with Mason or ensure it is on PATH.", vim.log.levels.WARN)
      end

      local netcoredbg_adapter = {
        type = "executable",
        command = adapter_command,
        args = { "--interpreter=vscode" },
      }

      dap.adapters.netcoredbg = netcoredbg_adapter -- needed for normal debugging
      dap.adapters.coreclr = netcoredbg_adapter  -- needed for unit test debugging

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

      -- VSCode-like keybindings
      map("n", "<F5>", dap.continue, "DAP: Continue/Start")
      map("n", "<F9>", dap.toggle_breakpoint, "DAP: Toggle breakpoint")
      map("n", "<F10>", dap.step_over, "DAP: Step over")
      map("n", "<F11>", dap.step_into, "DAP: Step into")
      map("n", "<F12>", dap.step_out, "DAP: Step out")
      map("n", "<S-F5>", dap.terminate, "DAP: Stop")
      map("n", "<C-S-F5>", dap.restart, "DAP: Restart")

      -- Additional keybindings (your existing ones)
      map("n", "<F8>", dap.step_out, "DAP: Step out")
      map("n", "<Leader>db", dap.toggle_breakpoint, "DAP: Toggle breakpoint")
      map("n", "<leader>dr", dap.repl.open, "DAP: REPL open")
      map("n", "<leader>dl", dap.run_last, "DAP: Run last")

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
            size = 15,                     -- height in lines (adjust to taste)
            position = "bottom",           -- "left", "right", "top", "bottom"
          },
        },
      })

      map("n", "<D-d>", dapui.toggle, "DAP UI toggle")

      map({ "n", "v" }, "<leader>dw", function() dapui.eval(nil, { enter = true }) end,
        "DAP Add word under cursor to Watches")
      map({ "n", "v" }, "Q", function() dapui.eval() end, "DAP Peek")
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
      local neotest_registry = require("core.utils.neotest")
      local neotest = require("neotest")
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
      end

      neotest_registry.register_adapter("dotnet", require("neotest-dotnet")({
        dap = { justMyCode = false },
      }), {
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
      map("n", "<leader>dt", function() neotest.run.run({ strategy = "dap" }) end, "Debug nearest test")
      map("n", "<F6>", function() neotest.run.run({ strategy = "dap" }) end, "Debug nearest test")

      -- TODO: badan checkeshun kon ye ghaede keybinding e khub bara function bedard bokhora bezar
      map("n", "<leader>ut", "<cmd>lua require('neotest').run.run()<cr>", "Run nearest test")
      map("n", "<leader>uf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", "Run file tests")
      map("n", "<leader>ud", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", "Debug nearest test")
      map("n", "<leader>um", "<cmd>lua require('neotest').summary.toggle()<cr>", "Toggle test summary")
      map("n", "<leader>uo", "<cmd>lua require('neotest').output.open({ enter = true })<cr>", "Show test output")
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
