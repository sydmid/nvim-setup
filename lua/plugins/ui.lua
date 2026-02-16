-- Global variables to track current background mode
_G.background_modes = {
  { bg = "#282c34", secondary = "#373c47", cursorline = "#303640", name = "Light",  opacity = false },
  { bg = "#1f1f19", secondary = "#34342a", cursorline = "#333227", name = "Warm",   opacity = false },
  { bg = "#0f1419", secondary = "#1c262f", cursorline = "#1a1f29", name = "Bluish", opacity = false },
  { bg = "#121212", secondary = "#313131", cursorline = "#272727", name = "Dark",   opacity = false },
  { bg = "#121212", secondary = "#313131", cursorline = "#272727", name = "Glass",  opacity = true, opacity_value = 0 } -- (opacity_value is not working for some reason)
}
_G.current_bg_index = 1

-- Function to set background mode
function _G.set_background_mode(mode_index)
  if mode_index < 1 or mode_index > #_G.background_modes then
    mode_index = 1
  end

  _G.current_bg_index = mode_index
  local mode = _G.background_modes[mode_index]

  -- Handle opacity settings
  if mode.opacity then
    -- Set transparency for the colorscheme
    vim.g.molokaiTransparent = true
    -- Apply opacity using winblend for floating windows
    vim.opt.winblend = mode.opacity_value
    vim.opt.pumblend = mode.opacity_value
  else
    -- Disable transparency
    vim.g.molokaiTransparent = false
    vim.opt.winblend = 0
    vim.opt.pumblend = 0
  end

  -- Apply custom background highlights
  local bg_highlights = {
    Normal = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    NormalFloat = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    SignColumn = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    LineNr = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    CursorLine = mode.opacity and { bg = "NONE" } or { bg = mode.cursorline },
    CursorLineNr = mode.opacity and { bg = "NONE" } or { bg = mode.cursorline },
    StatusLine = mode.opacity and { bg = "NONE" } or { bg = mode.cursorline },
    TabLineFill = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    Pmenu = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    PmenuBorder = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    TelescopeNormal = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    TelescopeBorder = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    TelescopeResultsNormal = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    TelescopeResultsBorder = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    TelescopePreviewNormal = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    TelescopePreviewBorder = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    TelescopePromptNormal = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    TelescopePromptBorder = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    NoiceCmdlinePopup = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    NoiceCmdlinePopupBorder = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    NoicePopup = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    NoicePopupBorder = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    NoiceConfirm = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    NoiceConfirmBorder = mode.opacity and { bg = "NONE" } or { bg = mode.bg },
    TreesitterContext = mode.opacity and { bg = "NONE" } or { bg = mode.secondary },
    TreesitterContextLineNumber = mode.opacity and { bg = "NONE" } or { bg = mode.secondary },
  }

  -- Apply the highlights
  for group, opts in pairs(bg_highlights) do
    local current_hl = vim.api.nvim_get_hl(0, { name = group })
    vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", current_hl, opts))
  end

  _G.save_background_preference()
  local opacity_text = mode.opacity and (" (" .. mode.opacity_value .. "% opacity)") or ""
  vim.notify("Background mode: " .. mode.name .. opacity_text, vim.log.levels.INFO)
end

