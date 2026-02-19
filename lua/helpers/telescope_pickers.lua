-- Centralized Telescope picker helpers
-- Two base functions: M.builtin() for telescope.builtin.* pickers, M.custom() for pickers.new() custom pickers.
-- Both auto-inject Esc/q close mappings and support layout selection ("ivy" | "horizontal").

local M = {}

--- Compose close mappings (Esc in insert+normal, q in normal) with user-provided attach_mappings.
--- @param user_attach_mappings? function(prompt_bufnr, map): boolean
--- @return function
local function compose_mappings(user_attach_mappings)
  return function(prompt_bufnr, map)
    local actions = require("telescope.actions")
    map("i", "<Esc>", actions.close)
    map("n", "<Esc>", actions.close)
    map("n", "q", actions.close)

    if user_attach_mappings then
      return user_attach_mappings(prompt_bufnr, map)
    end
    return true
  end
end

--- Apply layout settings to opts table and strip helper-only keys.
--- @param opts table
--- @return table cleaned opts (mutated in-place)
local function apply_layout(opts)
  local layout = opts.layout or "horizontal"
  local height = opts.height

  if layout == "ivy" then
    opts.theme = "ivy"
    -- Deep merge layout_config: caller may have set extra keys like preview_cutoff
    local lc = opts.layout_config or {}
    lc.height = lc.height or height or 0.6
    opts.layout_config = lc
  end
  -- "horizontal" uses telescope global defaults (no extra keys needed),
  -- but if the caller passed layout_config it stays untouched.

  -- Set initial_mode from the convenience "mode" key
  if opts.mode then
    opts.initial_mode = opts.mode
  end

  -- Strip helper-only keys so telescope doesn't warn about unknown options
  opts.layout = nil
  opts.mode = nil
  opts.height = nil

  -- Compose close mappings with any user-provided attach_mappings
  opts.attach_mappings = compose_mappings(opts.attach_mappings)

  return opts
end

--- Open a telescope.builtin picker with standardized layout and close mappings.
---
--- @param name string  Builtin picker name (e.g. "find_files", "git_branches", "diagnostics")
--- @param opts? table  Options passed to the builtin picker, plus:
---   - layout: "ivy" | "horizontal"  (default "horizontal")
---   - mode:   "insert" | "normal"   (default "insert")
---   - height: number                (ivy height, default 0.6)
---   All other keys pass through to the builtin picker.
function M.builtin(name, opts)
  opts = vim.tbl_deep_extend("force", {}, opts or {})
  apply_layout(opts)
  require("telescope.builtin")[name](opts)
end

--- Open a custom telescope picker (pickers.new) with standardized layout and close mappings.
---
--- @param opts table  Options passed to pickers.new, plus:
---   - layout: "ivy" | "horizontal"  (default "horizontal")
---   - mode:   "insert" | "normal"   (default "normal")
---   - height: number                (ivy height, default 0.6)
---   Required: finder (and usually prompt_title, sorter).
function M.custom(opts)
  opts = vim.tbl_deep_extend("force", {}, opts or {})
  -- Custom pickers default to normal mode (most are selection lists)
  if not opts.mode and not opts.initial_mode then
    opts.mode = "normal"
  end
  apply_layout(opts)
  require("telescope.pickers").new({}, opts):find()
end

--- Standalone compose_mappings export for edge cases (e.g. extension pickers).
M.compose_mappings = compose_mappings

return M
