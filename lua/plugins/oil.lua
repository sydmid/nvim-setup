return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Function to change workspace to selected file's parent folder or selected folder
      local function change_workspace_to_selection()
        local oil = require("oil")
        local entry = oil.get_cursor_entry()
        if not entry then
          vim.notify("No entry selected", vim.log.levels.WARN)
          return
        end

        local current_dir = oil.get_current_dir()
        if not current_dir then
          vim.notify("Could not get current directory", vim.log.levels.ERROR)
          return
        end

        -- Ensure current_dir ends with a path separator
        if not current_dir:match("/$") then
          current_dir = current_dir .. "/"
        end

        local selected_path = current_dir .. entry.name
        local target_dir

        -- If it's a file, get its parent directory
        -- If it's a directory, use it directly
        if entry.type == "file" then
          target_dir = vim.fn.fnamemodify(selected_path, ":h")
        elseif entry.type == "directory" then
          target_dir = selected_path
        else
          -- For other types (links, etc.), try to determine if it's a directory
          local stat = vim.loop.fs_stat(selected_path)
          if stat and stat.type == "directory" then
            target_dir = selected_path
          else
            target_dir = vim.fn.fnamemodify(selected_path, ":h")
          end
        end

        -- Normalize the path
        target_dir = vim.fn.resolve(target_dir)

        -- Close oil first to prevent interference
        oil.close()

        -- Use vim.schedule to ensure operations happen after oil is properly closed
        vim.schedule(function()
          -- Change the working directory first
          vim.cmd("cd " .. vim.fn.fnameescape(target_dir))

          -- Close all windows except the current one
          vim.cmd("silent! only")

          -- Force close ALL buffers to start fresh in new workspace
          -- Use %bdelete to close all buffers and start with a clean slate
          vim.cmd("silent! %bdelete!")

          -- Ensure we have at least one buffer open
          if #vim.api.nvim_list_bufs() == 0 then
            vim.cmd("enew")
          end

          -- Stop LSP clients after buffer cleanup
          vim.schedule(function()
            vim.lsp.stop_client(vim.lsp.get_active_clients())
          end)

          -- Update nvim-tree to reflect the new workspace
          vim.schedule(function()
            local nvim_tree_ok, nvim_tree_api = pcall(require, "nvim-tree.api")
            if nvim_tree_ok then
              -- Change nvim-tree's root to the new workspace
              nvim_tree_api.tree.change_root(target_dir)
            end
          end)

          vim.notify("Workspace changed to: " .. target_dir, vim.log.levels.INFO)
        end)
      end

      require("oil").setup {
        columns = { "icon" },
        keymaps = {
          ["g?"] = { "actions.show_help", mode = "n" },
          ["<CR>"] = "actions.select",
          ["<BS>"] = { "actions.parent", mode = "n" },
          ["l"] = "actions.select",
          ["h"] = { "actions.parent", mode = "n" },
          ["<C-s>"] = { "actions.select", opts = { vertical = true } },
          ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
          ["<C-t>"] = { "actions.select", opts = { tab = true } },
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = { "actions.close", mode = "n" },
          ["<C-l>"] = "actions.refresh",
          -- ["_"] = { "actions.open_cwd", mode = "n" },
          ["`"] = { "actions.cd", mode = "n" },
          ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
          ["gs"] = { "actions.change_sort", mode = "n" },
          ["gx"] = "actions.open_external",
          ["g."] = { "actions.toggle_hidden", mode = "n" },
          ["g\\"] = { "actions.toggle_trash", mode = "n" },
          -- ["-"] = false,
          ["<Esc>"] = { "actions.close", mode = "n" },
          ["q"] = { "actions.close", mode = "n" },
          ["ts"] = { "actions.change_sort", mode = "n" },
          ["ee"] = "actions.open_external",
          ["th"] = { "actions.toggle_hidden", mode = "n" },
          ["<C-w>"] = { change_workspace_to_selection, mode = "n", desc = "Change workspace to selection" },

        },
        float = {
          padding = 2,
          max_width = 80,
          max_height = 30,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
          preview_split = "auto",
        },
        -- win_options = {
        --   winbar = "%{v:lua.CustomOilBar()}",
        -- },
        view_options = {
          show_hidden = false,
          is_always_hidden = function(name, _)
            -- folders/files you already skip
            local folder_skip = { "dev-tools.locks", "dune.lock", "_build" }
            if vim.tbl_contains(folder_skip, name) then
              return true
            end

            -- Always hide .DS_Store
            if name == ".DS_Store" then
              return true
            end

            -- Always hide files ending with .meta
            if name:match("%.meta$") then
              return true
            end

            return false
          end, },
      }

      -- Set custom highlight for directories (folders)
      vim.api.nvim_set_hl(0, "OilDir", { fg = "#84dc85" })

      -- Open parent directory in floating window
      -- vim.keymap.set("n", "<BS>", require("oil").toggle_float)
    end,
  },
}
