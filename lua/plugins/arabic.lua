return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "arabic" })
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        -- Add any specific LSP configurations for Arabic if needed
      },
    },
  },

  {
    "nvim-lua/plenary.nvim",
    lazy = false,
    config = function()
      -- Arabic language support setup
      local arabic_group = vim.api.nvim_create_augroup("ArabicSupport", { clear = true })

      -- Define a function to toggle Arabic mode with all required settings
      _G.toggle_arabic = function()
        if vim.o.arabic then
          -- Disable Arabic mode
          vim.o.arabic = false
          vim.notify("Arabic mode disabled", vim.log.levels.INFO)
        else
          -- Enable Arabic mode
          vim.o.arabic = true
          vim.o.arabicshape = true
          vim.o.encoding = "utf-8"
          vim.o.rightleft = true
          vim.o.rightleftcmd = "search"
          vim.o.delcombine = true
          vim.keymap.set('i', '<C-^>', function()
            if vim.b.keymap_name == "arabic" then
              vim.b.keymap_name = nil
              vim.notify("Arabic keymap disabled", vim.log.levels.INFO)
            else
              vim.b.keymap_name = "arabic"
              vim.notify("Arabic keymap enabled", vim.log.levels.INFO)
            end
          end, { silent = true, desc = "Toggle Arabic keymap" })
          vim.notify("Arabic mode enabled", vim.log.levels.INFO)
        end
      end

      -- Create command to toggle Arabic mode
      vim.api.nvim_create_user_command("ArabicToggle", function()
        _G.toggle_arabic()
      end, { desc = "Toggle Arabic language support" })

      -- Create command to specifically enable Arabic mode
      vim.api.nvim_create_user_command("Arabic", function()
        vim.o.arabic = true
        vim.o.arabicshape = true
        vim.o.encoding = "utf-8"
        vim.o.rightleft = true
        vim.o.rightleftcmd = "search"
        vim.o.delcombine = true
        vim.cmd("set keymap=arabic")
        vim.notify("Arabic mode enabled", vim.log.levels.INFO)
      end, { desc = "Enable Arabic language support" })

      -- Create command to specifically disable Arabic mode
      vim.api.nvim_create_user_command("NoArabic", function()
        vim.o.arabic = false
        vim.o.rightleft = false
        vim.o.rightleftcmd = ""
        vim.cmd("set keymap=")
        vim.notify("Arabic mode disabled", vim.log.levels.INFO)
      end, { desc = "Disable Arabic language support" })

      -- Add keymappings for quickly toggling Arabic mode
      vim.keymap.set("n", "<leader>ta", ":ArabicToggle<CR>", { silent = true, desc = "Toggle Arabic Mode" })

      -- In Arabic mode, set options for a better Arabic experience
      vim.api.nvim_create_autocmd("OptionSet", {
        group = arabic_group,
        pattern = "arabic",
        callback = function()
          if vim.v.option_new == "1" then
            -- When Arabic is enabled
            vim.o.arabicshape = true
            vim.o.rightleft = true
            vim.o.rightleftcmd = "search"
            vim.o.delcombine = true
            vim.cmd("set keymap=arabic")
          else
            -- When Arabic is disabled
            vim.o.rightleft = false
            vim.o.rightleftcmd = ""
            vim.cmd("set keymap=")
          end
        end,
      })
    end,
  }
}