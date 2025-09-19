return {
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- This allows certain windows to use fzf-lua, specifically Ctrl-f in Mason
      require('fzf-lua').register_ui_select {
        winopts = {
          fullscreen = true,
        },
      }

      -- Configuration
      require('fzf-lua').setup {
        winopts = {
          fullscreen = true,
        },

      }
    end,
  },
}
