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

      -- NetCoreDbg adapter configuration
      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.expand("~/Documents/debuggers/netcoredbg/netcoredbg"),
        args = { "--interpreter=vscode" },
      }

      dap.adapters.netcoredbg = {
        type = "executable",
        command = vim.fn.expand("~/Documents/debuggers/netcoredbg/netcoredbg"),
        args = { "--interpreter=vscode" },
      }

      -- C# debug configuration
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            -- Look for common .NET output paths
            local cwd = vim.fn.getcwd()
            local common_paths = {
              cwd .. "/bin/Debug/net8.0/",
              cwd .. "/bin/Debug/net7.0/",
              cwd .. "/bin/Debug/net6.0/",
              cwd .. "/bin/Debug/netcoreapp3.1/",
            }

            -- Find the first existing path
            for _, path in ipairs(common_paths) do
              if vim.fn.isdirectory(path) == 1 then
                return vim.fn.input("Path to dll: ", path, "file")
              end
            end

            -- Fallback to current directory
            return vim.fn.input("Path to dll: ", cwd .. "/", "file")
          end,
        },
      }

      -- Debug keymaps
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", opts)
      map("n", "<F6>", "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", opts)
      map("n", "<F9>", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
      map("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", opts)
      map("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", opts)
      map("n", "<F8>", "<Cmd>lua require'dap'.step_out()<CR>", opts)
      map("n", "<leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>", opts)
      map("n", "<leader>dl", "<Cmd>lua require'dap'.run_last()<CR>", opts)
      map("n", "<leader>dt", "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>",
        { noremap = true, silent = true, desc = 'debug nearest test' })
      map("n", "<leader>du", "<Cmd>lua require'dapui'.toggle()<CR>", opts)
    end,
    event = "VeryLazy",
  },

  -- DAP UI for debugging interface
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "↻",
            terminate = "□",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        },
      })

      -- Auto-open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Custom highlight groups for breakpoints
      vim.api.nvim_set_hl(0, "blue", { fg = "#3d59a1" })
      vim.api.nvim_set_hl(0, "green", { fg = "#9ece6a" })
      vim.api.nvim_set_hl(0, "yellow", { fg = "#FFFF00" })
      vim.api.nvim_set_hl(0, "orange", { fg = "#f09000" })

      -- Breakpoint signs
      vim.fn.sign_define('DapBreakpoint', {
        text = '🔴',
        texthl = 'DapBreakpointSymbol',
        linehl = 'DapBreakpoint',
        numhl = 'DapBreakpoint'
      })

      vim.fn.sign_define('DapStopped', {
        text = '🟡',
        texthl = 'yellow',
        linehl = 'DapBreakpoint',
        numhl = 'DapBreakpoint'
      })

      vim.fn.sign_define('DapBreakpointRejected', {
        text = '🚫',
        texthl = 'DapStoppedSymbol',
        linehl = 'DapBreakpoint',
        numhl = 'DapBreakpoint'
      })
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
      local map = vim.keymap.set
      map("n", "<leader>tt", "<cmd>lua require('neotest').run.run()<cr>", { desc = "Run nearest test" })
      map("n", "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", { desc = "Run file tests" })
      map("n", "<leader>td", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", { desc = "Debug nearest test" })
      map("n", "<leader>ts", "<cmd>lua require('neotest').summary.toggle()<cr>", { desc = "Toggle test summary" })
      map("n", "<leader>to", "<cmd>lua require('neotest').output.open({ enter = true })<cr>", { desc = "Show test output" })
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

  -- TreeSitter for C# syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c_sharp" })
    end,
  },

  -- OmniSharp Extended - enables go-to-definition for imported libraries
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    lazy = true,
    ft = { "cs" },
  },

  -- Overseer - Task runner for building, testing, and running projects
  {
    "stevearc/overseer.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      strategy = {
        "toggleterm",
        direction = "horizontal",
        auto_scroll = true,
        quit_on_exit = "success"
      },
      templates = { "builtin" },
      auto_scroll = true,
      task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
        bindings = {
          ["?"] = "ShowHelp",
          ["g?"] = "ShowHelp",
          ["<CR>"] = "RunAction",
          ["<C-e>"] = "Edit",
          ["o"] = "Open",
          ["<C-v>"] = "OpenVsplit",
          ["<C-s>"] = "OpenSplit",
          ["<C-f>"] = "OpenFloat",
          ["<C-q>"] = "OpenQuickFix",
          ["p"] = "TogglePreview",
          ["<C-l>"] = "IncreaseDetail",
          ["<C-h>"] = "DecreaseDetail",
          ["L"] = "IncreaseAllDetail",
          ["H"] = "DecreaseAllDetail",
          ["["] = "DecreaseWidth",
          ["]"] = "IncreaseWidth",
          ["{"] = "PrevTask",
          ["}"] = "NextTask",
          ["<C-k>"] = "ScrollOutputUp",
          ["<C-j>"] = "ScrollOutputDown",
          ["q"] = "Close",
        },
      },
    },
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)

      -- Enhanced task templates for different project types
      overseer.register_template({
        name = "dotnet build",
        builder = function()
          return {
            cmd = { "dotnet" },
            args = { "build" },
            components = { "default" },
          }
        end,
        condition = {
          filetype = { "cs" },
        },
      })

      overseer.register_template({
        name = "dotnet run",
        builder = function()
          return {
            cmd = { "dotnet" },
            args = { "run" },
            components = { "default" },
          }
        end,
        condition = {
          filetype = { "cs" },
        },
      })

      overseer.register_template({
        name = "dotnet test",
        builder = function()
          return {
            cmd = { "dotnet" },
            args = { "test" },
            components = { "default" },
          }
        end,
        condition = {
          filetype = { "cs" },
        },
      })

      overseer.register_template({
        name = "npm build",
        builder = function()
          return {
            cmd = { "npm" },
            args = { "run", "build" },
            components = { "default" },
          }
        end,
        condition = {
          filetype = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
        },
      })

      overseer.register_template({
        name = "npm start",
        builder = function()
          return {
            cmd = { "npm" },
            args = { "start" },
            components = { "default" },
          }
        end,
        condition = {
          filetype = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
        },
      })

      overseer.register_template({
        name = "ng build",
        builder = function()
          return {
            cmd = { "ng" },
            args = { "build" },
            components = { "default" },
          }
        end,
        condition = {
          filetype = { "typescript", "typescriptreact" },
        },
      })

      overseer.register_template({
        name = "ng serve",
        builder = function()
          return {
            cmd = { "ng" },
            args = { "serve" },
            components = { "default" },
          }
        end,
        condition = {
          filetype = { "typescript", "typescriptreact" },
        },
      })

      overseer.register_template({
        name = "python run",
        builder = function()
          local file = vim.fn.expand("%:p")
          return {
            cmd = { "python3" },
            args = { file },
            components = { "default" },
          }
        end,
        condition = {
          filetype = { "python" },
        },
      })

      -- Keymaps for overseer
      vim.keymap.set("n", "<leader>or", "<cmd>OverseerRun<cr>", { desc = "Run task" })
      vim.keymap.set("n", "<leader>ot", "<cmd>OverseerToggle<cr>", { desc = "Toggle task list" })
      vim.keymap.set("n", "<leader>oo", "<cmd>OverseerOpen<cr>", { desc = "Open task list" })
      vim.keymap.set("n", "<leader>oc", "<cmd>OverseerClose<cr>", { desc = "Close task list" })
      vim.keymap.set("n", "<leader>oa", "<cmd>OverseerQuickAction<cr>", { desc = "Quick action" })
      vim.keymap.set("n", "<leader>ob", "<cmd>OverseerBuild<cr>", { desc = "Build task" })
      vim.keymap.set("n", "<leader>od", "<cmd>OverseerDeleteBundle<cr>", { desc = "Delete task bundle" })
      vim.keymap.set("n", "<leader>ol", "<cmd>OverseerLoadBundle<cr>", { desc = "Load task bundle" })
      vim.keymap.set("n", "<leader>os", "<cmd>OverseerSaveBundle<cr>", { desc = "Save task bundle" })
    end,
  },
}
