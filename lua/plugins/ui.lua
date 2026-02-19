-- Global variables to track current background mode
_G.background_modes = {
<<<<<<< HEAD
<<<<<<< HEAD
  { name = "Light", background = "light", colorscheme = "kanagawa-lotus" },
  { name = "Dark", background = "dark", colorscheme = "kanagawa" },
}
_G.current_bg_index = 2
  { name = "Light", background = "light", colorscheme = "kanagawa-lotus" },
  { name = "Dark", background = "dark", colorscheme = "kanagawa" },
}
_G.current_bg_index = 2

=======
=======
>>>>>>> a438cfe (feat: enhance Neovim configuration with new plugins and keybindings)
  { bg = "#282c34", secondary = "#373c47", cursorline = "#303640", name = "Light",    opacity = false },
  { bg = "#1f1f19", secondary = "#34342a", cursorline = "#333227", name = "Warm",     opacity = false },
  { bg = "#0f1419", secondary = "#1c262f", cursorline = "#1a1f29", name = "Bluish",   opacity = false },
  { bg = "#121212", secondary = "#313131", cursorline = "#272727", name = "Dark",     opacity = false },
  { bg = "#121212", secondary = "#313131", cursorline = "#272727", name = "Glass",    opacity = true, opacity_value = 0 }, -- (opacity_value is not working for some reason)
<<<<<<< HEAD
  { bg = "#f2ecbc", secondary = "#d5cea3", cursorline = "#e7dba0", name = "Daylight", opacity = false },
=======
  { bg = "#f5efdc", secondary = "#e8e2cf", cursorline = "#ece6d4", name = "Daylight", opacity = false },
>>>>>>> a438cfe (feat: enhance Neovim configuration with new plugins and keybindings)
}
_G.current_bg_index = 1
_G.last_dark_theme = "bearded" -- remember the last dark theme for switching back

-- Central function to refresh lualine + bufferline for light/dark
function _G.refresh_bars()
  local is_light = (_G.current_theme == "kanagawa_lotus")

  -- Refresh lualine (reuse stored config, just swap theme)
  local ok_lualine, lualine = pcall(require, "lualine")
  if ok_lualine and _G._lualine_config then
    local lualine_theme
    if is_light then
      lualine_theme = "auto"
    else
      lualine_theme = require("lualine.themes.moonfly")
      lualine_theme.normal.b.fg = "#cad3f5"
      lualine_theme.insert.b.fg = "#cad3f5"
      lualine_theme.visual.b.fg = "#cad3f5"
      lualine_theme.replace.b.fg = "#cad3f5"
      lualine_theme.inactive.b.fg = "#cad3f5"
      lualine_theme.normal.c.fg = "#6e738d"
      lualine_theme.normal.c.bg = "#1e2030"
    end
    _G._lualine_config.options.theme = lualine_theme
    lualine.setup(_G._lualine_config)
  end

  -- Refresh bufferline highlights via raw highlight groups (preserves existing config)
  local ok_bl = pcall(require, "bufferline")
  if ok_bl then
    local mode = _G.background_modes[_G.current_bg_index]
    local bg, bg_sel, fg, fg_sel, fg_dim, sep_fg
    if is_light then
      -- Kanagawa Lotus palette
      bg      = "#d5cea3" -- lotusWhite0 (inactive tab bg)
      bg_sel  = "#f2ecbc" -- lotusWhite3 (active tab bg = main bg)
      fg      = "#8a8980" -- lotusGray3  (inactive tab fg)
      fg_sel  = "#545464" -- lotusInk1   (active tab fg)
      fg_dim  = "#a09cac" -- lotusViolet1
      sep_fg  = "#e7dba0" -- lotusWhite4 (separator)
    else
      bg      = mode.opacity and "NONE" or mode.secondary
      bg_sel  = mode.opacity and "NONE" or mode.cursorline
      fg      = "#6e738d"
      fg_sel  = "#cad3f5"
      fg_dim  = "#545c7e"
      sep_fg  = mode.opacity and "NONE" or mode.bg
    end
    local fill_bg = is_light and "#e7dba0" or (mode.opacity and "NONE" or mode.bg)

    -- Map: { HighlightGroupName = { opts } }
    local bl_hls = {
      BufferLineFill                     = { bg = fill_bg },
      BufferLineBackground               = { fg = fg, bg = bg },
      BufferLineBufferSelected           = { fg = fg_sel, bg = bg_sel, bold = true },
      BufferLineBufferVisible            = { fg = fg_dim, bg = bg },
      BufferLineCloseButton              = { fg = fg, bg = bg },
      BufferLineCloseButtonSelected      = { fg = fg_sel, bg = bg_sel },
      BufferLineCloseButtonVisible       = { fg = fg_dim, bg = bg },
      BufferLineSeparator                = { fg = sep_fg, bg = bg },
      BufferLineSeparatorSelected        = { fg = sep_fg, bg = bg_sel },
      BufferLineSeparatorVisible         = { fg = sep_fg, bg = bg },
      BufferLineTab                      = { fg = fg, bg = bg },
      BufferLineTabSelected              = { fg = fg_sel, bg = bg_sel, bold = true },
      BufferLineTabSeparator             = { fg = sep_fg, bg = bg },
      BufferLineTabSeparatorSelected     = { fg = sep_fg, bg = bg_sel },
      BufferLineModified                 = { fg = "#e6c384", bg = bg },
      BufferLineModifiedSelected         = { fg = "#e6c384", bg = bg_sel },
      BufferLineModifiedVisible          = { fg = "#e6c384", bg = bg },
      BufferLineDuplicate                = { fg = fg_dim, bg = bg, italic = true },
      BufferLineDuplicateSelected        = { fg = fg_sel, bg = bg_sel, italic = true },
      BufferLineDuplicateVisible         = { fg = fg_dim, bg = bg, italic = true },
      BufferLineDiagnostic               = { fg = fg_dim, bg = bg },
      BufferLineDiagnosticSelected       = { fg = fg_sel, bg = bg_sel },
      BufferLineDiagnosticVisible        = { fg = fg_dim, bg = bg },
      BufferLineIndicatorSelected        = { fg = is_light and "#6f894e" or "#7aa89f", bg = bg_sel },
      BufferLineIndicatorVisible         = { fg = fg_dim, bg = bg },
      BufferLinePick                     = { fg = is_light and "#b35b79" or "#ff5d62", bg = bg, bold = true },
      BufferLinePickSelected             = { fg = is_light and "#b35b79" or "#ff5d62", bg = bg_sel, bold = true },
      BufferLinePickVisible              = { fg = is_light and "#b35b79" or "#ff5d62", bg = bg, bold = true },
      BufferLineOffsetSeparator          = { fg = sep_fg, bg = fill_bg },
    }

    for group, opts in pairs(bl_hls) do
      vim.api.nvim_set_hl(0, group, opts)
    end

    -- Force tabline redraw
    vim.cmd("redrawtabline")
  end
