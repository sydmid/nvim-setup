local M = {}

function M.setup()
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { ".bashrc", ".zshrc", ".bash_profile", ".profile", ".zsh_*", ".bash_*", ".env" },
    callback = function(ev)
      vim.bo[ev.buf].filetype = "sh"
    end,
  })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.py", "*.pyi", "*.pyw", ".pythonrc", "SConstruct", "SConscript", "*.wsgi" },
    callback = function(ev)
      vim.bo[ev.buf].filetype = "python"
    end,
  })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.rs", "*.rlib" },
    callback = function(ev)
      vim.bo[ev.buf].filetype = "rust"
    end,
  })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.toml", "Cargo.toml", "Cargo.lock", "pyproject.toml" },
    callback = function(ev)
      vim.bo[ev.buf].filetype = "toml"
    end,
  })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.go", "go.mod", "go.sum", "go.work", "go.work.sum", "*.gotmpl" },
    callback = function(ev)
      local filename = vim.fn.expand("%:t")
      if filename == "go.mod" or filename == "go.work" then
        vim.bo[ev.buf].filetype = "gomod"
      elseif filename == "go.sum" or filename == "go.work.sum" then
        vim.bo[ev.buf].filetype = "gosum"
      elseif vim.fn.expand("%:e") == "gotmpl" then
        vim.bo[ev.buf].filetype = "gotmpl"
      else
        vim.bo[ev.buf].filetype = "go"
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.ts", "*.tsx", "*.js", "*.jsx", "*.mjs", "*.cjs" },
    callback = function(ev)
      local ext = vim.fn.expand("%:e")
      if ext == "ts" then
        vim.bo[ev.buf].filetype = "typescript"
      elseif ext == "tsx" then
        vim.bo[ev.buf].filetype = "typescriptreact"
      elseif ext == "js" or ext == "mjs" or ext == "cjs" then
        vim.bo[ev.buf].filetype = "javascript"
      elseif ext == "jsx" then
        vim.bo[ev.buf].filetype = "javascriptreact"
      end
    end,
  })
end

return M
