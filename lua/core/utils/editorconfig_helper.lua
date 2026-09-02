local M = {}

-- Boilerplate .editorconfig templates for different languages
local templates = {
  csharp = [[
# C# .editorconfig enforcing K&R (same-line braces)
root = true

[*.cs]
charset = utf-8-bom
end_of_line = crlf
insert_final_newline = true

indent_style = space
indent_size = 4
trim_trailing_whitespace = true

csharp_new_line_before_open_brace = none
csharp_prefer_braces = true:suggestion
csharp_new_line_before_else = false
csharp_new_line_before_catch = false
csharp_new_line_before_finally = false

csharp_style_expression_bodied_methods = false:suggestion
csharp_style_expression_bodied_properties = false:suggestion
]],

  javascript = [[
# JavaScript/TypeScript .editorconfig
root = true

[*.{js,jsx,ts,tsx}]
charset = utf-8
indent_style = space
indent_size = 2
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
]],

  python = [[
# Python .editorconfig (PEP 8)
root = true

[*.py]
charset = utf-8
indent_style = space
indent_size = 4
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
]],

  go = [[
# Go .editorconfig
root = true

[*.go]
charset = utf-8
indent_style = tab
indent_size = 4
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
]],
}

-- Write chosen template to .editorconfig in project root
function M.write_editorconfig(lang)
  local cwd = vim.fn.getcwd()
  local dest = cwd .. "/.editorconfig"

  if vim.fn.filereadable(dest) == 1 then
    local choice = vim.fn.input(".editorconfig already exists. Overwrite? (y/N): ")
    if choice:lower() ~= "y" then
      vim.notify("Aborted: existing .editorconfig kept.", vim.log.levels.WARN)
      return
    end
  end

  local content = templates[lang]
  if not content then
    vim.notify("No template found for language: " .. lang, vim.log.levels.ERROR)
    return
  end

  local f = io.open(dest, "w")
  f:write(content)
  f:close()

  vim.notify("Wrote " .. lang .. " .editorconfig to " .. dest, vim.log.levels.INFO)
end

-- Default keymaps (leader + eX where X = language)
vim.keymap.set("n", "<leader>ec", function() M.write_editorconfig("csharp") end,
  { desc = "Write C# .editorconfig" })
vim.keymap.set("n", "<leader>ej", function() M.write_editorconfig("javascript") end,
  { desc = "Write JS/TS .editorconfig" })
vim.keymap.set("n", "<leader>ep", function() M.write_editorconfig("python") end,
  { desc = "Write Python .editorconfig" })
vim.keymap.set("n", "<leader>eg", function() M.write_editorconfig("go") end,
  { desc = "Write Go .editorconfig" })

return M