end

>>>>>>> 0e9ff36 (feat: enhance theme support and color configurations for light/dark modes)
-- Function to set background mode (with re-entry guard)
_G._setting_bg = false
function _G.set_background_mode(mode_index)
  if _G._setting_bg then return end
  _G._setting_bg = true

  if mode_index < 1 or mode_index > #_G.background_modes then
    mode_index = 1
  end

  _G.current_bg_index = mode_index
  local mode = _G.background_modes[mode_index]
<<<<<<< HEAD
  vim.opt.background = mode.background
  vim.cmd.colorscheme(mode.colorscheme)
  vim.opt.background = mode.background
  vim.cmd.colorscheme(mode.colorscheme)
=======

  -- Handle opacity settings
  if mode.opacity then
    vim.g.molokaiTransparent = true
    vim.opt.winblend = mode.opacity_value
    vim.opt.pumblend = mode.opacity_value
  else
    vim.g.molokaiTransparent = false
    vim.opt.winblend = 0
    vim.opt.pumblend = 0
  end

  -- Step 1: Auto-switch theme when crossing the light/dark boundary
  -- This MUST happen before highlight application so is_light is correct.
  local is_light_bg = (mode.name == "Daylight")
  local is_light_theme = (_G.current_theme == "kanagawa_lotus")

  if is_light_bg and not is_light_theme then
    -- Switching to Daylight bg → auto-switch to Kanagawa Lotus
    _G.last_dark_theme = _G.current_theme
    _G.current_theme = "kanagawa_lotus"
    _G.save_theme_preference()
    vim.opt.background = "light"
    vim.cmd.colorscheme("kanagawa-lotus")
  elseif not is_light_bg and is_light_theme then
    -- Switching away from Daylight → restore previous dark theme
    local dark_theme = _G.last_dark_theme or "bearded"
    _G.current_theme = dark_theme
    _G.save_theme_preference()
    vim.opt.background = "dark"
    if dark_theme == "zenwritten" then
      vim.cmd.colorscheme("zenwritten")
    elseif dark_theme == "modus_vivendi" then
      vim.cmd.colorscheme("modus_vivendi")
    elseif dark_theme == "github_dark_default" then
      vim.cmd.colorscheme("github_dark_default")
    elseif dark_theme == "ayu_dark" then
      require("ayu").setup({ mirage = false })
      vim.cmd.colorscheme("ayu-dark")
    elseif dark_theme == "ayu_mirage" then
      require("ayu").setup({ mirage = true })
      vim.cmd.colorscheme("ayu-mirage")
    elseif dark_theme == "dracula" then
      vim.cmd.colorscheme("dracula")
    else
      require("bearded").setup({ flavor = "arc" })
      vim.cmd.colorscheme("bearded")
    end
  end
