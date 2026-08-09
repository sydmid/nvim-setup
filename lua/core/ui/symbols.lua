local M = {}

M.theme_opts = {
  styles = {
    type = { bold = true },
    lsp = { underline = false },
    match_paren = { underline = true },
    functions = { bold = true },
    keywords = { bold = true },
    comments = { italic = true },
  },
}

M.symbol_icons = {
  [1] = { icon = "󰈔", name = "File" },
  [2] = { icon = "󰏖", name = "Module" },
  [3] = { icon = "󰌗", name = "Namespace" },
  [4] = { icon = "󰏗", name = "Package" },
  [5] = { icon = "󰠱", name = "Class" },
  [6] = { icon = "󰊕", name = "Method" },
  [7] = { icon = "󰜢", name = "Property" },
  [8] = { icon = "󰓹", name = "Field" },
  [9] = { icon = "󰆧", name = "Constructor" },
  [10] = { icon = "󰕘", name = "Enum" },
  [11] = { icon = "󰜰", name = "Interface" },
  [12] = { icon = "󰡱", name = "Function" },
  [13] = { icon = "󰀫", name = "Variable" },
  [14] = { icon = "󰏿", name = "Constant" },
  [15] = { icon = "󰀬", name = "String" },
  [16] = { icon = "󰎠", name = "Number" },
  [17] = { icon = "󰨙", name = "Boolean" },
  [18] = { icon = "󰅪", name = "Array" },
  [19] = { icon = "󰅩", name = "Object" },
  [20] = { icon = "󰌋", name = "Key" },
  [21] = { icon = "󰟢", name = "Null" },
  [22] = { icon = "󰕘", name = "EnumMember" },
  [23] = { icon = "󰙅", name = "Struct" },
  [24] = { icon = "󰉁", name = "Event" },
  [25] = { icon = "󰆕", name = "Operator" },
  [26] = { icon = "󰊄", name = "TypeParameter" },
}

function M.get_symbol_line(symbol)
  if symbol.location and symbol.location.range then
    return symbol.location.range.start.line
  elseif symbol.selectionRange then
    return symbol.selectionRange.start.line
  elseif symbol.range then
    return symbol.range.start.line
  end
  return 0
end

function M.sort_symbols_by_line(symbols)
  local sorted = vim.deepcopy(symbols)
  table.sort(sorted, function(a, b)
    return M.get_symbol_line(a) < M.get_symbol_line(b)
  end)
  return sorted
end

function M.make_symbol_entry(entry)
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  return {
    value = entry,
    display = string.format("%s%s %s", entry.indent, entry.icon, entry.name),
    ordinal = entry.name .. " " .. entry.type_name,
    symbol = entry.symbol,
    kind = entry.kind,
    type_name = entry.type_name,
    filename = filename,
    lnum = entry.line + 1,
    col = 1,
    bufnr = bufnr,
    path = filename,
    row = entry.line + 1,
    start = entry.line + 1,
  }
end

function M.jump_to_symbol(selection)
  if not (selection and selection.symbol) then
    return
  end

  local symbol = selection.symbol
  local range = symbol.location and symbol.location.range or symbol.selectionRange or symbol.range
  if not range then
    return
  end

  local line = range.start.line + 1
  local col = range.start.character
  vim.api.nvim_win_set_cursor(0, { line, col })
  vim.cmd("normal! zz")

  if vim.fn.has("nvim-0.9") == 1 then
    vim.cmd("normal! ^")
    local ns_id = vim.api.nvim_create_namespace("symbol_jump")
    vim.api.nvim_buf_add_highlight(0, ns_id, "Search", line - 1, 0, -1)
    vim.defer_fn(function()
      vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end, 150)
  end

  vim.notify(string.format("Jumped to %s: %s (line %d)", selection.type_name, selection.value.name, line), vim.log.levels.INFO)
end

function M.fetch_lsp_symbols()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No active LSP clients found", vim.log.levels.WARN)
    return nil
  end

  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  local results_lsp = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 3000)
  if not results_lsp or vim.tbl_isempty(results_lsp) then
    vim.notify("No LSP symbols found", vim.log.levels.WARN)
    return nil
  end

  return results_lsp
end

return M
