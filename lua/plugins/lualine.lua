return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	config = function()
		-- Cached ahead/behind counts for statusline (avoids per-render git calls)
		local ahead_behind_cache = { ahead = 0, behind = 0 }
		local function update_ahead_behind()
			local result = vim.fn.systemlist(
				"git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null"
			)
			if vim.v.shell_error == 0 and result[1] then
				local a, b = result[1]:match("(%d+)%s+(%d+)")
				ahead_behind_cache.ahead = tonumber(a) or 0
				ahead_behind_cache.behind = tonumber(b) or 0
			else
				ahead_behind_cache.ahead = 0
				ahead_behind_cache.behind = 0
			end
		end

		vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained" }, {
			callback = function()
				vim.defer_fn(update_ahead_behind, 100)
			end,
		})
		local timer = vim.uv.new_timer()
		if timer then
			timer:start(0, 30000, vim.schedule_wrap(update_ahead_behind))
		end

		-- Custom Lualine component to show attached language server
		local clients_lsp = function()
			local bufnr = vim.api.nvim_get_current_buf()

			local clients = vim.lsp.get_clients()
			if next(clients) == nil then
				return ""
			end

			local c = {}
			for _, client in pairs(clients) do
				table.insert(c, client.name)
			end
			return " " .. table.concat(c, "|")
		end

		local custom_theme = require("lualine.themes.moonfly")

		-- Custom colours
		custom_theme.normal.b.fg = "#cad3f5"
		custom_theme.insert.b.fg = "#cad3f5"
		custom_theme.visual.b.fg = "#cad3f5"
		custom_theme.replace.b.fg = "#cad3f5"
		-- custom_theme.command.b.fg = "#cad3f5"
		custom_theme.inactive.b.fg = "#cad3f5"

		custom_theme.normal.c.fg = "#6e738d"
		custom_theme.normal.c.bg = "#1e2030"

		require("lualine").setup({
			options = {
				theme = custom_theme,
				component_separators = "",
				section_separators = { left = "", right = "" },
				disabled_filetypes = { "alpha", "Outline" },
			},
			sections = {
				lualine_a = {
					{ "mode", separator = { left = " ", right = "" } , icon = ""},
				},
				lualine_b = {
					{
						"filetype",
						icon_only = true,
						padding = { left = 1, right = 0 },
					},
					"filename",
				},
				lualine_c = {
					{
						"branch",
						icon = "",
					},
					{
						function()
							local a = ahead_behind_cache.ahead
							local b = ahead_behind_cache.behind
							if a == 0 and b == 0 then return "" end
							local parts = {}
							if b > 0 then table.insert(parts, "↓" .. b) end
							if a > 0 then table.insert(parts, "↑" .. a) end
							return table.concat(parts, " ")
						end,
						cond = function() return vim.b.gitsigns_head ~= nil end,
						color = { fg = "#f5c359" },
						padding = { left = 1, right = 0 },
					},
					{
						"diff",
						symbols = { added = " ", modified = " ", removed = " " },
						colored = true,
					},
				},
				lualine_x = {
					{
						"diagnostics",
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
						update_in_insert = true,
					},
				},
				-- lualine_y = { clients_lsp },
				lualine_y = {},
				lualine_z = {
					{ "location", separator = { left = "", right = " " }, icon = "" },
				},
			},
			inactive_sections = {
				lualine_a = { "filename" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
			extensions = { "toggleterm", "trouble" },
		})
	end,
}
