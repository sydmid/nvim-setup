local M = {}

local state = { winnr = nil, total = 0, active = 0, src_buf = nil, params = nil }

local function cleanup()
  if state.src_buf and vim.api.nvim_buf_is_valid(state.src_buf) then
    pcall(vim.keymap.del, "n", "<Tab>", { buffer = state.src_buf })
    pcall(vim.keymap.del, "i", "<Tab>", { buffer = state.src_buf })
    pcall(vim.keymap.del, "n", "<S-Tab>", { buffer = state.src_buf })
    pcall(vim.keymap.del, "i", "<S-Tab>", { buffer = state.src_buf })
    pcall(vim.keymap.del, "n", "<Esc>", { buffer = state.src_buf })
  end

  state.winnr = nil
  state.total = 0
  state.active = 0
  state.src_buf = nil
  state.params = nil
end

function M.setup_handlers(border)
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = border,
    focusable = false,
    silent = true,
    close_events = { "CursorMoved", "BufHidden", "InsertLeave" },
    max_width = 80,
    max_height = 15,
    wrap = true,
    style = "minimal",
  })
end

function M.show_signature_with_index(border, override_index, custom_params, fallback_params)
  local params = custom_params or vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/signatureHelp", params, function(err, result, ctx, config)
    if err or not result or not result.signatures or #result.signatures == 0 then
      if fallback_params then
        M.show_signature_with_index(border, override_index, fallback_params, nil)
      end
      return
    end

    if override_index then
      result.activeSignature = override_index
    end

    local active = result.activeSignature or 0
    local total = #result.signatures
    local opts = vim.tbl_extend("force", config or {}, {
      border = border,
      focusable = false,
      style = "minimal",
      max_width = 80,
      max_height = 15,
      wrap = true,
      close_events = { "CursorMoved", "BufHidden", "InsertLeave" },
    })

    local _, winnr = vim.lsp.handlers["textDocument/signatureHelp"](err, result, ctx, opts)

    if state.winnr and state.winnr ~= winnr and vim.api.nvim_win_is_valid(state.winnr) then
      pcall(vim.api.nvim_win_close, state.winnr, true)
    end

    local src_buf = vim.api.nvim_get_current_buf()
    state.winnr = winnr
    state.total = total
    state.active = active
    state.src_buf = src_buf
    state.params = params

    if winnr and vim.api.nvim_win_is_valid(winnr) then
      vim.keymap.set("n", "<Esc>", function()
        if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
          vim.api.nvim_win_close(state.winnr, true)
        end
      end, { buffer = src_buf, desc = "Close signature help", silent = true })

      if total > 1 then
        vim.keymap.set({ "n", "i" }, "<Tab>", function()
          if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
            local next_idx = (state.active + 1) % state.total
            M.show_signature_with_index(border, next_idx, state.params, nil)
          end
        end, { buffer = src_buf, desc = "Next signature overload", silent = true })

        vim.keymap.set({ "n", "i" }, "<S-Tab>", function()
          if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
            local prev_idx = state.active > 0 and state.active - 1 or state.total - 1
            M.show_signature_with_index(border, prev_idx, state.params, nil)
          end
        end, { buffer = src_buf, desc = "Previous signature overload", silent = true })
      end

      vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(winnr),
        once = true,
        callback = cleanup,
      })
    end
  end)
end

function M.show_signature_help(border)
  local params = vim.lsp.util.make_position_params()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local fallback_params = nil

  if line:sub(col + 1, col + 1):match("[%w_]") then
    for i = col + 2, #line do
      local c = line:sub(i, i)
      if c == "(" then
        fallback_params = vim.deepcopy(params)
        fallback_params.position.character = i
        break
      elseif not c:match("[%w_.]") then
        break
      end
    end
  end

  M.show_signature_with_index(border, nil, params, fallback_params)
end

function M.previous_or_complete(border)
  if vim.fn.pumvisible() ~= 0 then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-p>", true, false, true), "n", false)
    return
  end

  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/signatureHelp", params, function(err, result, ctx, config)
    if result and result.signatures and #result.signatures > 1 then
      local current = result.activeSignature or 0
      local prev = current > 0 and current - 1 or #result.signatures - 1
      result.activeSignature = prev

      local opts = {
        border = border,
        focusable = true,
        style = "minimal",
        max_width = 80,
        max_height = 15,
        wrap = true,
      }
      vim.lsp.handlers["textDocument/signatureHelp"](err, result, ctx, vim.tbl_extend("force", config or {}, opts))
    else
      M.show_signature_help(border)
    end
  end)
end

function M.next_or_complete(border)
  if vim.fn.pumvisible() ~= 0 then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", false)
    return
  end

  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/signatureHelp", params, function(err, result, ctx, config)
    if result and result.signatures and #result.signatures > 1 then
      local current = result.activeSignature or 0
      result.activeSignature = (current + 1) % #result.signatures

      local opts = {
        border = border,
        focusable = true,
        style = "minimal",
        max_width = 80,
        max_height = 15,
        wrap = true,
      }
      vim.lsp.handlers["textDocument/signatureHelp"](err, result, ctx, vim.tbl_extend("force", config or {}, opts))
    else
      M.show_signature_help(border)
    end
  end)
end

return M
