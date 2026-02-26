return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    -- Pin current tab
    { "<leader>tt", "<cmd>BufferLineTogglePin<CR>", desc = "Pin/unpin tab" },

    -- Smart close current tab (Cmd+w)
    {
      "<M-w>",
      function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.bo[bufnr].modified then
          local choice = vim.fn.confirm(
            "Buffer has unsaved changes. Save before closing?",
            "&Save\n&Discard\n&Cancel",
            3
          )
          if choice == 1 then
            vim.cmd("write")
            Snacks.bufdelete(bufnr)
          elseif choice == 2 then
            Snacks.bufdelete({ buf = bufnr, force = true })
          end
          -- choice == 3 or 0: cancel
        else
          Snacks.bufdelete(bufnr)
        end
      end,
      desc = "Smart close current tab",
    },

    -- Smart close all: close every buffer except current and pinned
    {
      "<leader>tr",
      function()
        local current_buf = vim.api.nvim_get_current_buf()
        -- Use bufferline.groups to check pinned state
        local groups_ok, bl_groups = pcall(require, "bufferline.groups")
        local function is_pinned(bufnr)
          if groups_ok and bl_groups and bl_groups._is_pinned then
            return bl_groups._is_pinned({ id = bufnr })
          end
          return false
        end

        -- Collect buffers to close (not current, not pinned, valid listed buffers)
        local to_close = {}
        local modified_bufs = {}
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(bufnr)
            and vim.bo[bufnr].buflisted
            and bufnr ~= current_buf
            and not is_pinned(bufnr)
          then
            if vim.bo[bufnr].modified then
              table.insert(modified_bufs, bufnr)
            else
              table.insert(to_close, bufnr)
            end
          end
        end

        -- Handle modified buffers: ask once for all
        if #modified_bufs > 0 then
          local names = {}
          for _, bufnr in ipairs(modified_bufs) do
            local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
            if name == "" then name = "[No Name]" end
            table.insert(names, name)
          end
          local choice = vim.fn.confirm(
            #modified_bufs .. " buffer(s) have unsaved changes:\n" .. table.concat(names, ", ") .. "\n\nWhat to do?",
            "&Save All\n&Discard All\n&Cancel",
            3
          )
          if choice == 1 then
            for _, bufnr in ipairs(modified_bufs) do
              vim.api.nvim_buf_call(bufnr, function() vim.cmd("write") end)
              table.insert(to_close, bufnr)
            end
          elseif choice == 2 then
            for _, bufnr in ipairs(modified_bufs) do
              vim.bo[bufnr].modified = false
              table.insert(to_close, bufnr)
            end
          end
          -- choice == 3 or 0: skip modified buffers
        end

        -- Close collected buffers
        local closed = 0
        for _, bufnr in ipairs(to_close) do
          pcall(Snacks.bufdelete, bufnr)
          closed = closed + 1
        end

        if closed > 0 then
          vim.notify("Closed " .. closed .. " buffer(s)", vim.log.levels.INFO)
        else
          vim.notify("No buffers to close", vim.log.levels.INFO)
        end
      end,
      desc = "Close all except current & pinned",
    },

    -- New tab + file picker (Cmd+t): opens picker, if dismissed lands in scratch buffer
    {
      "<M-t>",
      function()
        -- Helper to set up scratch buffer with :w support
        local function setup_scratch(buf)
          if not vim.api.nvim_buf_is_valid(buf) then return end
          vim.api.nvim_set_current_buf(buf)
          vim.bo[buf].buflisted = true
          vim.bo[buf].swapfile = false
          -- Create buffer-local :W command and also override :w via abbreviation
          vim.api.nvim_buf_create_user_command(buf, "W", function(opts)
            local path = opts.args
            if path == "" then
              path = vim.fn.input("Save as: ", vim.fn.getcwd() .. "/", "file")
            end
            if path and path ~= "" then
              vim.api.nvim_buf_set_name(buf, path)
              -- Create parent directories if needed
              local dir = vim.fn.fnamemodify(path, ":h")
              if vim.fn.isdirectory(dir) == 0 then
                vim.fn.mkdir(dir, "p")
              end
              vim.cmd("write!")
              vim.notify("Saved to " .. path, vim.log.levels.INFO)
              -- Remove the abbreviation and command since buffer now has a name
              pcall(function()
                vim.api.nvim_buf_del_user_command(buf, "W")
                vim.cmd("silent! cunabbrev <buffer> w")
              end)
            end
          end, { nargs = "?", complete = "file", desc = "Save new buffer to path" })
          -- Make :w redirect to :W for this buffer
          vim.cmd("cabbrev <buffer> w W")
          vim.notify("New buffer — type and hit :w to save to a file", vim.log.levels.INFO)
        end

        -- Create the new empty buffer first
        vim.cmd("enew")
        local scratch_buf = vim.api.nvim_get_current_buf()

        -- Try telescope frecency picker (shows all files, recent priority)
        local ok_tel, telescope = pcall(require, "telescope")
        local ok_frecency = ok_tel and pcall(require, "frecency")

        local esc_mapping = function(_, map_fn)
          local tel_actions = require("telescope.actions")
          map_fn("i", "<Esc>", function(prompt_bufnr)
            tel_actions.close(prompt_bufnr)
            setup_scratch(scratch_buf)
          end)
          return true
        end

        if ok_frecency then
          telescope.extensions.frecency.frecency({
            prompt_title = "  New Tab — pick file or Esc for scratch",
            workspace = "CWD",
            show_unindexed = true,
            attach_mappings = esc_mapping,
          })
        elseif ok_tel then
          require("telescope.builtin").find_files({
            prompt_title = "  New Tab — pick file or Esc for scratch",
            attach_mappings = esc_mapping,
          })
        end
      end,
      desc = "New tab + file picker (Esc = scratch buffer)",
    },
  },
  opts = {
    options = {
      -- Use snacks.bufdelete for proper buffer closing
      close_command = function(n) Snacks.bufdelete(n) end,
      right_mouse_command = function(n) Snacks.bufdelete(n) end,

      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(count, level)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,

      -- Show buffer close button
      show_close_icon = false,
      show_buffer_close_icons = true,

      -- Separator style
      separator_style = "slant",

      -- Keep pinned tabs on the left
      sort_by = function(buffer_a, buffer_b)
        -- Pinned buffers always come first
        if buffer_a.pinned ~= buffer_b.pinned then
          return buffer_a.pinned
        end
        -- Then sort by most recently used
        return buffer_a.id < buffer_b.id
      end,

      -- Offsets for sidebars
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          separator = true,
        },
      },
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
  end,
}
