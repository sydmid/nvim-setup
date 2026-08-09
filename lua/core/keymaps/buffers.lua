local M = {}

local ignored_filetypes = {
  "NvimTree",
  "TelescopePrompt",
  "TelescopeResults",
  "lazy",
  "packer",
  "qf",
  "netrw",
  "help",
  "oil",
  "alpha",
  "snacks_terminal",
}

local ignored_buftypes = {
  "nofile",
  "prompt",
  "terminal",
  "help",
}

local function is_main_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local ft_ok, ft = pcall(function()
    return vim.bo[bufnr].filetype
  end)
  local bt_ok, bt = pcall(function()
    return vim.bo[bufnr].buftype
  end)
  if not ft_ok or not bt_ok then
    return false
  end

  local name_ok, name = pcall(vim.api.nvim_buf_get_name, bufnr)
  local buf_name = name_ok and name or ""

  return not vim.tbl_contains(ignored_filetypes, ft)
    and not vim.tbl_contains(ignored_buftypes, bt)
    and buf_name ~= ""
end

local function save_all_modified()
  local modified_count = 0

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
      if vim.bo[buf].buftype == "" then
        local ok, err = pcall(function()
          vim.api.nvim_buf_call(buf, function()
            vim.cmd("write")
          end)
        end)

        if ok then
          modified_count = modified_count + 1
        else
          local bufname = vim.api.nvim_buf_get_name(buf)
          local filename = vim.fn.fnamemodify(bufname, ":t")
          vim.notify("Error saving " .. filename .. ": " .. tostring(err), vim.log.levels.WARN)
        end
      end
    end
  end

  if modified_count > 0 then
    vim.notify("Saved " .. modified_count .. " modified buffer(s)", vim.log.levels.INFO)
  else
    vim.notify("No modified buffers to save", vim.log.levels.INFO)
  end
end

function M.setup()
  local map = vim.keymap.set

  map("n", "<leader>br", function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname == "" then
      vim.notify("Cannot reset buffer: No file associated", vim.log.levels.WARN)
      return
    end

    if vim.bo[0].modified then
      local choice = vim.fn.confirm("Buffer has unsaved changes. Reset anyway?", "&Yes\n&No", 2)
      if choice ~= 1 then
        return
      end
    end

    vim.cmd("edit!")
  end, { desc = "Reset buffer (reload from disk)" })

  map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete current buffer" })
  map({ "n", "i", "v" }, "<D-S-s>", save_all_modified, {
    desc = "Save all modified buffers",
    noremap = true,
    silent = true,
  })

  map({ "n", "t" }, "<D-b>", function()
    local current_buf = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())

    pcall(function()
      if package.loaded["symbols-outline"] then
        require("symbols-outline").close_outline()
        vim.defer_fn(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_buf_is_valid(buf) then
              local name_ok, name = pcall(vim.api.nvim_buf_get_name, buf)
              if name_ok and name:match("symbols%-outline") then
                pcall(vim.api.nvim_win_close, win, true)
              end
            end
          end
        end, 10)
      end
    end)

    local buffers_to_close = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(bufnr) and (bufnr ~= current_buf or not is_main_buffer(current_buf)) then
        if not is_main_buffer(bufnr) then
          local name_ok, buf_name = pcall(vim.api.nvim_buf_get_name, bufnr)
          local should_skip = false

          if name_ok and (buf_name:match("symbols%-outline") or buf_name:match("treesitter%-context")) then
            should_skip = true
          end

          if not should_skip then
            local ft_ok, ft = pcall(function()
              return vim.bo[bufnr].filetype
            end)
            if ft_ok and ft == "treesitter-context" then
              should_skip = true
            end
          end

          if not should_skip then
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
                local win_config = vim.api.nvim_win_get_config(win)
                if win_config.relative ~= "" and win_config.zindex and win_config.zindex >= 20 then
                  should_skip = true
                  break
                end
              end
            end
          end

          if not should_skip then
            table.insert(buffers_to_close, bufnr)
          end
        end
      end
    end

    for _, bufnr in ipairs(buffers_to_close) do
      pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
    end

    if not is_main_buffer(current_buf) then
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if is_main_buffer(buf) then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
    end
  end, { desc = "Close non-main buffers", silent = true })

  map("n", "<C-Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next tab", silent = true })
  map("n", "<C-S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous tab", silent = true })
  map("n", "<D-]>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next tab", silent = true })
  map("n", "<D-[>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous tab", silent = true })
  map("n", "<D-S-]>", "<cmd>BufferLineMoveNext<CR>", { desc = "Move tab right", silent = true })
  map("n", "<D-S-[>", "<cmd>BufferLineMovePrev<CR>", { desc = "Move tab left", silent = true })
  map("n", "<D-S-t>", "<cmd>edit #<CR>", { desc = "Reopen last closed tab/buffer", silent = true })
end

return M
