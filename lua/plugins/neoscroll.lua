return {
	"karb94/neoscroll.nvim",
	event = "VeryLazy",
	config = function()
		-- Setup neoscroll with no default mappings
		require("neoscroll").setup({
			mappings = {}, -- Disable all default mappings
			hide_cursor = true, -- Hide cursor while scrolling for better visual experience
			stop_eof = true, -- Stop at <EOF> when scrolling downwards
			respect_scrolloff = false, -- Stop scrolling when cursor reaches scrolloff margin
			cursor_scrolls_alone = true, -- Cursor keeps scrolling even if window can't scroll further
			duration_multiplier = 1.0, -- Global duration multiplier
			easing = "quadratic", -- Smooth easing function for better animation
			pre_hook = nil, -- Function to run before scrolling starts
			post_hook = nil, -- Function to run after scrolling ends
			performance_mode = false, -- Keep syntax highlighting during scroll
			ignored_events = { -- Events ignored while scrolling
				"WinScrolled",
				"CursorMoved",
			},
		})

		local neoscroll = require("neoscroll")

		-- Custom smooth scrolling keymaps
		local keymap = {
			-- ["<D-j>"] = function()
			-- 	neoscroll.scroll(vim.wo.scroll, { duration = 200, easing = "sine" })
			-- end,
			-- ["<D-k>"] = function()
			-- 	neoscroll.scroll(-vim.wo.scroll, { duration = 200, easing = "sine" })
			-- end,
			["<S-j>"] = function()
				neoscroll.scroll(12, { duration = 150, easing = "quadratic" })
			end,
			["<S-k>"] = function()
				neoscroll.scroll(-12, { duration = 150, easing = "quadratic" })
			end,
		}

		-- Apply keymaps to normal, visual, and select modes
		local modes = { "n", "v", "x" }
		for key, func in pairs(keymap) do
			vim.keymap.set(modes, key, func, { silent = true, desc = "Smooth scroll" })
		end
	end,
}