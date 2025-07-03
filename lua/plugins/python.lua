-- Professional Python development setup for Neovim
-- Configured for maximum productivity like the most experienced Python developers

return {
	-- Enhanced Python debugging with debugpy
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		dependencies = {
			"mfussenegger/nvim-dap",
			"rcarriga/nvim-dap-ui",
		},		config = function()
			-- Configure debugpy path with robust Mason integration
			local dap_python = require("dap-python")

			-- Try to get debugpy path from Mason first
			local debugpy_path = nil
			local mason_ok, mason_registry = pcall(require, "mason-registry")
			if mason_ok and mason_registry and mason_registry.is_installed then
				local is_installed_ok, is_installed = pcall(mason_registry.is_installed, "debugpy")
				if is_installed_ok and is_installed then
					local pkg_ok, debugpy_pkg = pcall(mason_registry.get_package, "debugpy")
					if pkg_ok and debugpy_pkg and debugpy_pkg.get_install_path then
						local path_ok, install_path = pcall(debugpy_pkg.get_install_path, debugpy_pkg)
						if path_ok and install_path then
							debugpy_path = install_path .. "/venv/bin/python"
						end
					end
				end
			end

			-- Fallback to system python or virtual environment
			if not debugpy_path then
				-- Try to find python in current virtual environment
				local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
				if vim.fn.executable(venv_python) == 1 then
					debugpy_path = venv_python
				else
					-- Fallback to system python
					debugpy_path = vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
				end
			end

			-- Ensure we have a valid path before setting up DAP
			if debugpy_path and debugpy_path ~= "" then
				dap_python.setup(debugpy_path)
			else
				-- Final fallback
				dap_python.setup("python3")
			end

			-- Custom configurations for common Python scenarios
			table.insert(require("dap").configurations.python, {
				type = "python",
				request = "launch",
				name = "Launch file with arguments",
				program = "${file}",
				args = function()
					local args_string = vim.fn.input("Arguments: ")
					return vim.split(args_string, " ")
				end,
				console = "integratedTerminal",
				cwd = "${workspaceFolder}",
			})

			table.insert(require("dap").configurations.python, {
				type = "python",
				request = "launch",
				name = "Django",
				program = "${workspaceFolder}/manage.py",
				args = {
					"runserver",
				},
				django = true,
				console = "integratedTerminal",
				cwd = "${workspaceFolder}",
			})

			table.insert(require("dap").configurations.python, {
				type = "python",
				request = "launch",
				name = "Flask",
				module = "flask",
				env = {
					FLASK_APP = "app.py",
					FLASK_ENV = "development",
				},
				args = {
					"run",
					"--no-debugger",
					"--no-reload",
				},
				jinja = true,
				console = "integratedTerminal",
				cwd = "${workspaceFolder}",
			})

			table.insert(require("dap").configurations.python, {
				type = "python",
				request = "launch",
				name = "FastAPI",
				module = "uvicorn",
				args = {
					"main:app",
					"--reload",
				},
				console = "integratedTerminal",
				cwd = "${workspaceFolder}",
			})

			-- Keymaps for Python debugging
			local keymap = vim.keymap.set
			keymap("n", "<leader>dpr", function()
				require("dap-python").test_method()
			end, { desc = "Debug Python method" })

			keymap("n", "<leader>dpc", function()
				require("dap-python").test_class()
			end, { desc = "Debug Python class" })

			keymap("v", "<leader>dps", function()
				require("dap-python").debug_selection()
			end, { desc = "Debug Python selection" })
		end,
	},

	-- Python testing with pytest integration
	{
		"nvim-neotest/neotest-python",
		dependencies = {
			"nvim-neotest/neotest",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		ft = "python",
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-python")({
						-- Extra arguments for pytest
						args = { "--log-level", "DEBUG", "--verbose" },
						-- Runner to use (pytest, unittest, etc.)
						runner = "pytest",
						-- Custom python path
						python = function()
							-- Try to find venv python first
							local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
							if vim.fn.executable(venv_python) == 1 then
								return venv_python
							end
							-- Fallback to system python
							return "python3"
						end,
						-- pytest discovery
						pytest_discover_instances = true,
					}),
				},
				discovery = {
					enabled = false, -- Disable auto-discovery for performance
					concurrent = 1,
				},
				running = {
					concurrent = true,
				},
				summary = {
					enabled = true,
					expand_errors = true,
					follow = true,
				},
			})

			-- Python testing keymaps
			local keymap = vim.keymap.set
			keymap("n", "<leader>tr", function()
				require("neotest").run.run()
			end, { desc = "Run nearest test" })

			keymap("n", "<leader>tf", function()
				require("neotest").run.run(vim.fn.expand("%"))
			end, { desc = "Run file tests" })

			keymap("n", "<leader>td", function()
				require("neotest").run.run({ strategy = "dap" })
			end, { desc = "Debug nearest test" })

			keymap("n", "<leader>ts", function()
				require("neotest").summary.toggle()
			end, { desc = "Toggle test summary" })

			keymap("n", "<leader>to", function()
				require("neotest").output.open({ enter = true })
			end, { desc = "Show test output" })

			keymap("n", "<leader>tS", function()
				require("neotest").run.stop()
			end, { desc = "Stop test" })
		end,
	},

	-- Enhanced Python REPL integration
	{
		"Vigemus/iron.nvim",
		ft = "python",
		config = function()
			local iron = require("iron.core")

			iron.setup({
				config = {
					-- Whether a repl should be discarded or not
					scratch_repl = true,
					-- Your repl definitions come here
					repl_definition = {
						python = {
							-- Can be a table or a function that returns a table (see below)
							command = { "python3" },
							format = require("iron.fts.python").bracketed_paste,
						},
					},
					-- How the repl window will be displayed
					-- See below for more information
					repl_open_cmd = require("iron.view").bottom(40),
				},
				-- Iron doesn't set keymaps by default anymore.
				-- You can set them here or manually add keymaps to the config
				keymaps = {
					send_motion = "<space>sc",
					visual_send = "<space>sc",
					send_file = "<space>sf",
					send_line = "<space>sl",
					send_until_cursor = "<space>su",
					send_mark = "<space>sm",
					mark_motion = "<space>mc",
					mark_visual = "<space>mc",
					remove_mark = "<space>md",
					cr = "<space>s<cr>",
					interrupt = "<space>s<space>",
					exit = "<space>sq",
					clear = "<space>cl",
				},
				-- If the highlight is on, you can change how it looks
				-- For the available options, check nvim_set_hl
				highlight = {
					italic = true,
				},
				ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
			})

			-- Python REPL keymaps
			local keymap = vim.keymap.set
			keymap("n", "<leader>rs", "<cmd>IronRepl<cr>", { desc = "Start Python REPL" })
			keymap("n", "<leader>rr", "<cmd>IronRestart<cr>", { desc = "Restart Python REPL" })
			keymap("n", "<leader>rf", "<cmd>IronFocus<cr>", { desc = "Focus Python REPL" })
			keymap("n", "<leader>rh", "<cmd>IronHide<cr>", { desc = "Hide Python REPL" })
		end,
	},

	-- Docstring generation
	{
		"danymat/neogen",
		ft = "python",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("neogen").setup({
				snippet_engine = "luasnip",
				languages = {
					python = {
						template = {
							annotation_convention = "google_docstrings", -- Use Google style docstrings
						},
					},
				},
			})

			-- Docstring generation keymap
			vim.keymap.set("n", "<leader>ds", function()
				require("neogen").generate()
			end, { desc = "Generate docstring" })
		end,
	},

	-- Python virtual environment detection and switching
	{
		"linux-cultist/venv-selector.nvim",
		ft = "python",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-telescope/telescope.nvim",
			"mfussenegger/nvim-dap-python",
		},
		opts = {
			-- Options for venv-selector
			name = {
				"venv",
				".venv",
				"env",
				".env",
			},
			auto_refresh = false,
		},
		config = function(_, opts)
			require("venv-selector").setup(opts)

			-- Virtual environment keymap
			vim.keymap.set("n", "<leader>vs", "<cmd>VenvSelect<cr>", { desc = "Select Python venv" })
		end,
	},

	-- Python-specific text objects and motions
	{
		"jeetsukumaran/vim-pythonsense",
		ft = "python",
		config = function()
			-- Enhanced Python text objects
			-- ac/ic for classes
			-- af/if for functions
			-- ad/id for docstrings
			vim.g.is_pythonsense_suppress_motion_keymaps = 0
			vim.g.is_pythonsense_suppress_object_keymaps = 0
		end,
	},

	-- Jupyter notebook support in Neovim
	{
		"benlubas/molten-nvim",
		ft = "python",
		build = ":UpdateRemotePlugins",
		init = function()
			-- Configuration for molten
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = false
		end,
		config = function()
			-- Jupyter notebook keymaps
			local keymap = vim.keymap.set
			keymap("n", "<leader>mi", ":MoltenInit<CR>", { desc = "Initialize Molten" })
			keymap("n", "<leader>me", ":MoltenEvaluateOperator<CR>", { desc = "Evaluate operator" })
			keymap("n", "<leader>ml", ":MoltenEvaluateLine<CR>", { desc = "Evaluate line" })
			keymap("v", "<leader>mr", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Evaluate visual selection" })
			keymap("n", "<leader>mc", ":MoltenReevaluateCell<CR>", { desc = "Re-evaluate cell" })
			keymap("n", "<leader>md", ":MoltenDelete<CR>", { desc = "Delete Molten cell" })
			keymap("n", "<leader>mo", ":MoltenShowOutput<CR>", { desc = "Show output" })
			keymap("n", "<leader>mh", ":MoltenHideOutput<CR>", { desc = "Hide output" })
		end,
	},

	-- Enhanced Python syntax and semantic highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			if opts.ensure_installed ~= "all" then
				opts.ensure_installed = opts.ensure_installed or {}
				vim.list_extend(opts.ensure_installed, { "python", "rst" })
			end
		end,
	},

	-- Python import sorting and management
	{
		"stsewd/isort.nvim",
		ft = "python",
		build = ":UpdateRemotePlugins",
		config = function()
			vim.keymap.set("n", "<leader>si", ":Isort<CR>", { desc = "Sort Python imports" })
		end,
	},

	-- Python code completion enhancements
	{
		"hrsh7th/nvim-cmp",
		optional = true,
		dependencies = {
			{
				"hrsh7th/cmp-nvim-lsp-signature-help",
				ft = "python",
			},
		},
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			table.insert(opts.sources, { name = "nvim_lsp_signature_help" })
			return opts
		end,
	},
}
