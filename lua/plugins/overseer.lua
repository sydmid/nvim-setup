-- Overseer.nvim - Task runner for scratch and dev commands
return {
	{
		"stevearc/overseer.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"folke/which-key.nvim",
		},
		event = "VeryLazy",
		opts = {
			templates = {},
			strategy = "terminal",
			dap = false,
		},
		config = function()
			local overseer = require("overseer")

			-- Setup overseer with custom configuration
			overseer.setup({
				templates = {},
				strategy = "terminal", -- Use basic terminal strategy
				dap = false,
				component_aliases = {
					default = {
						"display_duration",
						"on_output_summarize",
						"on_exit_set_status",
						"on_complete_notify",
					},
				},
			})

			-- Converts VSCode-style placeholders to Neovim values
			local function expand_vars(cmd)
				return cmd
					:gsub("${file}", vim.fn.expand("%:p"))
					:gsub("${fileDirname}", vim.fn.expand("%:p:h"))
					:gsub("${fileBasename}", vim.fn.expand("%:t"))
					:gsub("${fileBasenameNoExtension}", vim.fn.expand("%:t:r"))
					:gsub("${relativeFile}", vim.fn.expand("%"))
					:gsub("${workspaceFolder}", vim.fn.getcwd())
			end

			-- Function to create scratch files and open them in Neovim
			local function create_scratch_file(lang)
				local base_dir = vim.fn.expand("~/Desktop/temp")
				local target_dir = base_dir .. "/" .. lang
				vim.fn.system("mkdir -p " .. vim.fn.shellescape(target_dir))

				local timestamp = os.date("%Y%m%d%H%M%S")
				local filename = target_dir .. "/scratch-" .. timestamp .. "." .. lang

				-- Add starter templates
				local templates = {
					rs = "fn main() {\n    \n}",
					c = "#include <stdio.h>\n\nint main() {\n    return 0;\n}",
					cpp = "#include <iostream>\n\nint main() {\n    return 0;\n}",
					ts = "function main() {\n    \n}\n\nmain();",
					py = "def main():\n    pass\n\nif __name__ == '__main__':\n    main()",
					go = 'package main\n\nimport "fmt"\n\nfunc main() {\n    fmt.Println("Hello, Go")\n}',
					cs = 'using System;\n\nclass Program {\n    static void Main(string[] args) {\n        Console.WriteLine("Hello, C#");\n    }\n}',
				}

				local content = templates[lang] or ""

				-- Write the template content to the file
				local file = io.open(filename, "w")
				if file then
					file:write(content)
					file:close()
				end

				-- Change the working directory to the target directory
				vim.cmd("cd " .. vim.fn.fnameescape(target_dir))

				-- Open the file in Neovim
				vim.cmd("edit " .. vim.fn.fnameescape(filename))
			end

			-- Define all your commands (both scratch and dev)
			local commands = {
				-- Scratch commands (these will be handled specially)
				{ name = "SCRATCH: Rust", lang = "rs", type = "scratch" },
				{ name = "SCRATCH: C", lang = "c", type = "scratch" },
				{ name = "SCRATCH: Cpp", lang = "cpp", type = "scratch" },
				{ name = "SCRATCH: TypeScript", lang = "ts", type = "scratch" },
				{ name = "SCRATCH: Python", lang = "py", type = "scratch" },
				{ name = "SCRATCH: Go", lang = "go", type = "scratch" },
				{ name = "SCRATCH: C#", lang = "cs", type = "scratch" },
				{ name = "SCRATCH: lua", lang = "lua", type = "scratch" },

				-- Dev commands
				{
					name = "Rust: Compile & Run (Rustc)",
					cmd = 'rustc "${file}" -o "${fileDirname}/${fileBasenameNoExtension}" && "${fileDirname}/${fileBasenameNoExtension}"',
					type = "dev",
				},
				{
					name = "DEV: Compile & Run C",
					cmd = 'gcc "${file}" -o "${fileDirname}/${fileBasenameNoExtension}" && "${fileDirname}/${fileBasenameNoExtension}"',
					type = "dev",
				},
				{
					name = "DEV: Compile & Run Cpp",
					cmd = 'g++ "${file}" -o "${fileDirname}/${fileBasenameNoExtension}" && "${fileDirname}/${fileBasenameNoExtension}"',
					type = "dev",
				},
				{ name = "DEV: Run TypeScript (node)", cmd = 'node "${file}"', type = "dev" },
				{ name = "DEV: Run Python", cmd = 'python3 "${file}"', type = "dev" },
				{ name = "DEV: Run Go", cmd = 'go run "${file}"', type = "dev" },
				{ name = "DEV: Run C# (dotnet)", cmd = 'dotnet "${file}"', type = "dev" },
				{ name = "DEV: Run lua", cmd = 'lua "${file}"', type = "dev" },
			}

			-- Register all commands as overseer tasks
			for _, entry in ipairs(commands) do
				if entry.type == "scratch" then
					-- Register scratch commands as custom tasks
					overseer.register_template({
						name = entry.name,
						builder = function()
							-- Execute the scratch file creation immediately
							create_scratch_file(entry.lang)
							-- Return a dummy task that immediately succeeds
							return {
								cmd = { "echo" },
								args = { "Scratch file created and opened" },
								name = entry.name,
								components = { "on_complete_notify" },
							}
						end,
						priority = 60, -- Higher priority for scratch commands
						params = {},
					})
				else
					-- Register dev commands with simple terminal execution
					overseer.register_template({
						name = entry.name,
						builder = function()
							local expanded_cmd = expand_vars(entry.cmd)

							-- Simple terminal task that opens output automatically
							return {
								cmd = { "fish", "-c" },
								args = { expanded_cmd },
								name = entry.name,
								components = {
									"default",
									"on_complete_notify",
									{ "open_output", on_start = "always" },
								},
							}
						end,
						condition = {
							callback = function()
								-- Dev commands only when we have a file
								return vim.fn.expand("%") ~= ""
							end,
						},
						priority = 50,
						params = {},
					})
				end
			end

			-- Register keymaps following your configuration pattern
			local map = vim.keymap.set

			-- Main overseer menu on "-" key
			map("n", "-", function()
				vim.cmd("OverseerRun")
			end, { desc = "Run Scratch or Dev Command", noremap = true, silent = true })

			-- Integration with existing Which-Key groups
			local wk_ok, wk = pcall(require, "which-key")
			if wk_ok then
				wk.add({
					{ "-", desc = "󱓞 Run Scratch/Dev Command" },
				})
			end
		end,
	},
}