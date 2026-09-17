return {
  {
    "goolord/alpha-nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local alpha = require("alpha")
      local theta = require("alpha.themes.theta")
      local alpha_dashboard = require("core.ui.alpha_dashboard")

      local projects_section = alpha_dashboard.get_projects_section()

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