>>>>>>> 0e9ff36 (feat: enhance theme support and color configurations for light/dark modes)

  -- Step 2: Apply highlight overrides (is_light now reflects the actual current theme)
  local is_light = (_G.current_theme == "kanagawa_lotus")

  if is_light and mode.name == "Daylight" then
    -- Kanagawa Lotus: nudge highlight groups to exact palette values
    local lotus = {
      bg      = "#f2ecbc", -- lotusWhite3 (main bg)
      bg_dim  = "#dcd5ac", -- lotusWhite1 (dimmed bg / floats border)
      gutter  = "#e7dba0", -- lotusWhite4 (gutter / cursorline)
      float   = "#d5cea3", -- lotusWhite0 (float bg)
      fg      = "#545464", -- lotusInk1
      fg_dim  = "#43436c", -- lotusInk2
      nontext = "#a09cac", -- lotusViolet1
    }
    local light_hl = {
      Normal                       = { bg = lotus.bg, fg = lotus.fg },
      NormalFloat                  = { bg = lotus.float, fg = lotus.fg_dim },
      SignColumn                   = { bg = lotus.bg },
      LineNr                       = { bg = lotus.bg, fg = lotus.nontext },
      CursorLine                   = { bg = lotus.gutter },
      CursorLineNr                 = { bg = lotus.gutter },
      StatusLine                   = { bg = lotus.gutter },
      TabLineFill                  = { bg = lotus.bg },
      Pmenu                        = { bg = lotus.float },
      PmenuBorder                  = { bg = lotus.float },
      TelescopeNormal              = { bg = lotus.bg },
      TelescopeBorder              = { bg = lotus.bg, fg = lotus.nontext },
      TelescopeResultsNormal       = { bg = lotus.bg },
      TelescopeResultsBorder       = { bg = lotus.bg },
      TelescopePreviewNormal       = { bg = lotus.bg },
      TelescopePreviewBorder       = { bg = lotus.bg },
      TelescopePromptNormal        = { bg = lotus.bg },
      TelescopePromptBorder        = { bg = lotus.bg },
      NoiceCmdlinePopup            = { bg = lotus.float },
      NoiceCmdlinePopupBorder      = { bg = lotus.float },
      NoicePopup                   = { bg = lotus.float },
      NoicePopupBorder             = { bg = lotus.float },
      NoiceConfirm                 = { bg = lotus.float },
      NoiceConfirmBorder           = { bg = lotus.float },
      TreesitterContext            = { bg = lotus.bg_dim },
      TreesitterContextLineNumber  = { bg = lotus.bg_dim },
    }
    for group, opts in pairs(light_hl) do
      vim.api.nvim_set_hl(0, group, opts)
    end
  else
    -- Dark theme: apply custom background highlights
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

    for group, opts in pairs(bg_highlights) do
      local current_hl = vim.api.nvim_get_hl(0, { name = group })
      vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", current_hl, opts))
    end
  end

  -- Step 3: Refresh lualine + bufferline to match
  _G.refresh_bars()

  _G.save_background_preference()
<<<<<<< HEAD
=======
  local opacity_text = mode.opacity and (" (" .. mode.opacity_value .. "% opacity)") or ""
  vim.notify("Background mode: " .. mode.name .. opacity_text, vim.log.levels.INFO)
>>>>>>> 0e9ff36 (feat: enhance theme support and color configurations for light/dark modes)

  _G._setting_bg = false
end

