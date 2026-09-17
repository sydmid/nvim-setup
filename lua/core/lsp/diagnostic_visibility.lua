local M = {}

function M.setup()
  local diagnostics = require("core.lsp.diagnostics")

  -- Telescope picker: toggle diagnostic severity visibility
  local function open_diagnostic_severity_picker(initial_idx)
    local tp = require("core.utils.telescope_pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local severity_items = {
      { severity = vim.diagnostic.severity.ERROR, name = "Errors", icon = " " },
      { severity = vim.diagnostic.severity.WARN, name = "Warnings", icon = " " },
      { severity = vim.diagnostic.severity.INFO, name = "Info", icon = " " },
      { severity = vim.diagnostic.severity.HINT, name = "Hints", icon = " " },
    }

    local entries = {}
    for i, item in ipairs(severity_items) do
      table.insert(entries, {
        idx = i,
        severity = item.severity,
        name = item.name,
        icon = item.icon,
        active = diagnostics.severity_state[item.severity],
      })
    end

    tp.custom({
      prompt_title = "Diagnostic Visibility (Enter: toggle, Esc: close)",
      mode = "normal",
      default_selection_index = initial_idx or 1,
      finder = finders.new_table({
        results = entries,
        entry_maker = function(entry)
          local indicator = entry.active and "[x]" or "[ ]"
          return {
            value = entry,
            display = string.format("%s %s %s", indicator, entry.icon, entry.name),
            ordinal = entry.name,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          if selection then
            local sev = selection.value.severity
            local idx = selection.value.idx
            diagnostics.severity_state[sev] = not diagnostics.severity_state[sev]
            diagnostics.apply_severity_visibility()
            actions.close(prompt_bufnr)
            vim.schedule(function()
              open_diagnostic_severity_picker(idx)
            end)
          end
        end)
        return true
      end,
    })
  end

  vim.keymap.set("n", "<leader>xv", function()
    open_diagnostic_severity_picker()
  end, { desc = "Diagnostic visibility", silent = true })

  -- Reset severity to errors-only on project change
  vim.api.nvim_create_autocmd("DirChanged", {
    group = vim.api.nvim_create_augroup("DiagnosticSeverityReset", { clear = true }),
    callback = function()
      diagnostics.reset_severity_defaults()
    end,
  })
end

return M
