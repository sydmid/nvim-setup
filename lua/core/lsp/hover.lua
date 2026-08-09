local M = {}

local function normalize_hover(contents)
  local text = ""
  if type(contents) == "string" then
    text = contents
  elseif vim.tbl_islist(contents) then
    for _, v in ipairs(contents) do
      if type(v) == "string" then
        text = text .. v .. "\n"
      elseif type(v) == "table" and v.value then
        text = text .. v.value .. "\n"
      end
    end
  elseif type(contents) == "table" and contents.value then
    text = contents.value
  end

  return {
    kind = "markdown",
    value = text
      :gsub("\\%.", ".")
      :gsub("\\%-", "-")
      :gsub("\\%(", "(")
      :gsub("\\%[", "[")
      :gsub("\\%<", "<")
      :gsub("\\%)", ")")
      :gsub("\\%]", "]")
      :gsub("\\%>", ">")
      :gsub("\\%*", "*")
      :gsub("&nbsp;", " ")
      :gsub("\\_", "_")
      :gsub("\\`", "`"),
  }
end

function M.setup_handler(border)
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = border,
    focusable = true,
    style = "minimal",
    max_width = 80,
    max_height = 15,
    wrap = true,
    close_events = { "CursorMoved", "BufHidden" },
  })
end

function M.request_hover(border)
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP client attached to current buffer", vim.log.levels.WARN)
    return
  end

  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result, ctx, config)
    if err then
      vim.notify("LSP hover error: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    if not result or not result.contents then
      vim.notify("No hover information available", vim.log.levels.INFO)
      return
    end

    local opts = vim.tbl_extend("force", config or {}, {
      border = border,
      focusable = true,
      style = "minimal",
      max_width = 80,
      max_height = 15,
      wrap = true,
      close_events = { "BufHidden" },
    })

    local bufnr, winnr
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client and (client.name == "roslyn" or client.name == "gopls") then
      bufnr, winnr = vim.lsp.handlers["textDocument/hover"](err, { contents = normalize_hover(result.contents) }, ctx, opts)
    else
      bufnr, winnr = vim.lsp.handlers["textDocument/hover"](err, result, ctx, opts)
    end

    if not (winnr and vim.api.nvim_win_is_valid(winnr)) then
      return
    end

    vim.defer_fn(function()
      if not vim.api.nvim_win_is_valid(winnr) then
        return
      end

      local original_buf = vim.api.nvim_get_current_buf()

      vim.keymap.set("n", "<Tab>", function()
        if vim.api.nvim_win_is_valid(winnr) then
          vim.api.nvim_set_current_win(winnr)
        end
      end, { buffer = original_buf, desc = "Focus hover window", nowait = true })

      local hover_move_group = vim.api.nvim_create_augroup("LspHoverCursorClose_" .. winnr, { clear = true })
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = hover_move_group,
        buffer = original_buf,
        callback = function()
          if vim.api.nvim_get_current_win() ~= winnr then
            if vim.api.nvim_win_is_valid(winnr) then
              vim.api.nvim_win_close(winnr, true)
            end
            pcall(vim.api.nvim_del_augroup_by_id, hover_move_group)
            return true
          end
        end,
      })

      if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.keymap.set("n", "<Esc>", function()
          if vim.api.nvim_win_is_valid(winnr) then
            vim.api.nvim_win_close(winnr, true)
          end
        end, { buffer = bufnr, nowait = true, silent = true })

        vim.keymap.set("n", "q", function()
          if vim.api.nvim_win_is_valid(winnr) then
            vim.api.nvim_win_close(winnr, true)
          end
        end, { buffer = bufnr, nowait = true, silent = true })

        vim.keymap.set("n", "j", function()
          if vim.api.nvim_win_is_valid(winnr) then
            vim.api.nvim_win_call(winnr, function()
              vim.cmd("normal! j")
            end)
          end
        end, { buffer = bufnr, nowait = true, silent = true })

        vim.keymap.set("n", "k", function()
          if vim.api.nvim_win_is_valid(winnr) then
            vim.api.nvim_win_call(winnr, function()
              vim.cmd("normal! k")
            end)
          end
        end, { buffer = bufnr, nowait = true, silent = true })

        vim.keymap.set("n", "gx", function()
          local word = vim.fn.expand("<cWORD>")
          local url = word:match("%((.-)%)") or word:match("<(.-)>") or word
          url = url:match("https?://[%w%-%.%_%~%:%/%?#%[%]@!%$&'%(%)%*%+,;%%=]+")
          if url then
            vim.ui.open(url)
          else
            vim.notify("No URL found under cursor", vim.log.levels.WARN)
          end
        end, { buffer = bufnr, nowait = true, silent = true, desc = "Open URL under cursor" })

        vim.keymap.set("n", "<Esc>", function()
          if vim.api.nvim_win_is_valid(winnr) then
            vim.api.nvim_win_close(winnr, true)
            return
          end
          vim.cmd("nohlsearch")
        end, { buffer = original_buf, nowait = true, silent = true })

        vim.api.nvim_create_autocmd("WinClosed", {
          pattern = tostring(winnr),
          once = true,
          callback = function()
            pcall(vim.keymap.del, "n", "<Esc>", { buffer = original_buf })
          end,
        })
      end
    end, 10)

    local group = vim.api.nvim_create_augroup("LspHoverEscClose_" .. winnr, { clear = true })
    vim.api.nvim_create_autocmd("WinEnter", {
      group = group,
      callback = function()
        local current_win = vim.api.nvim_get_current_win()
        if current_win == winnr and vim.api.nvim_win_is_valid(winnr) then
          vim.keymap.set("n", "<Esc>", function()
            if vim.api.nvim_win_is_valid(winnr) then
              vim.api.nvim_win_close(winnr, true)
            end
          end, { buffer = bufnr, nowait = true, silent = true })
        end
      end,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
      pattern = tostring(winnr),
      once = true,
      callback = function()
        pcall(vim.api.nvim_del_augroup_by_id, group)
      end,
    })
  end)
end

return M
