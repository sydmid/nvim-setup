local M = {}

function M.setup()
  local map = vim.keymap.set

  map({ "n", "i", "v", "t" }, "<D-`>", function()
    require("snacks").terminal.toggle()
  end, { desc = "Toggle terminal" })

  map({ "n", "v" }, "<D-s>", ":NvimTreeFindFileToggle<CR>", {
    desc = "Toggle NvimTree and reveal current file",
    silent = true,
  })

  map("n", "<leader>tw", function()
    if vim.opt.list:get() then
      vim.opt.list = false
      vim.notify("Whitespace display: OFF", vim.log.levels.INFO)
    else
      vim.opt.list = true
      vim.notify("Whitespace display: ON", vim.log.levels.INFO)
    end
  end, { desc = "Toggle whitespace display", silent = true })

  map("n", "<leader>cr", "<cmd>RunCode<CR>", { desc = "Run code in current buffer" })
  map("v", "<leader>cr", "<cmd>RunCode<CR>", { desc = "Run selected code" })

  map("n", "<BS>", "<CMD>Oil<CR>", { desc = "Open parent directory with Oil" })
  map("n", "<D-BS>", function()
    local root
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if client.config.root_dir then
        root = client.config.root_dir
        break
      end
    end
    require("oil").open(root or vim.fn.getcwd())
  end, { desc = "Open workspace root with Oil" })
end

return M
