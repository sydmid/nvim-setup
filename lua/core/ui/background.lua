local M = {
  modes = {
    { name = "Light", background = "light", colorscheme = "kanagawa-lotus" },
    { name = "Dark", background = "dark", colorscheme = "kanagawa" },
  },
  current_index = 2,
  is_setting = false,
}

local function preference_file()
  return vim.fn.stdpath("data") .. "/background_preference.lua"
end

function M.set_mode(mode_index)
  if M.is_setting then
    return
  end

  M.is_setting = true
  if mode_index < 1 or mode_index > #M.modes then
    mode_index = 1
  end

  M.current_index = mode_index
  local mode = M.modes[mode_index]
  vim.opt.background = mode.background
  vim.cmd.colorscheme(mode.colorscheme)
  M.save_preference()
  M.is_setting = false
end

function M.toggle_mode()
  local next_index = (M.current_index % #M.modes) + 1
  M.set_mode(next_index)
end

function M.save_preference()
  local file = io.open(preference_file(), "w")
  if file then
    file:write("return {\n")
    file:write("  mode_index = " .. M.current_index .. "\n")
    file:write("}\n")
    file:close()
  end
end

function M.load_preference()
  local bg_file = preference_file()
  if vim.fn.filereadable(bg_file) == 1 then
    local ok, prefs = pcall(dofile, bg_file)
    if ok and prefs and prefs.mode_index then
      M.current_index = prefs.mode_index
    end
  end
end

function M.open_picker()
  local tp = require("core.utils.telescope_pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local mode_info = {}
  for i, mode in ipairs(M.modes) do
    table.insert(mode_info, {
      index = i,
      name = mode.name,
      display = mode.name,
      description = string.format("Kanagawa %s", mode.name:lower()),
    })
  end

  tp.custom({
    prompt_title = "Background Selector (Current: " .. M.modes[M.current_index].name .. ")",
    mode = "normal",
    finder = finders.new_table({
      results = mode_info,
      entry_maker = function(entry)
        local display_text = entry.display
        if entry.index == M.current_index then
          display_text = "✓ " .. entry.display .. " 🎯 (CURRENT)"
        end

        return {
          value = entry.index,
          display = display_text,
          ordinal = entry.name .. " " .. entry.display,
          is_current = entry.index == M.current_index,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          M.set_mode(selection.value)
        end
      end)
      return true
    end,
  })
end

return M
