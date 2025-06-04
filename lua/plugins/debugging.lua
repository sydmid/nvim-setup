return {
	-- Debug Adapter Protocol - General configuration for non-C# debugging
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			-- Note: C# specific DAP configuration is handled in csharp.lua
			-- This file handles general DAP setup for other languages

			local dap = require("dap")

			-- Add other language debuggers here as needed
			-- Example for Node.js debugging:
			-- dap.adapters.node2 = {
			--   type = 'executable',
			--   command = 'node',
			--   args = {os.getenv('HOME') .. '/dev/microsoft/vscode-node-debug2/out/src/nodeDebug.js'},
			-- }

			-- Example for Python debugging:
			-- dap.adapters.python = {
			--   type = 'executable',
			--   command = 'python',
			--   args = { '-m', 'debugpy.adapter' },
			-- }

			-- General DAP keymaps (these complement the C# specific F-key mappings)
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Set Conditional Breakpoint" })
			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Start/Continue Debugging" })
			vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
			vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step Over" })
			vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step Out" })
			vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
			vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last Debug Configuration" })
			vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate Debugging" })
		end,
	},
}