return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      scope = { enabled = false }, -- disabled in favor of mini.indentscope
    },
    config = function(_, opts)
      require("ibl").setup(opts)
    end,
  },
}
