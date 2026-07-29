return {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
        require("neoscroll").setup({
            mappings = {},
            hide_cursor = true,
            stop_eof = true,
            respect_scrolloff = false,
            cursor_scrolls_alone = true,
            duration_multiplier = 1.0,
            easing = "quadratic",
            pre_hook = nil,
            post_hook = nil,
            performance_mode = false,
            ignored_events = {
                "WinScrolled",
                "CursorMoved",
            },
        })

        local neoscroll = require("neoscroll")

        local keymap = {
            ["<M-j>"] = function()
                neoscroll.scroll(10, { duration = 60, easing = "quadratic" })
            end,
            ["<A-k>"] = function()
                neoscroll.scroll(-10, { duration = 60, easing = "quadratic" })
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

        local modes = { "n", "v", "x" }
        for key, func in pairs(keymap) do
            vim.keymap.set(modes, key, func, { silent = true, desc = "Smooth scroll" })
        end
    end,
}
