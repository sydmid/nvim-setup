return {
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
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = false, -- Disable named colors to avoid false positives
        RRGGBBAA = false, -- #RRGGBBAA hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features
        css_fn = true, -- Enable all CSS *functions*
        mode = "background", -- Set the display mode
      })
    end,
  },
}
