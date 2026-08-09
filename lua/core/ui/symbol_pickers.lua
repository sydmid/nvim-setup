local M = {}

local symbols = require("core.ui.symbols")

function M.open_ordered_symbols_picker()
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local results_lsp = symbols.fetch_lsp_symbols()
  if not results_lsp then
    return
  end

  local document_symbols = {}
  local function process_symbols(syms, level, prefix_order)
    level = level or 0
    prefix_order = prefix_order or ""

    local sorted_syms = symbols.sort_symbols_by_line(syms)
    for _, symbol in ipairs(sorted_syms) do
      local kind = symbol.kind or symbol.symbolKind or 1
      local icon_info = symbols.symbol_icons[kind] or { icon = "", name = "Unknown" }
      local line = symbols.get_symbol_line(symbol)
      local order_key = prefix_order .. string.format("%06d", line)

      table.insert(document_symbols, {
        symbol = symbol,
        kind = kind,
        icon = icon_info.icon,
        type_name = icon_info.name,
        name = symbol.name,
        indent = string.rep("  ", level),
        level = level,
        line = line,
        order_key = order_key,
        document_order = #document_symbols + 1,
      })

      if symbol.children and #symbol.children > 0 then
        process_symbols(symbol.children, level + 1, order_key .. "_")
      end
    end
  end

  for _, response in pairs(results_lsp) do
    if response.result then
      process_symbols(response.result)
    end
  end

  table.sort(document_symbols, function(a, b)
    return a.document_order < b.document_order
  end)

  if vim.tbl_isempty(document_symbols) then
    vim.notify("No symbols found in current buffer", vim.log.levels.WARN)
    return
  end

  local tp = require("helpers.telescope_pickers")
  tp.custom({
    prompt_title = "󰘦 Document Symbols (Document Order)",
    finder = finders.new_table({
      results = document_symbols,
      entry_maker = symbols.make_symbol_entry,
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.grep_previewer({}),
    mode = "insert",
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        symbols.jump_to_symbol(selection)
      end)
      return true
    end,
  })
end

function M.open_symbol_type_filter_picker()
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local results_lsp = symbols.fetch_lsp_symbols()
  if not results_lsp then
    return
  end

  local document_symbols = {}
  local function process_symbols(syms, level)
    level = level or 0

    local sorted_syms = symbols.sort_symbols_by_line(syms)
    for _, symbol in ipairs(sorted_syms) do
      local kind = symbol.kind or symbol.symbolKind or 1
      local icon_info = symbols.symbol_icons[kind] or { icon = "", name = "Unknown" }
      local line = symbols.get_symbol_line(symbol)

      table.insert(document_symbols, {
        symbol = symbol,
        kind = kind,
        icon = icon_info.icon,
        type_name = icon_info.name,
        name = symbol.name,
        indent = string.rep("  ", level),
        line = line,
      })

      if symbol.children and #symbol.children > 0 then
        process_symbols(symbol.children, level + 1)
      end
    end
  end

  for _, response in pairs(results_lsp) do
    if response.result then
      process_symbols(response.result)
    end
  end

  if vim.tbl_isempty(document_symbols) then
    vim.notify("No symbols found in current buffer", vim.log.levels.WARN)
    return
  end

  local type_counts = {}
  for _, sym in ipairs(document_symbols) do
    type_counts[sym.type_name] = (type_counts[sym.type_name] or 0) + 1
  end

  local type_options = { { name = "All", count = #document_symbols, icon = "󰒺" } }
  local ordered_types = {
    { name = "Class", icon = "󰠱" },
    { name = "Interface", icon = "󰜰" },
    { name = "Enum", icon = "󰕘" },
    { name = "Function", icon = "󰡱" },
    { name = "Method", icon = "󰊕" },
    { name = "Constructor", icon = "󰆧" },
    { name = "Property", icon = "󰜢" },
    { name = "Field", icon = "󰓹" },
    { name = "Variable", icon = "󰀫" },
    { name = "Constant", icon = "󰏿" },
    { name = "Module", icon = "󰏖" },
    { name = "Namespace", icon = "󰌗" },
    { name = "Struct", icon = "󰙅" },
    { name = "Event", icon = "󰉁" },
  }

  for _, type_info in ipairs(ordered_types) do
    if type_counts[type_info.name] then
      table.insert(type_options, {
        name = type_info.name,
        count = type_counts[type_info.name],
        icon = type_info.icon,
      })
    end
  end

  local function create_filtered_picker(filter_type)
    local filtered_symbols = document_symbols
    if filter_type ~= "All" then
      filtered_symbols = vim.tbl_filter(function(sym)
        return sym.type_name == filter_type
      end, document_symbols)
    end

    local tp = require("helpers.telescope_pickers")
    tp.custom({
      prompt_title = "󰘦 Filtered Symbols - " .. filter_type .. " (" .. #filtered_symbols .. ")",
      finder = finders.new_table({
        results = filtered_symbols,
        entry_maker = symbols.make_symbol_entry,
      }),
      sorter = conf.generic_sorter({}),
      previewer = conf.grep_previewer({}),
      mode = "normal",
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          symbols.jump_to_symbol(selection)
        end)
        return true
      end,
    })
  end

  local tp = require("helpers.telescope_pickers")
  tp.custom({
    prompt_title = "󰈺 Filter by Symbol Type",
    finder = finders.new_table({
      results = type_options,
      entry_maker = function(entry)
        return {
          value = entry,
          display = string.format("%s %s (%d)", entry.icon, entry.name, entry.count),
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    mode = "normal",
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          create_filtered_picker(selection.value.name)
        end
      end)
      return true
    end,
  })
end

return M
