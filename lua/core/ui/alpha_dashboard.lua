local M = {}

function M.get_projects_section()
  local dashboard = require("alpha.themes.dashboard")

  -- ── Helper: build the "Recent Projects" section ──────────────
  local function get_project_buttons()
    local session_dir = vim.fn.stdpath("data") .. "/sessions"
    local buttons = {}

    if vim.fn.isdirectory(session_dir) == 0 then
      return buttons
    end

    -- Collect session files sorted by modification time (newest first)
    local sessions = {}
    local handle = vim.loop.fs_scandir(session_dir)
    if handle then
      while true do
        local name, typ = vim.loop.fs_scandir_next(handle)
        if not name then
          break
        end
        if (typ == "file") and name:match("%.vim$") and name ~= ".vim" then
          local full = session_dir .. "/" .. name
          local stat = vim.loop.fs_stat(full)
          if stat then
            table.insert(sessions, { name = name, mtime = stat.mtime.sec })
          end
        end
      end
    end
    table.sort(sessions, function(a, b)
      return a.mtime > b.mtime
    end)

    -- Decode the URL-encoded path to a human-readable name
    local function decode(encoded)
      local decoded = encoded:gsub("%.vim$", "")
      decoded = decoded:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
      end)
      return decoded
    end

    -- Use p1, p2, ... shortcuts to avoid conflict with theta's MRU numbers
    local max_projects = math.min(#sessions, 10)

    for i = 1, max_projects do
      local s = sessions[i]
      local project_path = decode(s.name)
      local display_name = vim.fn.fnamemodify(project_path, ":t") -- last dir component
      local shortcut = "p" .. i

      -- Build restore command: cd to the decoded path, then restore the session
      local restore_cmd = string.format(
        "<cmd>cd %s | lua require('auto-session').restore_session()<CR>",
        vim.fn.fnameescape(project_path)
      )

      local btn = dashboard.button(shortcut, "  " .. display_name .. "  (" .. project_path .. ")", restore_cmd)
      btn.opts.width = 72
      table.insert(buttons, btn)
    end

    return buttons
  end

  -- ── Build the projects section ───────────────────────────────
  return {
    type = "group",
    val = function()
      local heading = {
        type = "text",
        val = "  Recent Projects",
        opts = { hl = "SpecialComment", shrink_margin = false, position = "center" },
      }
      local project_btns = get_project_buttons()
      if #project_btns == 0 then
        return {
          heading,
          { type = "padding", val = 1 },
          { type = "text", val = "   No saved sessions yet", opts = { hl = "Comment", position = "center" } },
        }
      end
      local group = {
        heading,
        { type = "padding", val = 1 },
      }
      for _, btn in ipairs(project_btns) do
        table.insert(group, btn)
      end
      return group
    end,
  }
end

return M
