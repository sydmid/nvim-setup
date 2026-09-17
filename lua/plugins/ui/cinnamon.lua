return {
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
}
