return {
  -- Telescope symbols (replaces symbols-outline with beautiful telescope UI)
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<D-o>",
        function()
          symbol_pickers.open_ordered_symbols_picker()
        end,
        desc = "Document Symbols (Hierarchical)",
      },
      {
        "<D-S-o>",
        function()
          symbol_pickers.open_symbol_type_filter_picker()
        end,
        desc = "Filter Document Symbols by Type",
      },
    },
  },
}
