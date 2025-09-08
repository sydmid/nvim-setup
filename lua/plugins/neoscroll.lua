return {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
        -- Setup neoscroll with no default mappings
        require("neoscroll").setup({
            mappings = {},      -- Disable all default mappings
            hide_cursor = true, -- Hide cursor while scrolling for better visual experience
            stop_eof = true,    -- Stop at <EOF> when scrolling downwards
            respect_scrolloff = false, -- Stop scrolling when cursor reaches scrolloff margin
            cursor_scrolls_alone = true, -- Cursor keeps scrolling even if window can't scroll further
            duration_multiplier = 1.0, -- Global duration multiplier
            easing = "quadratic", -- Smooth easing function for better animation
            pre_hook = nil,     -- Function to run before scrolling starts
            post_hook = nil,    -- Function to run after scrolling ends
            performance_mode = false, -- Keep syntax highlighting during scroll
            ignored_events = {  -- Events ignored while scrolling
                "WinScrolled",
                "CursorMoved",
            },
        })

        local neoscroll = require("neoscroll")

        -- Custom smooth scrolling keymaps
        local keymap = {
            ["<D-j>"] = function()
                neoscroll.scroll(5, { duration = 60, easing = "quadratic" })
            end,
            ["<D-k>"] = function()
                neoscroll.scroll(-5, { duration = 60, easing = "quadratic" })
            end,
            -- ["<S-j>"] = function()
            --     neoscroll.scroll(10, { duration = 60, easing = "quadratic" })
            -- end,
            -- ["<S-k>"] = function()
            --     neoscroll.scroll(-10, { duration = 60, easing = "quadratic" })
            -- end,
            ["<C-u>"] = function()
                neoscroll.ctrl_u({ duration = 40 })
            end,
            ["<C-d>"] = function()
                neoscroll.ctrl_d({ duration = 40 })
            end,
            ["<C-b>"] = function()
                neoscroll.ctrl_b({ duration = 40 })
            end,
            ["<C-f>"] = function()
                neoscroll.ctrl_f({ duration = 40 })
            end,
            ["<C-y>"] = function()
                neoscroll.scroll(-0.1, { move_cursor = false, duration = 40 })
            end,
            ["<C-e>"] = function()
                neoscroll.scroll(0.1, { move_cursor = false, duration = 40 })
            end,
            ["zt"] = function()
                neoscroll.zt({ half_win_duration = 40 })
            end,
            ["zz"] = function()
                neoscroll.zz({ half_win_duration = 40 })
            end,
            ["zb"] = function()
                neoscroll.zb({ half_win_duration = 40 })
            end,
        }

        -- Apply keymaps to normal, visual, and select modes
        local modes = { "n", "v", "x" }
        for key, func in pairs(keymap) do
            vim.keymap.set(modes, key, func, { silent = true, desc = "Smooth scroll" })
        end
    end,
}
