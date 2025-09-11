return {
  "williamboman/mason.nvim",
  opts = {
    registries = {
      "github:mason-org/mason-registry",
      "github:Crashdummyy/mason-registry",
    },
    ensure_installed = {
      "lua-language-server",
      -- for some reason those have to be installed explicitely with MasonInstall
      "roslyn",
      "rzls",
      "netcoredbg",

      -- "csharp-language-server",
      -- "omnisharp",
      "prettier",                   -- prettier formatter
      "stylua",                     -- lua formatter
      "isort",                      -- python formatter
      "black",                      -- python formatter
      "ruff",                       -- python linting and formatting (replaces flake8, pylint, etc.)
      "mypy",                       -- python type checker
      "debugpy",                    -- python debugger
      "pylint",                     -- python linter (legacy support)
      "eslint_d",
      "prettier",                   -- TypeScript/JavaScript formatter
      "typescript-language-server", -- Alternative TypeScript LSP (backup)
      "js-debug-adapter",           -- JavaScript/TypeScript debugger
      "shfmt",                      -- shell script formatter
      "shellcheck",                 -- shell script linter
      "csharpier",                  -- C# formatter
      "xmlformatter",               -- XML formatter for C# projects
      -- Go development tools
      "gopls",                      -- Go language server
      "gofumpt",                    -- Go formatter (stricter than gofmt)
      "golangci-lint",              -- Go linter
      "delve",                      -- Go debugger
      -- Rust development tools
      "rustfmt",                    -- Rust formatter (standard)
      "rust-analyzer",              -- Rust LSP server
      "codelldb",                   -- LLDB-based debugger for Rust
      "taplo",                      -- TOML formatter and language server
    },
  },
}