-- Function to cycle through background modes
function _G.toggle_background_mode()
  local next_index = (_G.current_bg_index % #_G.background_modes) + 1
  _G.set_background_mode(next_index)
end

<<<<<<< HEAD
=======
-- Theme preference persistence
_G.current_theme = "bearded" -- default theme

function _G.save_theme_preference()
  local theme_file = vim.fn.stdpath("data") .. "/theme_preference.lua"
  local file = io.open(theme_file, "w")
  if file then
    file:write("return {\n")
    file:write('  theme = "' .. _G.current_theme .. '"\n')
    file:write("}\n")
    file:close()
  end
end

function _G.load_theme_preference()
  local theme_file = vim.fn.stdpath("data") .. "/theme_preference.lua"
  if vim.fn.filereadable(theme_file) == 1 then
    local ok, prefs = pcall(dofile, theme_file)
    if ok and prefs and prefs.theme then
      _G.current_theme = prefs.theme
    end
  end
end

_G._applying_theme = false
function _G.apply_theme(theme_name)
  _G.current_theme = theme_name
  _G.save_theme_preference()

  local is_light = (theme_name == "kanagawa_lotus")

<<<<<<< HEAD
  -- Guard colorscheme commands so ColorScheme autocmd doesn't re-enter
  _G._applying_theme = true

=======
>>>>>>> a438cfe (feat: enhance Neovim configuration with new plugins and keybindings)
  if theme_name == "zenwritten" then
    vim.opt.background = "dark"
    vim.cmd.colorscheme("zenwritten")
  elseif theme_name == "modus_vivendi" then
    vim.opt.background = "dark"
    vim.cmd.colorscheme("modus_vivendi")
  elseif theme_name == "github_dark_default" then
    vim.opt.background = "dark"
    vim.cmd.colorscheme("github_dark_default")
  elseif theme_name == "ayu_dark" then
    require("ayu").setup({ mirage = false })
    vim.opt.background = "dark"
    vim.cmd.colorscheme("ayu-dark")
  elseif theme_name == "ayu_mirage" then
    require("ayu").setup({ mirage = true })
    vim.opt.background = "dark"
    vim.cmd.colorscheme("ayu-mirage")
  elseif theme_name == "dracula" then
    vim.opt.background = "dark"
    vim.cmd.colorscheme("dracula")
  elseif theme_name == "kanagawa_lotus" then
    vim.opt.background = "light"
    vim.cmd.colorscheme("kanagawa-lotus")
    -- Auto-select the warm Daylight background for the light theme
    for i, mode in ipairs(_G.background_modes) do
      if mode.name == "Daylight" then
        _G.current_bg_index = i
        break
      end
    end
  else
    require("bearded").setup({ flavor = "arc" })
    vim.opt.background = "dark"
    vim.cmd.colorscheme("bearded")
  end

<<<<<<< HEAD
  _G._applying_theme = false

=======
>>>>>>> a438cfe (feat: enhance Neovim configuration with new plugins and keybindings)
  -- If switching to a dark theme while Daylight bg is active, reset to default
  if not is_light and _G.background_modes[_G.current_bg_index].name == "Daylight" then
    _G.current_bg_index = 1
  end

  -- Apply Dracula-specific grey comments and strings
  if theme_name == "dracula" then
    vim.api.nvim_set_hl(0, "Comment", { fg = "#857a7b", italic = true })
    vim.api.nvim_set_hl(0, "@comment", { fg = "#857a7b", italic = true })
    vim.api.nvim_set_hl(0, "String", { fg = "#857a7b" })
    vim.api.nvim_set_hl(0, "@string", { fg = "#857a7b" })
    vim.api.nvim_set_hl(0, "@string.escape", { fg = "#857a7b" })
    vim.api.nvim_set_hl(0, "@string.special", { fg = "#857a7b" })
    vim.api.nvim_set_hl(0, "Character", { fg = "#857a7b" })
    vim.api.nvim_set_hl(0, "@character", { fg = "#857a7b" })
  end

  -- Override LSP reference highlights to only show underline (no color change)
  vim.api.nvim_set_hl(0, "LspReferenceText",  { underline = true, bg = "NONE" })
  vim.api.nvim_set_hl(0, "LspReferenceRead",  { underline = true, bg = "NONE" })
  vim.api.nvim_set_hl(0, "LspReferenceWrite", { underline = true, bg = "NONE" })

<<<<<<< HEAD
  -- Cursor — adapt to light/dark theme
  if is_light then
<<<<<<< HEAD
    vim.api.nvim_set_hl(0, "Cursor",  { fg = "#f2ecbc", bg = "#545464" })
    vim.api.nvim_set_hl(0, "lCursor", { fg = "#f2ecbc", bg = "#545464" })
=======
    vim.api.nvim_set_hl(0, "Cursor",  { fg = "#f5efdc", bg = "#3b4252" })
    vim.api.nvim_set_hl(0, "lCursor", { fg = "#f5efdc", bg = "#3b4252" })
>>>>>>> a438cfe (feat: enhance Neovim configuration with new plugins and keybindings)
  else
    vim.api.nvim_set_hl(0, "Cursor",  { fg = "#000000", bg = "#ffffff" })
    vim.api.nvim_set_hl(0, "lCursor", { fg = "#000000", bg = "#ffffff" })
  end

  -- Remember last dark theme for background picker switching
  if not is_light then
    _G.last_dark_theme = theme_name
  end

  -- Reapply background mode on top of the new theme + refresh bars
=======
  -- White block cursor
  vim.api.nvim_set_hl(0, "Cursor",  { fg = "#000000", bg = "#ffffff" })
  vim.api.nvim_set_hl(0, "lCursor", { fg = "#000000", bg = "#ffffff" })

  -- Reapply background mode on top of the new theme
>>>>>>> 0e4d1ab (feat: add white block cursor styling for improved visibility)
  _G.set_background_mode(_G.current_bg_index)
end

-- Function to create a Telescope theme picker
function _G.telescope_theme_picker()
  local tp = require("helpers.telescope_pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local theme_labels = {
    bearded = "Bearded Arc",
    zenwritten = "Zenwritten (Mono)",
    modus_vivendi = "Modus Vivendi",
    kanagawa_lotus = "Kanagawa Lotus ☀",
    github_dark_default = "GitHub Dark",
    ayu_dark = "Ayu Dark",
    ayu_mirage = "Ayu Mirage",
    dracula = "Dracula",
  }

  local themes = {
    { name = "Bearded Arc", value = "bearded", desc = "Colorful dark theme with vibrant syntax" },
    { name = "Zenwritten (Mono)", value = "zenwritten", desc = "Elegant monochrome with warm tints" },
    { name = "Modus Vivendi", value = "modus_vivendi", desc = "Accessible dark theme with high contrast" },
    { name = "Kanagawa Lotus ☀", value = "kanagawa_lotus", desc = "Elegant Japanese light theme — warm daylight for daytime" },
    { name = "GitHub Dark", value = "github_dark_default", desc = "GitHub's official dark color scheme" },
    { name = "Ayu Dark", value = "ayu_dark", desc = "Ayu dark variant — deep blue-toned background" },
    { name = "Ayu Mirage", value = "ayu_mirage", desc = "Ayu mirage variant — softer muted blue-grey" },
    { name = "Dracula", value = "dracula", desc = "Classic dark theme with grey comments & strings" },
  }

  tp.custom({
    prompt_title = "Theme Selector (Current: " .. (theme_labels[_G.current_theme] or "Bearded Arc") .. ")",
    mode = "insert",
    finder = finders.new_table({
      results = themes,
      entry_maker = function(entry)
        local display_text = entry.name .. " — " .. entry.desc
        if entry.value == _G.current_theme then
          display_text = "✓ " .. display_text .. " 🎯 (CURRENT)"
        end
        return {
          value = entry.value,
          display = display_text,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          _G.apply_theme(selection.value)
          vim.notify("Theme: " .. (theme_labels[selection.value] or selection.value), vim.log.levels.INFO)
        end
      end)
      return true
    end,
  })
end

>>>>>>> 0e9ff36 (feat: enhance theme support and color configurations for light/dark modes)
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
  local tp = require("helpers.telescope_pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local mode_info = {}
  for i, mode in ipairs(_G.background_modes) do
    table.insert(mode_info, {
      index = i,
      name = mode.name,
      display = mode.name,
      description = string.format("Kanagawa %s", mode.name:lower())
      display = mode.name,
      description = string.format("Kanagawa %s", mode.name:lower())
    })
  end

  tp.custom({
    prompt_title = "Background Selector (Current: " .. _G.background_modes[_G.current_bg_index].name .. ")",
    mode = "normal",
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
  })
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
  -- Kanagawa (only theme)
  -- Kanagawa (only theme)
  {
    "rebelot/kanagawa.nvim",
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        commentStyle = { italic = true },
        functionStyle = { bold = true },
        keywordStyle = { bold = true },
        statementStyle = { bold = true },
        background = {
          dark = "wave",
          light = "lotus",
        },
      })

<<<<<<< HEAD
      _G.load_background_preference()
=======
      -- Apply saved theme
      if _G.current_theme == "zenwritten" then
        vim.opt.background = "dark"
        vim.cmd.colorscheme("zenwritten")
      elseif _G.current_theme == "modus_vivendi" then
        vim.opt.background = "dark"
        vim.cmd.colorscheme("modus_vivendi")
      elseif _G.current_theme == "github_dark_default" then
        vim.opt.background = "dark"
        vim.cmd.colorscheme("github_dark_default")
      elseif _G.current_theme == "ayu_dark" then
        require("ayu").setup({ mirage = false })
        vim.opt.background = "dark"
        vim.cmd.colorscheme("ayu-dark")
      elseif _G.current_theme == "ayu_mirage" then
        require("ayu").setup({ mirage = true })
        vim.opt.background = "dark"
        vim.cmd.colorscheme("ayu-mirage")
      elseif _G.current_theme == "dracula" then
        vim.opt.background = "dark"
        vim.cmd.colorscheme("dracula")
      elseif _G.current_theme == "kanagawa_lotus" then
        vim.opt.background = "light"
        vim.cmd.colorscheme("kanagawa-lotus")
        -- Auto-select warm Daylight background for light theme
        for i, mode in ipairs(_G.background_modes) do
          if mode.name == "Daylight" then
            _G.current_bg_index = i
            break
          end
        end
      else
        vim.opt.background = "dark"
        vim.cmd.colorscheme("bearded")
      end

      -- Apply Dracula-specific grey comments and strings at startup
      if _G.current_theme == "dracula" then
        vim.api.nvim_set_hl(0, "Comment", { fg = "#857a7b", italic = false })
        vim.api.nvim_set_hl(0, "@comment", { fg = "#857a7b", italic = false })
        vim.api.nvim_set_hl(0, "String", { fg = "#A19A5E" })
        vim.api.nvim_set_hl(0, "@string", { fg = "#A19A5E" })
        vim.api.nvim_set_hl(0, "@string.escape", { fg = "#A19A5E" })
        vim.api.nvim_set_hl(0, "@string.special", { fg = "#A19A5E" })
        vim.api.nvim_set_hl(0, "Character", { fg = "#A19A5E" })
        vim.api.nvim_set_hl(0, "@character", { fg = "#A19A5E" })
      end

      -- Apply the current background mode
>>>>>>> a438cfe (feat: enhance Neovim configuration with new plugins and keybindings)
      _G.set_background_mode(_G.current_bg_index)

<<<<<<< HEAD
=======
      -- Override LSP reference highlights to only underline (no color change)
      vim.api.nvim_set_hl(0, "LspReferenceText",  { underline = true, bg = "NONE" })
      vim.api.nvim_set_hl(0, "LspReferenceRead",  { underline = true, bg = "NONE" })
      vim.api.nvim_set_hl(0, "LspReferenceWrite", { underline = true, bg = "NONE" })

<<<<<<< HEAD
      -- Cursor — adapt to light/dark theme
      if _G.current_theme == "kanagawa_lotus" then
<<<<<<< HEAD
        vim.api.nvim_set_hl(0, "Cursor",  { fg = "#f2ecbc", bg = "#545464" })
        vim.api.nvim_set_hl(0, "lCursor", { fg = "#f2ecbc", bg = "#545464" })
=======
        vim.api.nvim_set_hl(0, "Cursor",  { fg = "#f5efdc", bg = "#3b4252" })
        vim.api.nvim_set_hl(0, "lCursor", { fg = "#f5efdc", bg = "#3b4252" })
>>>>>>> a438cfe (feat: enhance Neovim configuration with new plugins and keybindings)
      else
        vim.api.nvim_set_hl(0, "Cursor",  { fg = "#000000", bg = "#ffffff" })
        vim.api.nvim_set_hl(0, "lCursor", { fg = "#000000", bg = "#ffffff" })
      end
=======
      -- White block cursor
      vim.api.nvim_set_hl(0, "Cursor",  { fg = "#000000", bg = "#ffffff" })
      vim.api.nvim_set_hl(0, "lCursor", { fg = "#000000", bg = "#ffffff" })
>>>>>>> 0e4d1ab (feat: add white block cursor styling for improved visibility)

      -- Create autocmd to reapply background highlights when colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
<<<<<<< HEAD
        pattern = { "bearded", "zenwritten", "modus_vivendi", "kanagawa-lotus", "kanagawa", "github_dark_default", "ayu", "ayu-dark", "ayu-mirage", "dracula" },
=======
        pattern = { "bearded", "zenwritten", "modus_vivendi", "kanagawa-lotus", "github_dark_default", "ayu", "ayu-dark", "ayu-mirage", "dracula" },
>>>>>>> a438cfe (feat: enhance Neovim configuration with new plugins and keybindings)
        group = vim.api.nvim_create_augroup("AyuBackground", { clear = true }),
        callback = function()
          -- Skip if the change was triggered by our own apply_theme/set_background_mode
          if _G._applying_theme or _G._setting_bg then return end
          -- Reapply current background mode (handles highlights + bars)
          _G.set_background_mode(_G.current_bg_index)
          -- Re-override LSP reference highlights after colorscheme resets them
          vim.api.nvim_set_hl(0, "LspReferenceText",  { underline = true, bg = "NONE" })
          vim.api.nvim_set_hl(0, "LspReferenceRead",  { underline = true, bg = "NONE" })
          vim.api.nvim_set_hl(0, "LspReferenceWrite", { underline = true, bg = "NONE" })
<<<<<<< HEAD
          -- Cursor — adapt to light/dark
          if _G.current_theme == "kanagawa_lotus" then
            vim.api.nvim_set_hl(0, "Cursor",  { fg = "#f2ecbc", bg = "#545464" })
            vim.api.nvim_set_hl(0, "lCursor", { fg = "#f2ecbc", bg = "#545464" })
          else
            vim.api.nvim_set_hl(0, "Cursor",  { fg = "#000000", bg = "#ffffff" })
            vim.api.nvim_set_hl(0, "lCursor", { fg = "#000000", bg = "#ffffff" })
          end
=======
          -- White block cursor
          vim.api.nvim_set_hl(0, "Cursor",  { fg = "#000000", bg = "#ffffff" })
          vim.api.nvim_set_hl(0, "lCursor", { fg = "#000000", bg = "#ffffff" })
>>>>>>> 0e4d1ab (feat: add white block cursor styling for improved visibility)
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

<<<<<<< HEAD
>>>>>>> 0e9ff36 (feat: enhance theme support and color configurations for light/dark modes)
=======
>>>>>>> a438cfe (feat: enhance Neovim configuration with new plugins and keybindings)
      vim.keymap.set("n", "<leader>tb", function()
        _G.telescope_background_picker()
      end, { desc = "Change Background", silent = true })
      })

      _G.load_background_preference()
      _G.set_background_mode(_G.current_bg_index)

      vim.keymap.set("n", "<leader>tb", function()
        _G.telescope_background_picker()
      end, { desc = "Change Background", silent = true })
    end,
<<<<<<< HEAD
=======
    lazy = false
  },
  -- Zenbones: elegant monochrome theme family (zenwritten flavor)
  {
    "zenbones-theme/zenbones.nvim",
    lazy = true,
    dependencies = { "rktjmp/lush.nvim" },
  },
  -- Modus Themes: accessible high-contrast themes (Emacs port)
  {
    "miikanissi/modus-themes.nvim",
    lazy = true,
  },
  -- Kanagawa: beautiful theme inspired by Katsushika Hokusai
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
<<<<<<< HEAD
    config = function()
      require("kanagawa").setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = { bold = true },
        keywordStyle = { bold = true },
        statementStyle = { bold = true },
        transparent = false,
        theme = "lotus",
        background = {
          dark = "wave",
          light = "lotus",
        },
        colors = {
          theme = {
            lotus = {
              ui = {
                -- Use our Daylight palette values so bg overrides stay consistent
                bg       = "#f2ecbc", -- lotusWhite3
                bg_dim   = "#dcd5ac", -- lotusWhite1
                bg_gutter = "#e7dba0", -- lotusWhite4
              },
            },
          },
        },
        overrides = function(colors)
          local theme = colors.theme
          return {
            -- Telescope integration with proper light background
            TelescopeNormal       = { bg = theme.ui.bg },
            TelescopeBorder       = { bg = theme.ui.bg, fg = theme.ui.nontext },
            TelescopeResultsNormal = { bg = theme.ui.bg },
            TelescopePromptNormal = { bg = theme.ui.bg },
            TelescopePreviewNormal = { bg = theme.ui.bg },
            -- Noice / floating UI
            NoiceCmdlinePopup     = { bg = theme.ui.float.bg },
            NoiceCmdlinePopupBorder = { bg = theme.ui.float.bg },
            NoicePopup            = { bg = theme.ui.float.bg },
            NoicePopupBorder      = { bg = theme.ui.float.bg },
            NoiceConfirm          = { bg = theme.ui.float.bg },
            NoiceConfirmBorder    = { bg = theme.ui.float.bg },
            -- LSP reference underline only
            LspReferenceText      = { underline = true, bg = "NONE" },
            LspReferenceRead      = { underline = true, bg = "NONE" },
            LspReferenceWrite     = { underline = true, bg = "NONE" },
          }
        end,
      })
    end,
