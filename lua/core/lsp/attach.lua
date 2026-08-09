local M = {}

function M.setup(border)
  local signature = require("core.lsp.signature")
  local hover = require("core.lsp.hover")

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
      local keymap = vim.keymap.set
      local client = vim.lsp.get_client_by_id(ev.data.client_id)

      local function open_fold_after_jump()
        vim.defer_fn(function()
          pcall(vim.cmd, "silent! normal! zv")
        end, 200)
      end

      keymap("n", "gd", function()
        vim.cmd("Lspsaga goto_definition")
        open_fold_after_jump()
      end, { buffer = ev.buf, desc = "Go to definition" })
      keymap("n", "<leader>pd", "<cmd>Lspsaga peek_definition<CR>",
        { buffer = ev.buf, desc = "Peek definition" })
      keymap("n", "ga", "<cmd>lua require('fzf-lua').lsp_finder()<CR>",
        { desc = "[g]o [a]ll usages" })
      keymap("n", "gr", function()
        require("helpers.telescope_pickers").builtin("lsp_references", {
          mode = "normal",
          path_display = { "smart" },
          include_declaration = false,
          include_current_line = false,
          preview = {
            check_mime_type = false,
            hide_on_startup = false,
          },
          layout_config = {
            preview_width = 0.6,
            width = 0.9,
            height = 0.8,
          },
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          attach_mappings = function(prompt_bufnr, map_func)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            local function ensure_preview()
              local selection = action_state.get_selected_entry()
              if selection then
                require("telescope.actions").preview_scrolling_up(prompt_bufnr)
                require("telescope.actions").preview_scrolling_down(prompt_bufnr)
              end
            end

            map_func("n", "j", function()
              actions.move_selection_next(prompt_bufnr)
              ensure_preview()
            end)
            map_func("n", "k", function()
              actions.move_selection_previous(prompt_bufnr)
              ensure_preview()
            end)

            return true
          end,
          entry_maker = function(entry)
            local make_entry = require("telescope.make_entry")
            local default_entry = make_entry.gen_from_quickfix({})(entry)

            if default_entry then
              local current_buf = vim.api.nvim_get_current_buf()
              local current_line = vim.api.nvim_win_get_cursor(0)[1]
              local current_file = vim.api.nvim_buf_get_name(current_buf)

              if entry.filename == current_file and entry.lnum == current_line then
                return nil
              end

              default_entry.display = function(ent)
                local path_display = require("telescope.utils").path_smart(ent.filename)
                local line_preview = ent.text and ent.text:gsub("^%s+", "") or ""
                return string.format("%s:%d:%d │ %s", path_display, ent.lnum, ent.col, line_preview)
              end
            end

            return default_entry
          end,
          previewer = require("telescope.previewers").new_buffer_previewer({
            title = "LSP References",
            dyn_title = function(_, entry)
              if entry and entry.filename then
                return vim.fn.fnamemodify(entry.filename, ":t")
              end
              return "LSP References"
            end,
            get_buffer_by_name = function(_, entry)
              return entry and entry.filename or ""
            end,
            define_preview = function(self, entry)
              if not entry or not entry.filename then
                return
              end

              local function setup_preview_and_highlight()
                if not entry.lnum or not self.state.winid or not vim.api.nvim_win_is_valid(self.state.winid) then
                  return
                end

                pcall(vim.api.nvim_win_set_cursor, self.state.winid, { entry.lnum, math.max(0, (entry.col or 1) - 1) })
                pcall(vim.api.nvim_win_call, self.state.winid, function()
                  vim.cmd("normal! zz")
                end)
                pcall(vim.api.nvim_buf_clear_namespace, self.state.bufnr, -1, 0, -1)

                if entry.lnum and entry.col then
                  pcall(vim.api.nvim_buf_add_highlight, self.state.bufnr, -1, "TelescopePreviewLine", entry.lnum - 1, 0,
                    -1)

                  local lines = vim.api.nvim_buf_get_lines(self.state.bufnr, entry.lnum - 1, entry.lnum, false)
                  if lines and lines[1] then
                    local line_text = lines[1]
                    local col = math.max(0, entry.col - 1)
                    local start_col = col
                    local end_col = col

                    while start_col > 0 and line_text:sub(start_col, start_col):match("[%w_]") do
                      start_col = start_col - 1
                    end
                    if start_col < col and not line_text:sub(start_col + 1, start_col + 1):match("[%w_]") then
                      start_col = start_col + 1
                    end

                    while end_col < #line_text and line_text:sub(end_col + 1, end_col + 1):match("[%w_]") do
                      end_col = end_col + 1
                    end

                    if end_col >= start_col then
                      pcall(vim.api.nvim_buf_add_highlight, self.state.bufnr, -1, "TelescopeMatching", entry.lnum - 1,
                        start_col, end_col + 1)
                    end
                  end
                end
              end

              local ok = pcall(function()
                require("telescope.previewers").buffer_previewer_maker(entry.filename, self.state.bufnr, {
                  bufname = self.state.bufname,
                  winid = self.state.winid,
                  preview = {
                    mime_type = vim.filetype.match({ filename = entry.filename }),
                  },
                })

                setup_preview_and_highlight()
                vim.schedule(setup_preview_and_highlight)
                vim.defer_fn(setup_preview_and_highlight, 10)
                vim.defer_fn(setup_preview_and_highlight, 50)
              end)

              if not ok then
                pcall(require("telescope.previewers").buffer_previewer_maker, entry.filename, self.state.bufnr, {
                  bufname = self.state.bufname,
                  winid = self.state.winid,
                })
                vim.defer_fn(setup_preview_and_highlight, 100)
              end
            end,
          }),
          default_selection_index = 1,
        })
      end, { buffer = ev.buf, desc = "[g]o [r]eferences" })

      keymap("n", "gi", function()
        require("helpers.telescope_pickers").builtin("lsp_implementations", { mode = "normal" })
      end, { buffer = ev.buf, desc = "[g]o [I]mplementation" })
      keymap("n", "gt", function()
        vim.cmd("Lspsaga goto_type_definition")
        open_fold_after_jump()
      end, { buffer = ev.buf, desc = "[g]o [t]ype definition" })

      keymap("n", "gD", "<cmd>lua require('fzf-lua').lsp_declarations()<CR>", { desc = "[g]o [D]eclarations" })
      keymap("n", "<leader>pt", "<cmd>Lspsaga peek_type_definition<CR>",
        { buffer = ev.buf, desc = "Peek type definition" })
      keymap("n", "<leader>ls", "<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>",
        { desc = "[l]list [s]ymbols (document)" })
      keymap("n", "<leader>lS", "<cmd>lua require('fzf-lua').lsp_live_workspace_symbols()<CR>",
        { desc = "[L]ist all [S]ymbols (workspace)" })
      keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[r]e [n]ame symbol under cursor" })
      keymap("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol under cursor" })
      keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "[c]ode [a]ction" })
      keymap("n", "<leader>pd", "<cmd>Lspsaga peek_definition<CR>", { buffer = ev.buf, desc = "[p]eek [d]efinition" })
      keymap("n", "<leader>pt", "<cmd>Lspsaga peek_type_definition<CR>",
        { buffer = ev.buf, desc = "[p]eek [t]ype definition" })

      keymap({ "n", "i" }, "<D-i>", function()
        signature.show_signature_help(border)
      end, { buffer = ev.buf, desc = "Show signature help", silent = true })
      keymap("i", "<C-k>", function()
        signature.previous_or_complete(border)
      end, { buffer = ev.buf, desc = "Previous signature overload or completion", silent = true })
      keymap("i", "<C-j>", function()
        signature.next_or_complete(border)
      end, { buffer = ev.buf, desc = "Next signature overload or completion", silent = true })
      keymap("n", "gh", function()
        hover.request_hover(border)
      end, { buffer = ev.buf, desc = "Show documentation (Enhanced & Focusable)", silent = true })

      keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { buffer = ev.buf, desc = "Code actions (Lspsaga)" })
      keymap("n", "<leader>lr", "<cmd>Lspsaga rename<CR>", { buffer = ev.buf, desc = "Rename symbol (Lspsaga)" })
      keymap("n", "<leader>lf", "<cmd>Lspsaga finder<CR>", { buffer = ev.buf, desc = "LSP finder" })
      keymap("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { buffer = ev.buf, desc = "LSP outline" })

      keymap("n", "<leader>xx", function()
        local line_diags = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
        if #line_diags == 0 then
          vim.notify("No diagnostics found on current line", vim.log.levels.INFO)
          return
        end

        local lines = {}
        local severity_icons = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = " ",
        }
        local severity_names = {
          [vim.diagnostic.severity.ERROR] = "ERROR",
          [vim.diagnostic.severity.WARN] = "WARN",
          [vim.diagnostic.severity.INFO] = "INFO",
          [vim.diagnostic.severity.HINT] = "HINT",
        }

        table.insert(lines, "Line " .. vim.fn.line(".") .. " Diagnostics:")
        table.insert(lines, "")

        for i, diagnostic in ipairs(line_diags) do
          local icon = severity_icons[diagnostic.severity] or "󰌶"
          local severity = severity_names[diagnostic.severity] or "UNKNOWN"
          local source = diagnostic.source and (" [" .. diagnostic.source .. "]") or ""
          local code = diagnostic.code and (" (" .. diagnostic.code .. ")") or ""
          table.insert(lines, string.format("%s %s%s%s", icon, severity, source, code))
          table.insert(lines, "  " .. diagnostic.message)
          if i < #line_diags then
            table.insert(lines, "")
          end
        end

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

        local width = math.min(80, vim.o.columns - 4)
        local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.4))
        local win = vim.api.nvim_open_win(buf, false, {
          relative = "cursor",
          width = width,
          height = height,
          row = 1,
          col = 0,
          border = "rounded",
          style = "minimal",
          title = " Line Diagnostics ",
          title_pos = "center",
          focusable = true,
        })

        vim.api.nvim_win_set_option(win, "wrap", true)
        vim.api.nvim_win_set_option(win, "linebreak", true)

        local group = vim.api.nvim_create_augroup("LineDiagnosticFloat", { clear = true })
        vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave", "InsertEnter" }, {
          group = group,
          buffer = vim.api.nvim_get_current_buf(),
          once = true,
          callback = function()
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_close(win, true)
            end
            vim.api.nvim_del_augroup_by_id(group)
          end,
        })

        vim.defer_fn(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
          pcall(vim.api.nvim_del_augroup_by_id, group)
        end, 10000)

        vim.keymap.set("n", "<Esc>", function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end, { buffer = buf, nowait = true })
        vim.keymap.set("n", "q", function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end, { buffer = buf, nowait = true })
      end, { buffer = ev.buf, desc = "Line diagnostics (enhanced native)" })

      keymap("n", "<leader>xf", function()
        require("helpers.telescope_pickers").builtin("diagnostics", { bufnr = 0 })
      end, { buffer = ev.buf, desc = "Buffer diagnostics" })

      keymap("n", "]x", function()
        vim.diagnostic.goto_next({ severity = { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.ERROR } })
      end, { buffer = ev.buf, desc = "Next error" })
      keymap("n", "[x", function()
        vim.diagnostic.goto_prev({ severity = { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.ERROR } })
      end, { buffer = ev.buf, desc = "Previous error" })
      keymap("n", "<leader>xj", function()
        vim.diagnostic.goto_next({ severity = { min = vim.diagnostic.severity.WARN } })
      end, { buffer = ev.buf, desc = "Next warning or error" })
      keymap("n", "<leader>xk", function()
        vim.diagnostic.goto_prev({ severity = { min = vim.diagnostic.severity.WARN } })
      end, { buffer = ev.buf, desc = "Previous warning or error" })

      if client and client.server_capabilities then
        -- Reserved for future client-specific attach behavior.
      end
    end,
  })
end

return M
