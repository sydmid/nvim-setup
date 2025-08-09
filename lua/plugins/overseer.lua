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

			-- Function to open terminal and copy command
			local function open_terminal_with_command(cmd)
				-- Use Snacks terminal instead of vim terminal
				require("snacks").terminal.toggle()

				-- Wait a moment for terminal to initialize
				vim.defer_fn(function()
					-- Copy the command to clipboard
					vim.fn.setreg("+", cmd)
					vim.fn.setreg('"', cmd)

					-- Notify user that command is copied
					vim.notify("Command copied to clipboard: " .. cmd, vim.log.levels.INFO)

					-- Send the command to the terminal (but don't execute it)
					-- Remove the "i" prefix since Snacks terminal handles input differently
					vim.api.nvim_feedkeys(cmd, "n", false)
				end, 200) -- Slightly longer delay for Snacks terminal
			end			-- Define all your commands (scratch, dev, and terminal)
			local commands = {
				-- Scratch commands (these will be handled specially)
				{ name = "Rust: scratch", lang = "rs", type = "scratch" },
				{ name = "C: scratch", lang = "c", type = "scratch" },
				{ name = "Cpp: scratch", lang = "cpp", type = "scratch" },
				{ name = "TypeScript: scratch", lang = "ts", type = "scratch" },
				{ name = "Python: scratch", lang = "py", type = "scratch" },
				{ name = "Go: scratch", lang = "go", type = "scratch" },
				{ name = "C#: scratch", lang = "cs", type = "scratch" },
				{ name = "lua: scratch", lang = "lua", type = "scratch" },

				-- Terminal commands (open terminal with command copied)
				{ name = "Rust: cargo new --lib", cmd = "cargo new --lib ", type = "terminal" },
				{ name = "Rust: cargo new --bin", cmd = "cargo new --bin ", type = "terminal" },
				{ name = "Node: npm init", cmd = "npm init ", type = "terminal" },
				{ name = "Node: npm create vite@latest", cmd = "npm create vite@latest ", type = "terminal" },
				{ name = "Python: poetry new", cmd = "poetry new ", type = "terminal" },
				{ name = "Python: pip install", cmd = "pip install ", type = "terminal" },
				{ name = "Git: git clone", cmd = "git clone ", type = "terminal" },
				{ name = "Docker: docker run", cmd = "docker run ", type = "terminal" },
				{ name = "Go: go mod init", cmd = "go mod init ", type = "terminal" },

				-- Execute commands
				{
					name = "Rust: rustc $f -o $dir/$f-no-extension && $dir/$f-no-extension",
					cmd = 'rustc "${file}" -o "${fileDirname}/${fileBasenameNoExtension}" && "${fileDirname}/${fileBasenameNoExtension}"',
					type = "exec",
				},
				{
					name = "C: gcc $f -o $dir/$f-no-extension && $dir/$f-no-extension",
					cmd = 'gcc "${file}" -o "${fileDirname}/${fileBasenameNoExtension}" && "${fileDirname}/${fileBasenameNoExtension}"',
					type = "exec",
				},
				{
					name = "Cpp: g++ $f -o $dir/$f-no-extension && $dir/$f-no-extension",
					cmd = 'g++ "${file}" -o "${fileDirname}/${fileBasenameNoExtension}" && "${fileDirname}/${fileBasenameNoExtension}"',
					type = "exec",
				},
				{ name = "TS: node $f", cmd = 'node "${file}"', type = "exec" },
				{ name = "PY: python3 $f", cmd = 'python3 "${file}"', type = "exec" },
				{ name = "Go: go run $f", cmd = 'go run "${file}"', type = "exec" },
				{ name = "C#: dotnet $f", cmd = 'dotnet "${file}"', type = "exec" },
				{ name = "lua: lua $f", cmd = 'lua "${file}"', type = "exec" },
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
				elseif entry.type == "terminal" then
					-- Register terminal commands that open terminal with command copied
					overseer.register_template({
						name = entry.name,
						builder = function()
							-- Execute the terminal opening immediately
							open_terminal_with_command(entry.cmd)
							-- Return a dummy task that immediately succeeds
							return {
								cmd = { "echo" },
								args = { "Terminal opened with command: " .. entry.cmd },
								name = entry.name,
								components = { "on_complete_notify" },
							}
						end,
						priority = 55, -- Medium priority for terminal commands
						params = {},
					})
				else
					-- exec commands with simple terminal execution
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