=======
    opts = {
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = { bold = true },
      keywordStyle = { bold = true },
      statementStyle = { bold = true },
      transparent = false,
      theme = "lotus",
    },
>>>>>>> a438cfe (feat: enhance Neovim configuration with new plugins and keybindings)
  },
  -- GitHub Theme: official GitHub color schemes
  {
    "projekt0n/github-nvim-theme",
    lazy = true,
  },
  -- Ayu Theme: clean dark/mirage/light theme
  {
    "Shatur/neovim-ayu",
    lazy = true,
  },
  -- Dracula Theme: classic dark theme
  {
    "Mofiqul/dracula.nvim",
    lazy = true,
>>>>>>> 0e9ff36 (feat: enhance theme support and color configurations for light/dark modes)
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
          enable = false,
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
          enable = false,
          priority = 10,
          use_treesitter = false, -- Keep false for better performance
          chars = { "│" }, -- Simple vertical line character
<<<<<<< HEAD
=======
          style = { { fg = (_G.current_theme == "kanagawa_lotus") and "#d5cea3" or "#3a3a3a" } },
>>>>>>> 0e9ff36 (feat: enhance theme support and color configurations for light/dark modes)
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
        "<D-o>",
        function()
          -- Create advanced symbol picker with hierarchical document order
          local function ordered_symbols_picker()
            local finders = require("telescope.finders")
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

            local tp = require("helpers.telescope_pickers")
            tp.custom({
                  prompt_title = "󰘦 Document Symbols (Document Order)",
                  finder = finders.new_table({
                    results = symbols,
                    entry_maker = make_symbol_entry,
                  }),
                  sorter = conf.generic_sorter({}),
                  previewer = conf.grep_previewer({}),
                  mode = "insert",
                  attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                      local selection = action_state.get_selected_entry()
                      actions.close(prompt_bufnr)
                      jump_to_symbol(selection)
                    end)
                    return true
                  end,
                })
          end
          ordered_symbols_picker()
        end,
        desc = "Document Symbols (Hierarchical)",
      },
      {
        "<D-S-o>",
        function()
          -- Create symbol type filter picker
          local function symbol_type_filter_picker()
            local tp = require("helpers.telescope_pickers")
            local finders = require("telescope.finders")
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

              tp.custom({
                prompt_title = "󰘦 Filtered Symbols - " .. filter_type .. " (" .. #filtered_symbols .. ")",
                finder = finders.new_table({
                  results = filtered_symbols,
                  entry_maker = make_symbol_entry,
                }),
                sorter = conf.generic_sorter({}),
                previewer = conf.grep_previewer({}),
                mode = "normal",
                attach_mappings = function(prompt_bufnr, map)
                  actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    jump_to_symbol(selection)
                  end)
                  return true
                end,
              })
            end

            -- Show type filter picker
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
              attach_mappings = function(prompt_bufnr, map)
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
        { "<leader>gc", group = "Conflicts" },
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
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      local alpha = require("alpha")
      local theta = require("alpha.themes.theta")
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
            if not name then break end
            if (typ == "file") and name:match("%.vim$") and name ~= ".vim" then
              local full = session_dir .. "/" .. name
              local stat = vim.loop.fs_stat(full)
              if stat then
                table.insert(sessions, { name = name, mtime = stat.mtime.sec })
              end
            end
          end
        end
        table.sort(sessions, function(a, b) return a.mtime > b.mtime end)

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
          local display_name = vim.fn.fnamemodify(project_path, ":t")  -- last dir component
          local shortcut = "p" .. i

          -- Build restore command: cd to the decoded path, then restore the session
          local restore_cmd = string.format(
            "<cmd>cd %s | lua require('auto-session').restore_session()<CR>",
            vim.fn.fnameescape(project_path)
          )

          local btn = dashboard.button(
            shortcut,
            "  " .. display_name .. "  (" .. project_path .. ")",
            restore_cmd
          )
          btn.opts.width = 72
          table.insert(buttons, btn)
        end

        return buttons
      end

      -- ── Build the projects section ───────────────────────────────
      local projects_section = {
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

      -- ── Inject the projects section into theta's layout ──────────
      -- theta.config.layout is an ordered list of sections; we insert
      -- our projects section just before the last element (the footer).
      local layout = theta.config.layout
      -- Insert a padding + our section before the footer
      table.insert(layout, #layout, { type = "padding", val = 2 })
      table.insert(layout, #layout, projects_section)

      alpha.setup(theta.config)
    end,
  },
}
