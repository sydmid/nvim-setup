return {
  -- Code Runner - Fast and simple code execution
  {
    "CRAG666/code_runner.nvim",
    cmd = { "RunCode", "RunFile", "RunProject", "RunClose" },
    config = function()
      require("code_runner").setup({
        -- Choose default mode (valid options: 'single', 'float', 'toggle', 'buffer', 'terminal')
        mode = "float",

        -- Focus on the output window after running code
        focus = true,

        -- Start in insert mode after opening the output window
        startinsert = false,

        -- Window configuration for floating window
        float = {
          close_key = "<ESC>",
          border = "rounded",
          -- Dimensions
          height = 0.8,
          width = 0.8,
          x = 0.5,
          y = 0.5,
          -- Highlight
          border_hl = "FloatBorder",
          float_hl = "Normal",
          -- Transparency
          blend = 0,
        },

        -- Better split configuration
        better_term = {
          number = true,
          relativenumber = false,
        },

        -- File types and their run commands
        filetype = {
          java = {
            "cd $dir &&",
            "javac $fileName &&",
            "java $fileNameWithoutExt",
          },
          python = {
            "cd $dir &&",
            "if [ -f .venv/bin/python ]; then .venv/bin/python -u $fileName; else python3 -u $fileName; fi",
          },
          typescript = "deno run",
          rust = {
            "cd $dir &&",
            "rustc $fileName &&",
            "$dir/$fileNameWithoutExt",
          },
          javascript = "node",
          -- C programming language
          c = {
            "cd $dir &&",
            "gcc $fileName -o $fileNameWithoutExt &&",
            "$dir/$fileNameWithoutExt",
          },
          -- C++ programming language
          cpp = {
            "cd $dir &&",
            "g++ $fileName -o $fileNameWithoutExt &&",
            "$dir/$fileNameWithoutExt",
          },
          -- C# programming language (fish shell compatible)
          cs = {
            "set TEMP_DIR (mktemp -d); and",
            'cd "$TEMP_DIR"; and',
            "echo '<Project Sdk=\"Microsoft.NET.Sdk\"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net6.0</TargetFramework><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable></PropertyGroup></Project>' > project.csproj; and",
            "cp $file Program.cs; and",
            "dotnet run; and",
            "cd $dir; and",
            'rm -rf "$TEMP_DIR"',
          },
          -- Alternative C# for single file execution (requires dotnet-script)
          csharp = "dotnet script $fileName",
          go = "go run",
          lua = "lua",
          sh = "bash",
          bash = "bash",
          zsh = "zsh",
        },

        -- Project-level configurations
        project = {
          ["package.json"] = "npm start",
          ["Cargo.toml"] = "cargo run",
          ["go.mod"] = "go run .",
          ["Makefile"] = "make",
          -- C# project files
          ["*.csproj"] = "dotnet run",
          ["*.sln"] = "dotnet run",
          -- CMake for C/C++ projects
          ["CMakeLists.txt"] = "cmake . && make && ./main",
        },
      })

      -- Add custom keymap for 'q' to close code runner floating windows
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "crunner",
        callback = function()
          vim.keymap.set("n", "q", "<cmd>q<CR>", { buffer = true, silent = true })
        end,
      })
    end,
  },
}
