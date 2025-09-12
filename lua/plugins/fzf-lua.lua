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

        -- Open files
        -- vim.keymap.set('n', '<C-p>', "<cmd>lua require('fzf-lua').files()<CR>", { desc = 'Open files in working directory' }),
        -- vim.keymap.set('n', '<leader>fg', "<cmd>lua require('fzf-lua').git_files()<CR>", { desc = '[f]ind [g]it-ls files' }),

        -- Grep
        -- vim.keymap.set('n', '<leader>ga', "<cmd>lua require('fzf-lua').live_grep_glob()<CR>", { desc = '[g]rep [a]ll' }),
        -- vim.keymap.set('n', '<leader>gb', "<cmd>lua require('fzf-lua').lgrep_curbuf()<CR>", { desc = '[g]rep [b]uffer' }),
        -- vim.keymap.set('n', '<leader>gw', "<cmd>lua require('fzf-lua').grep_cword()<CR>", { desc = '[g]rep [w]word under cursor' }),
        -- vim.keymap.set('n', '<leader>gv', "<cmd>lua require('fzf-lua').grep_visual()<CR>", { desc = '[g]rep [v]isual selection' }),
        -- vim.keymap.set('n', '<leader>gr', "<cmd>lua require('fzf-lua').live_grep_resume()<CR>", { desc = '[g]rep [r]esume' }),

        -- Misc
        -- vim.keymap.set('n', '<leader>fk', "<cmd>lua require('fzf-lua').keymaps()<CR>", { desc = '[f]ind [k]eymap' }),
        -- vim.keymap.set('n', '<leader>fh', "<cmd>lua require('fzf-lua').help_tags()<CR>", { desc = '[f]ind [h]elp' }),
        -- vim.keymap.set('n', '<leader>fb', "<cmd>lua require('fzf-lua').builtin()<CR>", { desc = '[f]ind [b]uiltin' }),
        -- vim.keymap.set('n', '<leader>fc', "<cmd>lua require('fzf-lua').commands()<CR>", { desc = '[f]ind [c]ommands' }),
        -- vim.keymap.set('n', '<leader>fm', "<cmd>lua require('fzf-lua').manpages()<CR>", { desc = '[f]ind [m]anpages' }),
        -- vim.keymap.set('n', '<leader>fr', "<cmd>lua require('fzf-lua').registers()<CR>", { desc = '[f]ind [r]egisters' }),
        -- vim.keymap.set('n', '<leader>fs', "<cmd>lua require('fzf-lua').spell_suggest()<CR>", { desc = '[f]ind [s]pell suggestions' }),
        -- vim.keymap.set('n', '<leader>ft', "<cmd>lua require('fzf-lua').tags()<CR>", { desc = '[f]ind [t]ags' }),

        -- Navigation
        -- vim.keymap.set('n', '<leader>b', "<cmd>lua require('fzf-lua').buffers()<CR>", { desc = '[b]uffers' }),
        -- vim.keymap.set('n', '<leader>m', "<cmd>lua require('fzf-lua').marks()<CR>", { desc = '[m]arks' }),
        -- vim.keymap.set('n', '<leader>j', "<cmd>lua require('fzf-lua').jumps()<CR>", { desc = '[j]umplist' }),
        -- vim.keymap.set('n', '<leader>t', "<cmd>lua require('fzf-lua').tags()<CR>", { desc = '[t]ags' }),

        -- History
        -- vim.keymap.set('n', '<leader>hc', "<cmd>lua require('fzf-lua').command_history()<CR>", { desc = '[h]istory [c]ommands' }),
        -- vim.keymap.set('n', '<leader>hs', "<cmd>lua require('fzf-lua').search_history()<CR>", { desc = '[h]istory [s]earch' }),
        -- vim.keymap.set('n', '<leader>hf', "<cmd>lua require('fzf-lua').oldfiles()<CR>", { desc = '[h]istory [f]iles' }),
      }
    end,
  },
}
