local theme_opts = {
	styles = {
		type = { bold = true },
		lsp = { underline = false },
		match_paren = { underline = true },
	},
}

local function config_theme()
	local plugin = require("no-clown-fiesta")
	plugin.setup(theme_opts)
	return plugin.load()
end
return {
	-- Colorscheme
	{
		"aktersnurra/no-clown-fiesta.nvim",
		priority = 1000,
		config = config_theme,
    lazy = false
	},

	-- Status line
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local lualine = require("lualine")
			local lazy_status = require("lazy.status") -- to configure lazy pending updates count

			local colors = {
				blue = "#65D1FF",
				green = "#3EFFDC",
				violet = "#FF61EF",
				yellow = "#FFDA7B",
				red = "#FF4A4A",
				fg = "#c3ccdc",
				bg = "#112638",
				inactive_bg = "#2c3043",
			}

			local my_lualine_theme = {
				normal = {
					a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
					b = { bg = colors.bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.fg },
				},
				insert = {
					a = { bg = colors.green, fg = colors.bg, gui = "bold" },
					b = { bg = colors.bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.fg },
				},
				visual = {
					a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
					b = { bg = colors.bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.fg },
				},
				command = {
					a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
					b = { bg = colors.bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.fg },
				},
				replace = {
					a = { bg = colors.red, fg = colors.bg, gui = "bold" },
					b = { bg = colors.bg, fg = colors.fg },
					c = { bg = colors.bg, fg = colors.fg },
				},
				inactive = {
					a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
					b = { bg = colors.inactive_bg, fg = colors.semilightgray },
					c = { bg = colors.inactive_bg, fg = colors.semilightgray },
				},
			}

			-- configure lualine with modified theme
			lualine.setup({
				options = {
					theme = my_lualine_theme,
				},
				sections = {
					lualine_x = {
						{
							lazy_status.updates,
							cond = lazy_status.has_updates,
							color = { fg = "#ff9e64" },
						},
						{ "encoding" },
						{ "fileformat" },
						{ "filetype" },
					},
				},
			})
		end,
	},
	-- Highlight yanked text
	{
		"machakann/vim-highlightedyank",
		event = "VeryLazy",
	},

	-- Indentation guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},

	-- Better UI elements
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
		},
	},

	-- Telescope symbols (replaces symbols-outline with beautiful telescope UI)
	{
		"nvim-telescope/telescope.nvim",
		keys = {
			{
				"<D-o>",
				function()
					require("telescope.builtin").lsp_document_symbols({
						symbol_width = 50,
						symbol_type_width = 15,
						show_line = true,
						previewer = true,
					})
				end,
				desc = "Document Symbols (Telescope)",
			},
			{
				"<D-S-o>",
				function()
					require("telescope.builtin").lsp_workspace_symbols({
						symbol_width = 50,
						symbol_type_width = 15,
						show_line = true,
						previewer = true,
					})
				end,
				desc = "Workspace Symbols (Telescope)",
			},
		},
	},

	-- Tmux Tab Navigator
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
			"TmuxNavigatorProcessList",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},

	{
		"szw/vim-maximizer",
	},

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
					separator = "➜",
					group = "+",
				},
				layout = {
					height = { min = 4, max = 25 },
					width = { min = 20, max = 50 },
					spacing = 3,
					align = "left",
				},
				show_help = true,
			})

			-- Register all the key groups
			wk.add({
				-- { '<leader>b', group = 'Bookmarks' },
				{ "<leader>d", group = "Diagnostics/Debug" },
				{ "<leader>f", group = "File/Find" },
				{ "<leader>g", group = "Git/Goto" },
				{ "<leader>h", group = "Hunks/Help" },
				{ "<leader>i", group = "Info" },
				{ "<leader>m", group = "Bookmarks" },
				{ "<leader>n", group = "Navigation" },
				{ "<leader>r", group = "Rename/Refactor" },
				{ "<leader>s", group = "Split" },
				{ "<leader>t", group = "Terminal/Tabs" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>x", group = "Diagnostics" },
				{ "g", group = "Goto" },
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

	-- Add nvim-notify for notification support
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		config = function()
			require("notify").setup({
				background_colour = "#000000",
				timeout = 3000,
				max_width = 80,
				level = vim.log.levels.ERROR,
			})
		end,
	},
}
