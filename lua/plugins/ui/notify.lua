return {
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
}