-- Function to cycle through background modes
function _G.toggle_background_mode()
  local next_index = (_G.current_bg_index % #_G.background_modes) + 1
  _G.set_background_mode(next_index)
end

-- Function to save background preference
function _G.save_background_preference()
  local bg_file = vim.fn.stdpath("data") .. "/background_preference.lua"
  local file = io.open(bg_file, "w")
  if file then
    file:write("return {\n")
    file:write("  mode_index = " .. _G.current_bg_index .. "\n")
    file:write("}\n")
    file:close()
  end
end

-- Function to load background preference
function _G.load_background_preference()
  local bg_file = vim.fn.stdpath("data") .. "/background_preference.lua"
  if vim.fn.filereadable(bg_file) == 1 then
    local ok, prefs = pcall(dofile, bg_file)
    if ok and prefs and prefs.mode_index then
      _G.current_bg_index = prefs.mode_index
    end
  end
end

-- Function to create a Telescope background mode picker
function _G.telescope_background_picker()
  if not pcall(require, "telescope") then
    vim.notify("Telescope not available", vim.log.levels.WARN)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local mode_info = {}
  for i, mode in ipairs(_G.background_modes) do
    local opacity_text = mode.opacity and string.format(" (Opacity: %d%%)", mode.opacity_value) or ""
    local display_text = mode.name

    table.insert(mode_info, {
      index = i,
      name = mode.name,
      bg = mode.bg,
      cursorline = mode.cursorline,
      opacity = mode.opacity,
      opacity_value = mode.opacity_value,
      display = display_text,
      description = mode.opacity and
          string.format("Transparent background with %d%% opacity", mode.opacity_value) or
          string.format("Background: %s, Active line: %s", mode.bg, mode.cursorline)
    })
  end

  pickers.new({}, {
    prompt_title = "Background Selector (Current: " .. _G.background_modes[_G.current_bg_index].name .. ")",
    initial_mode = "insert",
    finder = finders.new_table({
      results = mode_info,
      entry_maker = function(entry)
        local display_text = entry.display
        -- Add current mode indicator
        if entry.index == _G.current_bg_index then
          display_text = "✓ " .. entry.display .. " 🎯 (CURRENT)"
        end

        return {
          value = entry.index,
          display = display_text,
          ordinal = entry.name .. " " .. entry.display,
          mode_info = entry,
          is_current = entry.index == _G.current_bg_index
        }
      end
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          _G.set_background_mode(selection.value)
        end
      end)
      return true
    end,
  }):find()
end

local theme_opts = {
  styles = {
    type = { bold = true },
    lsp = { underline = false },
    match_paren = { underline = true },
    functions = { bold = true },  -- Make functions bolder for better contrast
    keywords = { bold = true },   -- Make keywords bolder
    comments = { italic = true }, -- Make comments italic for distinction
  },
}

-- Shared LSP Symbol kinds mapping with icons (used by both symbol pickers)
local symbol_icons = {
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

-- Get the start line number from a symbol (handles different LSP response formats)
local function get_symbol_line(symbol)
  if symbol.location and symbol.location.range then
    return symbol.location.range.start.line
  elseif symbol.selectionRange then
    return symbol.selectionRange.start.line
  elseif symbol.range then
    return symbol.range.start.line
  end
  return 0
end

-- Sort a list of symbols by their line number
local function sort_symbols_by_line(syms)
  local sorted = vim.deepcopy(syms)
  table.sort(sorted, function(a, b)
    return get_symbol_line(a) < get_symbol_line(b)
  end)
  return sorted
end

-- Create a telescope entry from a processed symbol entry
local function make_symbol_entry(entry)
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

-- Jump to a symbol with visual feedback
local function jump_to_symbol(selection)
  if not (selection and selection.symbol) then return end
  local symbol = selection.symbol
  local range = symbol.location and symbol.location.range
      or symbol.selectionRange
      or symbol.range
  if not range then return end

  local line = range.start.line + 1
  local col = range.start.character
  vim.api.nvim_win_set_cursor(0, { line, col })
  vim.cmd("normal! zz")

  if vim.fn.has('nvim-0.9') == 1 then
    vim.cmd("normal! ^")
    local ns_id = vim.api.nvim_create_namespace("symbol_jump")
    vim.api.nvim_buf_add_highlight(0, ns_id, "Search", line - 1, 0, -1)
    vim.defer_fn(function()
      vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end, 150)
  end

  vim.notify(string.format("Jumped to %s: %s (line %d)",
      selection.type_name, selection.value.name, line),
    vim.log.levels.INFO)
end

-- Fetch and return LSP document symbols, or nil on failure
local function fetch_lsp_symbols()
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

return {
  -- ColorScheme
  {
    "Ferouk/bearded-nvim",
    lazy = false,
    name = "bearded",
    config = function()
      -- Load saved background preference
      _G.load_background_preference()
    require("bearded").setup({
      flavor = "arc", -- any flavor slug
    })

      -- Set the colorscheme
      vim.opt.background = "dark"
      vim.cmd.colorscheme("bearded")

      -- Apply the current background mode
      _G.set_background_mode(_G.current_bg_index)

      -- Create autocmd to reapply background highlights when colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "bearded",
        group = vim.api.nvim_create_augroup("AyuBackground", { clear = true }),
        callback = function()
          -- Reapply current background mode
          _G.set_background_mode(_G.current_bg_index)
        end,
      })

      -- Additional autocmd to fix Telescope backgrounds specifically
      vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
        pattern = { "TelescopePrompt", "TelescopeResults", "TelescopePreview" },
        group = vim.api.nvim_create_augroup("TelescopeBackgroundFix", { clear = true }),
        callback = function()
          -- Reapply telescope highlights from current background mode
          local mode = _G.background_modes[_G.current_bg_index]
          if mode then
            local bg_value = mode.opacity and "NONE" or mode.bg
            vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = bg_value })
            vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = bg_value })
            vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = bg_value })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = bg_value })
            vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = bg_value })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = bg_value })
            vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = bg_value })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = bg_value })
          end
        end,
      })

      vim.keymap.set("n", "<leader>tt", function()
        _G.telescope_background_picker()
      end, { desc = "Change Background", silent = true })
    end,
    lazy = false
  },
  -- Highlight yanked text with enhanced styling
  {
    "machakann/vim-highlightedyank",
    event = "VeryLazy",
    config = function()
      -- Enhanced yank highlight with no-clown-fiesta colors
      vim.g.highlightedyank_highlight_duration = 200
    end,
  },
  -- hlchunk.nvim - Beautiful animated indentation and chunk highlighting
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        -- Chunk highlighting with beautiful animations
        chunk = {
          enable = true,
          priority = 15,
          use_treesitter = true,
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
          },
          textobject = "ic",           -- Inner chunk textobject
          max_file_size = 1024 * 1024, -- 1MB max file size
          error_sign = true,
          -- Animation settings for smooth effects
          duration = 200, -- Animation duration in ms
          delay = 300,    -- Animation delay in ms
          exclude_filetypes = {
            aerial = true,
            dashboard = true,
            alpha = true,
            lazy = true,
            mason = true,
            trouble = true,
            oil = true,
            NvimTree = true,
            ["neo-tree"] = true,
            terminal = true,
            toggleterm = true,
            notify = true,
            noice = true,
            TelescopePrompt = true,
            TelescopeResults = true,
            TelescopePreview = true,
            help = true,
          },
        },
        -- Indent line highlighting
        indent = {
          enable = true,
          priority = 10,
          use_treesitter = false, -- Keep false for better performance
          chars = { "│" }, -- Simple vertical line character
          ahead_lines = 5, -- Preview range
          delay = 100, -- Throttle delay for smooth scrolling
          exclude_filetypes = {
            aerial = true,
            dashboard = true,
            alpha = true,
            lazy = true,
            mason = true,
            trouble = true,
            oil = true,
            NvimTree = true,
            ["neo-tree"] = true,
            terminal = true,
            toggleterm = true,
            notify = true,
            noice = true,
            TelescopePrompt = true,
            TelescopeResults = true,
            TelescopePreview = true,
            help = true,
          },
        },
        -- Disable other features as requested
        line_num = {
          enable = false,
        },
        blank = {
          enable = false,
        },
      })
    end,
  },
  -- Better UI elements with enhanced theming
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        signature = {
          auto_open = { enabled = false },
        }
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
      -- Enhanced command line styling
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖" },
        },
      },
      -- Enhanced messages styling
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext",
      },
    },
    config = function(_, opts)
      require("noice").setup(opts)
    end,
  },
  -- Telescope symbols (replaces symbols-outline with beautiful telescope UI)
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<D-S-o>",
        function()
          -- Create advanced symbol picker with hierarchical document order
          local function ordered_symbols_picker()
            local finders = require("telescope.finders")
            local pickers = require("telescope.pickers")
            local conf = require("telescope.config").values
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            local results_lsp = fetch_lsp_symbols()
            if not results_lsp then return end

            -- Process symbols maintaining strict document order
            local symbols = {}
            local function process_symbols(syms, level, prefix_order)
              level = level or 0
              prefix_order = prefix_order or ""

              local sorted_syms = sort_symbols_by_line(syms)

              for _, symbol in ipairs(sorted_syms) do
                local kind = symbol.kind or symbol.symbolKind or 1
                local icon_info = symbol_icons[kind] or { icon = "", name = "Unknown" }
                local line = get_symbol_line(symbol)
                local order_key = prefix_order .. string.format("%06d", line)

                table.insert(symbols, {
                  symbol = symbol,
                  kind = kind,
                  icon = icon_info.icon,
                  type_name = icon_info.name,
                  name = symbol.name,
                  indent = string.rep("  ", level),
                  level = level,
                  line = line,
                  order_key = order_key,
                  document_order = #symbols + 1,
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

            table.sort(symbols, function(a, b)
              return a.document_order < b.document_order
            end)

            if vim.tbl_isempty(symbols) then
              vim.notify("No symbols found in current buffer", vim.log.levels.WARN)
              return
            end

            pickers
                .new({}, {
                  prompt_title = "󰘦 Document Symbols (Document Order)",
                  finder = finders.new_table({
                    results = symbols,
                    entry_maker = make_symbol_entry,
                  }),
                  sorter = conf.generic_sorter({}),
                  previewer = conf.grep_previewer({}),
                  initial_mode = "normal",
                  attach_mappings = function(prompt_bufnr, map)
                    map("i", "<Esc>", actions.close)
                    map("n", "<Esc>", actions.close)
                    map("n", "q", actions.close)
                    actions.select_default:replace(function()
                      local selection = action_state.get_selected_entry()
                      actions.close(prompt_bufnr)
                      jump_to_symbol(selection)
                    end)
                    return true
                  end,
                })
                :find()
          end
          ordered_symbols_picker()
        end,
        desc = "Document Symbols (Hierarchical)",
      },
      {
        "<D-o>",
        function()
          -- Create symbol type filter picker
          local function symbol_type_filter_picker()
            local finders = require("telescope.finders")
            local pickers = require("telescope.pickers")
            local conf = require("telescope.config").values
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            local results_lsp = fetch_lsp_symbols()
            if not results_lsp then return end

            -- Process symbols maintaining document order
            local symbols = {}
            local function process_symbols(syms, level)
              level = level or 0

              local sorted_syms = sort_symbols_by_line(syms)

              for _, symbol in ipairs(sorted_syms) do
                local kind = symbol.kind or symbol.symbolKind or 1
                local icon_info = symbol_icons[kind] or { icon = "", name = "Unknown" }
                local line = get_symbol_line(symbol)

                table.insert(symbols, {
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

            if vim.tbl_isempty(symbols) then
              vim.notify("No symbols found in current buffer", vim.log.levels.WARN)
              return
            end

            -- Calculate symbol type counts
            local type_counts = {}
            for _, sym in ipairs(symbols) do
              type_counts[sym.type_name] = (type_counts[sym.type_name] or 0) + 1
            end

            -- Create filter options
            local type_options = { { name = "All", count = #symbols, icon = "󰒺" } }
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
                  icon = type_info.icon
                })
              end
            end

            -- Function to create symbol picker with filtered results
            local function create_filtered_picker(filter_type)
              local filtered_symbols = symbols
              if filter_type ~= "All" then
                filtered_symbols = vim.tbl_filter(function(sym)
                  return sym.type_name == filter_type
                end, symbols)
              end

              pickers.new({}, {
                prompt_title = "󰘦 Filtered Symbols - " .. filter_type .. " (" .. #filtered_symbols .. ")",
                finder = finders.new_table({
                  results = filtered_symbols,
                  entry_maker = make_symbol_entry,
                }),
                sorter = conf.generic_sorter({}),
                previewer = conf.grep_previewer({}),
                initial_mode = "normal",
                attach_mappings = function(prompt_bufnr, map)
                  actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    jump_to_symbol(selection)
                  end)
                  return true
                end,
              }):find()
            end

            -- Show type filter picker
            pickers.new({}, {
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
              initial_mode = "normal",
              attach_mappings = function(prompt_bufnr, map)
                map("i", "<Esc>", actions.close)
                map("n", "<Esc>", actions.close)
                map("n", "q", actions.close)

                actions.select_default:replace(function()
                  local selection = action_state.get_selected_entry()
                  actions.close(prompt_bufnr)
                  if selection then
                    create_filtered_picker(selection.value.name)
                  end
                end)
                return true
              end,
            }):find()
          end

          symbol_type_filter_picker()
        end,
        desc = "Filter Document Symbols by Type",
      },
    },
  },
  -- Zellij Navigation
  {
    "swaits/zellij-nav.nvim",
    lazy = true,
    event = "VeryLazy",
    keys = {
      { "<c-h>", "<cmd>ZellijNavigateLeftTab<cr>",  { silent = true, desc = "navigate left or tab" } },
      { "<c-j>", "<cmd>ZellijNavigateDown<cr>",     { silent = true, desc = "navigate down" } },
      { "<c-k>", "<cmd>ZellijNavigateUp<cr>",       { silent = true, desc = "navigate up" } },
      { "<c-l>", "<cmd>ZellijNavigateRightTab<cr>", { silent = true, desc = "navigate right or tab" } },
    },
    opts = {},
  },
  -- Mini.icons for better which-key icon support
  {
    "echasnovski/mini.icons",
    version = false,
    config = true,
  },
  -- Show keys
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
    end,
    config = function()
      local wk = require("which-key")

      wk.setup({
        plugins = {
          marks = true,
          registers = true,
          presets = {
            operators = false,
            motions = false,
            text_objects = false,
            windows = false,
            nav = false,
            z = false,
            g = false,
          },
        },
        icons = {
          breadcrumb = "»",
          separator = "|",
          group = "+",
        },
        layout = {
          height = { min = 4, max = 25 },
          width = { min = 20, max = 50 },
          spacing = 3,
          -- align = "center",
        },
        show_help = false,
      })

      -- Register all the key groups
      wk.add({
        -- AI/Avante group with streamlined commands
        { "<leader>a",  group = "AI" },
        { "<leader>ai", desc = "Ask input" },
        { "<leader>af", desc = "Focus chat" },
        { "<leader>al", desc = "Clear chat" },
        -- Native Avante history features
        { "<leader>ah", desc = "Avante history" },
        { "[a",         desc = "Chat history selector" },
        { "]a",         desc = "Chat history selector" },
        -- Code assistance (visual mode)
        { "<leader>ae", desc = "Explain code" },
        { "<leader>at", desc = "Generate tests" },
        { "<leader>ar", desc = "Review code" },
        { "<leader>ad", desc = "Add docs" },
        { "<leader>ao", desc = "Optimize code" },
        -- Git integration
        { "<leader>ac", desc = "Commit message" },
        -- Other groups
        { "<leader>d",  group = "Debug" },
        { "<leader>e",  group = "Error Lens/Explorer" },
        { "<leader>b",  group = "Buffer" },
        { "<leader>c",  group = "Context/Code-Actions" },
        { "<leader>f",  group = "File/Find" },
        { "<leader>g",  group = "Git/Goto" },
        { "<leader>h",  group = "Hunks/Git-Stage" },
        { "<leader>j",  group = "Jump" },
        { "<leader>k",  group = "Jump/Flash" },
        { "<leader>l",  group = "LSP" },
        { "<leader>p",  group = "Peek/Preview" },
        { "<leader>r",  group = "Rename/Refactor" },
        { "<leader>s",  group = "Snacks" },
        { "<leader>t",  group = "Toggles" },
        { "<leader>u",  group = "Test/Utils" },
        { "<leader>v",  group = "Visual/View" },
        { "<leader>x",  group = "Diagnostics/Trouble" },
        { "<leader>z",  group = "Fold" },
      })
    end,
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show()
        end,
        desc = "Show keymaps",
      },
    },
  },
  -- Add nvim-notify for notification support
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("notify").setup({
        timeout = 3000,
        max_width = 80,
        level = vim.log.levels.ERROR,
      })
    end,
  },
  -- nvim-scrollbar
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require("scrollbar").setup({
        show = true,
        show_in_active_only = false,
        set_highlights = true,
        folds = 1000,                -- handle folds, set to number to disable folds if no. of lines in buffer exceeds this
        max_lines = false,           -- disables if no. of lines in buffer exceeds this
        hide_if_all_visible = false, -- Hides everything if all lines are visible
        throttle_ms = 100,
        handle = {
          text = " ",
          blend = 30,                 -- Integer between 0 and 100. 0 for fully opaque and 100 to full transparent. Defaults to 30.
          color = nil,
          color_nr = nil,             -- cterm
          highlight = "CursorColumn",
          hide_if_all_visible = true, -- Hides handle if all lines are visible
        },
        marks = {
          Cursor = {
            text = "•",
            priority = 0,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "Normal",
          },
          Search = {
            text = { "-", "=" },
            priority = 1,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "Search",
          },
          Error = {
            text = { "-", "=" },
            priority = 2,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "DiagnosticVirtualTextError",
          },
          Warn = {
            text = { "-", "=" },
            priority = 3,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "DiagnosticVirtualTextWarn",
          },
          Info = {
            text = { "-", "=" },
            priority = 4,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "DiagnosticVirtualTextInfo",
          },
          Hint = {
            text = { "-", "=" },
            priority = 5,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "DiagnosticVirtualTextHint",
          },
          Misc = {
            text = { "-", "=" },
            priority = 6,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "Normal",
          },
          GitAdd = {
            text = "┆",
            priority = 7,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "GitSignsAdd",
          },
          GitChange = {
            text = "┆",
            priority = 7,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "GitSignsChange",
          },
          GitDelete = {
            text = "▁",
            priority = 7,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "GitSignsDelete",
          },
        },
        excluded_buftypes = {
          "terminal",
        },
        excluded_filetypes = {
          "blink-cmp-menu",
          "dropbar_menu",
          "dropbar_menu_fzf",
          "DressingInput",
          "cmp_docs",
          "cmp_menu",
          "noice",
          "prompt",
          "TelescopePrompt",
        },
        autocmd = {
          render = {
            "BufWinEnter",
            "TabEnter",
            "TermEnter",
            "WinEnter",
            "CmdwinLeave",
            "TextChanged",
            "VimResized",
            "WinScrolled",
          },
          clear = {
            "BufWinLeave",
            "TabLeave",
            "TermLeave",
            "WinLeave",
          },
        },
        handlers = {
          cursor = true,
          diagnostic = true,
          gitsigns = false, -- Requires gitsigns
          handle = true,
          search = false,   -- Requires hlslens
          ale = false,      -- Requires ALE
        },
      })
    end,
  },
  -- High-performance color highlighter
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufRead",
    config = function()
      require("colorizer").setup({
        "css",
        "html",
        "javascript",
        "typescript",
        "vue",
        "scss",
        "sass",
      }, {
        RGB = true,          -- #RGB hex codes
        RRGGBB = true,       -- #RRGGBB hex codes
        names = false,       -- Disable named colors to avoid false positives
        RRGGBBAA = false,    -- #RRGGBBAA hex codes
        rgb_fn = true,       -- CSS rgb() and rgba() functions
        hsl_fn = true,       -- CSS hsl() and hsla() functions
        css = true,          -- Enable all CSS features
        css_fn = true,       -- Enable all CSS *functions*
        mode = "background", -- Set the display mode
      })
    end,
  },
  -- Tabby.nvim - Beautiful and configurable tab line
  {
    "nanozuki/tabby.nvim",
    event = "VimEnter",
    enabled = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local theme = {
        fill = "TabLineFill",
        -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
        head = "TabLine",
        current_tab = "TabLineSel",
        tab = "TabLine",
        win = "TabLine",
        tail = "TabLine",
      }

      require("tabby.tabline").set(function(line)
        return {
          {
            { "  ", hl = theme.head },
            line.sep("", theme.head, theme.fill),
          },
          line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.tab
            return {
              line.sep("", hl, theme.fill),
              tab.is_current() and "" or "󰆣",
              tab.number(),
              tab.name(),
              tab.close_btn(""),
              line.sep("", hl, theme.fill),
              hl = hl,
              margin = " ",
            }
          end),
          line.spacer(),
          line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
            return {
              line.sep("", theme.win, theme.fill),
              win.is_current() and "" or "",
              win.buf_name(),
              line.sep("", theme.win, theme.fill),
              hl = theme.win,
              margin = " ",
            }
          end),
          {
            line.sep("", theme.tail, theme.fill),
            { "  ", hl = theme.tail },
          },
          hl = theme.fill,
        }
      end)
    end,
  },
  -- Enhanced cursorword highlighting (cursorline disabled to avoid conflicts)
  {
    "ya2s/nvim-cursorline",
    config = function()
      require('nvim-cursorline').setup({
        cursorline = {
          enable = true,
          timeout = 0,
          number = false,
        },
        cursorword = {
          enable = true,
          min_length = 3,
          hl = { underline = true },
        }
      })
    end,
  },
  -- Smooth scrolling animations for any movement
  {
    "declancm/cinnamon.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("cinnamon").setup({
        -- Enable both basic and extra keymaps for comprehensive smooth scrolling
        keymaps = {
          basic = false, -- Disabled: neoscroll.nvim handles C-u/C-d/C-f/C-b with finer control
          extra = false, -- Start/end of file/line, screen scrolling, up/down, left/right movements
        },
        options = {
          -- Animate cursor and window scrolling for any movement
          mode = "cursor",
          -- Don't require count for animation (smoother experience)
          count_only = false,
          -- Slightly faster delay for responsive feel
          delay = 4,
          max_delta = {
            -- Disable limits for line movements (always animate)
            line = false,
            -- Disable limits for column movements (always animate)
            column = false,
            -- Maximum duration for any movement (1 second)
            time = 1000,
          },
          step_size = {
            -- Smooth vertical movement (1 line per step)
            vertical = 1,
            -- Slightly larger horizontal steps for efficiency
            horizontal = 2,
          },
        },
      })

      -- Disable smooth scrolling for specific file types where it might be distracting
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "dashboard",
          "alpha",
          "lazy",
          "mason",
          "telescope",
          "TelescopePrompt",
          "TelescopeResults",
          "TelescopePreview",
          "notify",
          "noice",
          "NvimTree",
          "neo-tree",
          "oil",
          "trouble",
          "qf", -- quickfix
        },
        callback = function()
          vim.b.cinnamon_disable = true
        end,
      })
    end,
  },
  {
    "goolord/alpha-nvim",
    dependencies = {
      -- 'echasnovski/mini.icons',
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons'
    },
    config = function()
      local startify = require("alpha.themes.startify")
      -- available: devicons, mini, default is mini
      -- if provider not loaded and enabled is true, it will try to use another provider
      startify.file_icons.provider = "devicons"
      require 'alpha'.setup(require 'alpha.themes.theta'.config)
      -- require("alpha").setup(
      --   startify.config
      -- )
    end,
  },
}
