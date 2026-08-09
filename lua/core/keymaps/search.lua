local M = {}

local function search_visual_selection()
  vim.cmd("normal! y")
  local text = vim.fn.getreg('"')
  text = vim.fn.escape(text, [[\/]])
  vim.fn.feedkeys("/" .. text .. "\n", "n")
end

local function get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local line = vim.fn.getline(start_pos[2])
  local start_col = start_pos[3]
  local end_col = end_pos[3]

  if vim.fn.visualmode() == "\22" then
    local lines = {}
    for line_num = start_pos[2], end_pos[2] do
      local line_text = vim.fn.getline(line_num)
      table.insert(lines, string.sub(line_text, start_col, end_col))
    end
    return table.concat(lines, "\n")
  end

  if start_pos[2] ~= end_pos[2] then
    local lines = vim.fn.getline(start_pos[2], end_pos[2])
    if type(lines) == "string" then
      lines = { lines }
    end
    if #lines > 0 then
      lines[1] = string.sub(lines[1], start_col)
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
      return table.concat(lines, "\n")
    end
    return ""
  end

  return string.sub(line, start_col, end_col)
end

function M.setup()
  local map = vim.keymap.set

  map("x", "/", search_visual_selection, { noremap = true, silent = true })
  map("n", "<D-f>", "/", { desc = "Search (/) in normal mode", noremap = true, silent = true })
  map("x", "<D-f>", search_visual_selection, { noremap = true, silent = true })

  map("x", "<D-r>", function()
    local selection = get_visual_selection()
    if selection and selection ~= "" then
      vim.api.nvim_input("<Esc>:%s/" .. vim.fn.escape(selection, "/\\[]^$.*") .. "//gc<Left><Left><Left>")
    end
  end, { desc = "Find and replace selected text", silent = true })

  map("n", "<D-r>", function()
    vim.ui.input({ prompt = "Search pattern: " }, function(search_pattern)
      if search_pattern and search_pattern ~= "" then
        vim.ui.input({ prompt = "Replace with: " }, function(replace_with)
          if replace_with ~= nil then
            local confirm = "c"
            vim.ui.input({ prompt = "Confirm each replacement? (y/n): " }, function(answer)
              if answer and string.lower(answer) == "n" then
                confirm = ""
              end
              vim.cmd(
                ":%s/"
                  .. vim.fn.escape(search_pattern, "/\\[]^$.*")
                  .. "/"
                  .. vim.fn.escape(replace_with, "/\\[]^$.*")
                  .. "/g"
                  .. confirm
              )
            end)
          end
        end)
      end
    end)
  end, { desc = "Find and replace dialog", silent = true })

  map("n", "<leader>R", '<cmd>lua require("spectre").toggle()<CR>', { desc = "Toggle Spectre" })
  map("n", "<leader>rw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "Search current word",
  })
  map("v", "<leader>rw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search current word",
  })
  map("n", "<leader>rp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    desc = "Search on current file",
  })
end

return M
