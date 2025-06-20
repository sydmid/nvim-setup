-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Suppress vim.validate deprecation warnings globally until plugins are updated
local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
	if msg and type(msg) == "string" and msg:match("vim%.validate is deprecated") then
		-- Silently ignore vim.validate deprecation warnings
		return
	end
	return orig_notify(msg, level, opts)
end

-- Load configuration modules
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Setup plugins with lazy.nvim
require("lazy").setup({ { import = "plugins" }, { import = "plugins.lsp" } }, {
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
	install = {},
	rocks = {
		enabled = false, -- disable luarocks integration
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
-- require("lazy").setup({
--   spec = {
--     { import = "plugins" }, -- Load all plugin modules from plugins/
--   },
--   install = {
--   },
--   checker = {
--     enabled = true,
--     notify = false,
--   },
--   change_detection = {
--     notify = false,
--   },
--   performance = {
--     rtp = {
--       disabled_plugins = {
--         "gzip",
--         "netrwPlugin",
--         "tarPlugin",
--         "tohtml",
--         "tutor",
--         "zipPlugin",
--       },
--     },
--   },
-- })

-- Syntactic Suger for neoScroll
neoscroll = require("neoscroll")
local keymap = {
	["<C-u>"] = function()
		neoscroll.ctrl_u({ duration = 40 })
	end,
	["<C-d>"] = function()
		neoscroll.ctrl_d({ duration = 40 })
	end,
	["<C-b>"] = function()
		neoscroll.ctrl_b({ duration = 40 })
	end,
	["<C-f>"] = function()
		neoscroll.ctrl_f({ duration = 40 })
	end,
	["<C-y>"] = function()
		neoscroll.scroll(-0.1, { move_cursor = false, duration = 40 })
	end,
	["<C-e>"] = function()
		neoscroll.scroll(0.1, { move_cursor = false, duration = 40 })
	end,
	["zt"] = function()
		neoscroll.zt({ half_win_duration = 40 })
	end,
	["zz"] = function()
		neoscroll.zz({ half_win_duration = 40 })
	end,
	["zb"] = function()
		neoscroll.zb({ half_win_duration = 40 })
	end,
}
local modes = { "n", "v", "x" }
for key, func in pairs(keymap) do
	vim.keymap.set(modes, key, func)
end

-- Normal mode: ⌘+/ (comment line and move down)
vim.keymap.set("n", "<D-/>", function()
	require("Comment.api").toggle.linewise.current()
	vim.cmd("normal! j") -- move down a line
end, { silent = true, desc = "Toggle comment line and move down" })

-- Visual mode: ⌘ + / (comment selected block)
vim.keymap.set("v", "<D-/>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { silent = true, desc = "Toggle comment (visual)" })

-- NerdTree
-- vim.g.NerdTreeWinPos = "right"
-- vim.g.lazyvim_check_order = false
