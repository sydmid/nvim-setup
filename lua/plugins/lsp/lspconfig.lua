return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      ---@diagnostic disable-next-line: missing-fields
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      ---@diagnostic disable-next-line: missing-fields
      { 'j-hui/fidget.nvim',       opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
      { "folke/neodev.nvim", opts = {} },
      "glepnir/lspsaga.nvim",
    },
    opts = {
      setup = {
        clangd = function(_, opts)
          local clangd_ext_opts = LazyVim.opts 'clangd_extensions.nvim'
          require('clangd_extensions').setup(vim.tbl_deep_extend('force', clangd_ext_opts or {}, { server = opts }))
          return false
        end,
      },
    },
    config = function()
      -- Fix position_encoding warning
      local orig_util = vim.lsp.util
      local orig_make_position_params = orig_util.make_position_params
      orig_util.make_position_params = function(winnr, encoding)
        return orig_make_position_params(winnr, encoding or "utf-8")
      end

      -- Configure diagnostics for Error Lens integration
      -- Enhanced diagnostic configuration with Error Lens support
      vim.diagnostic.config({
        virtual_text = false,                                -- Disabled - Error Lens handles inline display
        signs = {
          severity = { min = vim.diagnostic.severity.HINT }, -- Show all diagnostic signs
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = " ",
          }
        },
        underline = false, -- Disabled - No diagnostic underlines
        update_in_insert = false,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
          format = function(diagnostic)
            -- Enhanced formatting for floating diagnostics
            local severity_map = {
              [vim.diagnostic.severity.ERROR] = "ERROR",
              [vim.diagnostic.severity.WARN] = "WARN",
              [vim.diagnostic.severity.INFO] = "INFO",
              [vim.diagnostic.severity.HINT] = "HINT"
            }
            local severity = severity_map[diagnostic.severity] or "UNKNOWN"
            local code = diagnostic.code and string.format(" [%s]", diagnostic.code) or ""
            return string.format("%s: %s%s", severity, diagnostic.message, code)
          end,
        },
      })

      -- Configure LSP signature help with improved styling and fixed dimensions
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
        focusable = true,                                -- Make it focusable for navigation
        silent = true,
        close_events = { "BufHidden", "InsertCharPre" }, -- Remove CursorMoved to keep it open
        max_width = 80,
        max_height = 15,
        wrap = true,
        -- Custom styling
        style = "minimal",
        -- Position the window near the cursor
        anchor_bias = "below",
        -- Force window dimensions
        width = 80,
        height = 15,
        -- Additional styling options
        title = " Signature Help ",
        title_pos = "center",
        -- Window position
        relative = "cursor",
        row = 1,
        col = 0,
      })

      -- Configure LSP hover with consistent styling
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
        focusable = true,
        style = "minimal",
        max_width = 80,
        max_height = 15,
        wrap = true,
        title = " Documentation ",
        title_pos = "center",
        close_events = { "BufHidden" }, -- Only close when leaving buffer, not on cursor movement
      })



      -- Custom signature help function with better window management and focus support
      local function show_signature_help()
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, 'textDocument/signatureHelp', params, function(err, result, ctx, config)
          if err or not result or not result.signatures or #result.signatures == 0 then
            return
          end

          -- Custom window configuration with enhanced focus management
          local opts = {
            border = "rounded",
            focusable = true,
            style = "minimal",
            max_width = 80,
            max_height = 15,
            wrap = true,
            title = " Signature Help ",
            title_pos = "center",
            close_events = { "BufHidden" },
          }

          local bufnr, winnr = vim.lsp.handlers["textDocument/signatureHelp"](err, result, ctx,
            vim.tbl_extend("force", config or {}, opts))

          -- Ensure the signature help window is focusable and can be navigated
          if winnr and vim.api.nvim_win_is_valid(winnr) then
            -- Set up keymaps for focusing and navigation
            vim.defer_fn(function()
              if vim.api.nvim_win_is_valid(winnr) then
                -- Allow focusing the signature help window with Tab
                vim.keymap.set('n', '<Tab>', function()
                    vim.api.nvim_set_current_win(winnr)
                  end,
                  { buffer = vim.api.nvim_get_current_buf(), desc = "Focus signature help window", nowait = true })

                vim.keymap.set('i', '<Tab>', function()
                    vim.api.nvim_set_current_win(winnr)
                  end,
                  { buffer = vim.api.nvim_get_current_buf(), desc = "Focus signature help window", nowait = true })

                -- Set up keymaps within the signature help window for navigation
                if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
                  vim.keymap.set('n', '<Esc>', function()
                    if vim.api.nvim_win_is_valid(winnr) then
                      vim.api.nvim_win_close(winnr, true)
                    end
                  end, { buffer = bufnr, nowait = true })

                  vim.keymap.set('n', 'q', function()
                    if vim.api.nvim_win_is_valid(winnr) then
                      vim.api.nvim_win_close(winnr, true)
                    end
                  end, { buffer = bufnr, nowait = true })

                  -- Allow scrolling within the signature help window
                  vim.keymap.set('n', 'j', function()
                    vim.api.nvim_win_call(winnr, function()
                      vim.cmd('normal! j')
                    end)
                  end, { buffer = bufnr, nowait = true })

                  vim.keymap.set('n', 'k', function()
                    vim.api.nvim_win_call(winnr, function()
                      vim.cmd('normal! k')
                    end)
                  end, { buffer = bufnr, nowait = true })
                end
              end
            end, 10)
          end
        end)
      end

      -- Setup LSP
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Disable signature help capability to prevent auto-suggestions
      capabilities.textDocument.signatureHelp = nil

      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")


      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          local keymap = vim.keymap.set
          local client = vim.lsp.get_client_by_id(ev.data.client_id)

          -- Standard LSP navigation commands for non-C# files
          keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { buffer = ev.buf, desc = "Go to definition" })
          keymap("n", "<leader>pd", "<cmd>Lspsaga peek_definition<CR>",
            { buffer = ev.buf, desc = "Peek definition" })
          -- Go everywhere for the symbol under the cursor.
          keymap('n', 'ga', "<cmd>lua require('fzf-lua').lsp_finder()<CR>",
            { desc = '[g]o [a]ll usages' })
          keymap("n", "gr", function()
            require("telescope.builtin").lsp_references({
              initial_mode = "normal",
              path_display = { "smart" },
              include_declaration = false,  -- Exclude the declaration itself
              include_current_line = false, -- Custom option we'll handle
              -- Force preview to show even for single results
              preview = {
                check_mime_type = false,
                hide_on_startup = false,
              },
              layout_config = {
                preview_width = 0.6,
                width = 0.9,
                height = 0.8,
              },
              -- Ensure first result is selected and previewed
              selection_strategy = "reset",
              sorting_strategy = "ascending",
              attach_mappings = function(prompt_bufnr, map_func)
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")

                -- Custom mapping to ensure preview is triggered
                local function ensure_preview()
                  local selection = action_state.get_selected_entry()
                  if selection then
                    -- Force preview refresh
                    require("telescope.actions").preview_scrolling_up(prompt_bufnr)
                    require("telescope.actions").preview_scrolling_down(prompt_bufnr)
                  end
                end

                map_func("i", "<Esc>", actions.close)
                map_func("n", "<Esc>", actions.close)
                map_func("n", "q", actions.close)

                -- Add preview refresh on movement
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
              -- Filter out the current line to avoid showing keymap definitions
              entry_maker = function(entry)
                local make_entry = require("telescope.make_entry")
                local default_entry = make_entry.gen_from_quickfix({})(entry)

                if default_entry then
                  -- Get current buffer and line
                  local current_buf = vim.api.nvim_get_current_buf()
                  local current_line = vim.api.nvim_win_get_cursor(0)[1]
                  local current_file = vim.api.nvim_buf_get_name(current_buf)

                  -- Filter out references from the same line in the same file
                  if entry.filename == current_file and entry.lnum == current_line then
                    return nil -- Skip this entry
                  end

                  -- Enhanced display with better formatting
                  default_entry.display = function(ent)
                    local path_display = require("telescope.utils").path_smart(ent.filename)
                    local line_preview = ent.text and ent.text:gsub("^%s+", "") or
                        "" -- Trim leading whitespace
                    return string.format("%s:%d:%d │ %s", path_display, ent.lnum, ent.col,
                      line_preview)
                  end
                end

                return default_entry
              end,
              -- Enhanced previewer for better reliability
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
                define_preview = function(self, entry, status)
                  if not entry or not entry.filename then
                    return
                  end

                  -- Enhanced preview function with better initialization
                  local function setup_preview_and_highlight()
                    if not entry.lnum or not self.state.winid or not vim.api.nvim_win_is_valid(self.state.winid) then
                      return
                    end

                    -- Set cursor position with better error handling
                    pcall(vim.api.nvim_win_set_cursor, self.state.winid,
                      { entry.lnum, math.max(0, (entry.col or 1) - 1) })

                    -- Center the line in the window
                    pcall(vim.api.nvim_win_call, self.state.winid, function()
                      vim.cmd("normal! zz")
                    end)

                    -- Clear previous highlights
                    pcall(vim.api.nvim_buf_clear_namespace, self.state.bufnr, -1, 0, -1)

                    -- Apply highlighting with enhanced logic
                    if entry.lnum and entry.col then
                      -- First, highlight the entire line with a subtle background
                      pcall(vim.api.nvim_buf_add_highlight,
                        self.state.bufnr,
                        -1,
                        "TelescopePreviewLine",
                        entry.lnum - 1,
                        0,
                        -1
                      )

                      -- Then highlight the specific symbol with a more prominent color
                      local lines = vim.api.nvim_buf_get_lines(self.state.bufnr, entry.lnum - 1,
                        entry.lnum, false)
                      if lines and lines[1] then
                        local line_text = lines[1]
                        local col = math.max(0, entry.col - 1)

                        -- Find word boundaries for the symbol
                        local start_col = col
                        local end_col = col

                        -- Expand to word boundaries
                        while start_col > 0 and line_text:sub(start_col, start_col):match("[%w_]") do
                          start_col = start_col - 1
                        end
                        if start_col < col and not line_text:sub(start_col + 1, start_col + 1):match("[%w_]") then
                          start_col = start_col + 1
                        end

                        while end_col < #line_text and line_text:sub(end_col + 1, end_col + 1):match("[%w_]") do
                          end_col = end_col + 1
                        end

                        -- Apply symbol highlight with bright color
                        if end_col >= start_col then
                          pcall(vim.api.nvim_buf_add_highlight,
                            self.state.bufnr,
                            -1,
                            "TelescopeMatching",
                            entry.lnum - 1,
                            start_col,
                            end_col + 1
                          )
                        end
                      end
                    end
                  end

                  -- Robust preview with multiple attempts and error handling
                  local ok = pcall(function()
                    require("telescope.previewers").buffer_previewer_maker(entry.filename,
                      self.state.bufnr, {
                        bufname = self.state.bufname,
                        winid = self.state.winid,
                        preview = {
                          mime_type = vim.filetype.match({ filename = entry.filename }),
                        },
                      })

                    -- Multiple scheduling attempts to ensure highlighting works
                    -- Immediate attempt
                    setup_preview_and_highlight()

                    -- Scheduled attempt for better reliability
                    vim.schedule(function()
                      setup_preview_and_highlight()
                    end)

                    -- Delayed attempt for edge cases (especially single results)
                    vim.defer_fn(function()
                      setup_preview_and_highlight()
                    end, 10)

                    -- Additional delayed attempt for very slow loading
                    vim.defer_fn(function()
                      setup_preview_and_highlight()
                    end, 50)
                  end)

                  if not ok then
                    -- Fallback: show file content without special positioning
                    pcall(require("telescope.previewers").buffer_previewer_maker, entry.filename,
                      self.state.bufnr, {
                        bufname = self.state.bufname,
                        winid = self.state.winid,
                      })
                    -- Still try to apply highlighting even in fallback
                    vim.defer_fn(function()
                      setup_preview_and_highlight()
                    end, 100)
                  end
                end
              }),
              -- Force preview on single result by customizing telescope behavior
              default_selection_index = 1,
            })
          end, { buffer = ev.buf, desc = '[g]o [r]eferences' })
          keymap("n", "gi", function()
            require("telescope.builtin").lsp_implementations({
              initial_mode = "normal",
              attach_mappings = function(prompt_bufnr, map_func)
                local actions = require("telescope.actions")
                map_func("i", "<Esc>", actions.close)
                map_func("n", "<Esc>", actions.close)
                map_func("n", "q", actions.close)
                return true
              end,
            })
          end, { buffer = ev.buf, desc = '[g]o [I]mplementation' })
          keymap("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>",
            { buffer = ev.buf, desc = '[g]o [t]ype definition' })

          -- Common LSP keymaps for all languages
          -- keymap("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          keymap('n', 'gD', "<cmd>lua require('fzf-lua').lsp_declarations()<CR>",
            { desc = '[g]o [D]eclarations' })
          keymap("n", "<leader>pt", "<cmd>Lspsaga peek_type_definition<CR>",
            { buffer = ev.buf, desc = "Peek type definition" })

          -- Navigate symbols
          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          keymap('n', '<leader>ls', "<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>",
            { desc = '[l]list [s]ymbols (document)' })

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          keymap('n', '<leader>lS', "<cmd>lua require('fzf-lua').lsp_live_workspace_symbols()<CR>",
            { desc = '[L]ist all [S]ymbols (workspace)' })

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          keymap('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[r]e [n]ame symbol under cursor' })
          keymap('n', '<F2>', vim.lsp.buf.rename, { desc = 'Rename symbol under cursor' })

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          keymap('n', '<leader>ca', vim.lsp.buf.code_action, { desc = '[c]ode [a]ction' })

          keymap("n", "<leader>pd", "<cmd>Lspsaga peek_definition<CR>",
            { buffer = ev.buf, desc = "[p]eek [d]efinition" })
          keymap("n", "<leader>pt", "<cmd>Lspsaga peek_type_definition<CR>",
            { buffer = ev.buf, desc = "[p]eek [t]ype definition" })

          -- Manual signature help triggers (auto-suggestions disabled)
          -- Use <D-S-i> (Cmd+Shift+I) to manually show function signatures when needed
          keymap("n", "<D-S-i>", function()
            show_signature_help()
          end, { buffer = ev.buf, desc = "Show method signature (manual & focusable)", silent = true })

          keymap("i", "<D-S-i>", function()
            show_signature_help()
          end, { buffer = ev.buf, desc = "Show method signature (manual & focusable)", silent = true })

          -- Signature help navigation between overloads
          keymap("i", "<C-k>", function()
            if vim.fn.pumvisible() == 0 then
              -- Navigate to previous signature overload
              local params = vim.lsp.util.make_position_params()
              vim.lsp.buf_request(0, 'textDocument/signatureHelp', params,
                function(err, result, ctx, config)
                  if result and result.signatures and #result.signatures > 1 then
                    local current = result.activeSignature or 0
                    local prev = current > 0 and current - 1 or #result.signatures - 1
                    result.activeSignature = prev

                    local opts = {
                      border = "rounded",
                      focusable = true,
                      style = "minimal",
                      max_width = 80,
                      max_height = 15,
                      wrap = true,
                      title = " Signature Help (" ..
                          (prev + 1) .. "/" .. #result.signatures .. ") ",
                      title_pos = "center",
                    }
                    vim.lsp.handlers["textDocument/signatureHelp"](err, result, ctx,
                      vim.tbl_extend("force", config or {}, opts))
                  else
                    show_signature_help()
                  end
                end)
            else
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-p>", true, false, true), "n", false)
            end
          end, { buffer = ev.buf, desc = "Previous signature overload or completion", silent = true })

          keymap("i", "<C-j>", function()
            if vim.fn.pumvisible() == 0 then
              -- Navigate to next signature overload
              local params = vim.lsp.util.make_position_params()
              vim.lsp.buf_request(0, 'textDocument/signatureHelp', params,
                function(err, result, ctx, config)
                  if result and result.signatures and #result.signatures > 1 then
                    local current = result.activeSignature or 0
                    local next = (current + 1) % #result.signatures
                    result.activeSignature = next

                    local opts = {
                      border = "rounded",
                      focusable = true,
                      style = "minimal",
                      max_width = 80,
                      max_height = 15,
                      wrap = true,
                      title = " Signature Help (" ..
                          (next + 1) .. "/" .. #result.signatures .. ") ",
                      title_pos = "center",
                    }
                    vim.lsp.handlers["textDocument/signatureHelp"](err, result, ctx,
                      vim.tbl_extend("force", config or {}, opts))
                  else
                    show_signature_help()
                  end
                end)
            else
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", false)
            end
          end, { buffer = ev.buf, desc = "Next signature overload or completion", silent = true })

          -- Auto-trigger signature help when typing function parameters (DISABLED)
          -- local function auto_signature_help()
          -- 	if vim.fn.pumvisible() == 0 then
          -- 		show_signature_help()
          -- 	end
          -- end

          -- Auto-trigger on opening parentheses and commas (DISABLED - use manual trigger <D-S-i> instead)
          -- keymap("i", "(", function()
          -- 	vim.api.nvim_feedkeys("(", "n", false)
          -- 	vim.defer_fn(auto_signature_help, 100)
          -- end, { buffer = ev.buf, desc = "Auto-trigger signature help", silent = true })

          -- keymap("i", ",", function()
          -- 	vim.api.nvim_feedkeys(",", "n", false)
          -- 	vim.defer_fn(auto_signature_help, 100)
          -- end, { buffer = ev.buf, desc = "Auto-trigger signature help", silent = true })

          keymap("n", "<D-i>", function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then
              vim.notify("No LSP client attached to current buffer", vim.log.levels.WARN)
              return
            end

            local params = vim.lsp.util.make_position_params()

            local function enhanced_hover_handler(err, result, ctx, config)
              if err then
                vim.notify("LSP hover error: " .. tostring(err), vim.log.levels.ERROR)
                return
              end

              if not result or not result.contents then
                vim.notify("No hover information available", vim.log.levels.INFO)
                return
              end

              -- 🔧 Normalize the hover text so it renders clean
              local function normalize_hover(contents)
                local text = ""
                if type(contents) == "string" then
                  text = contents
                elseif vim.tbl_islist(contents) then
                  for _, v in ipairs(contents) do
                    if type(v) == "string" then
                      text = text .. v .. "\n"
                    elseif type(v) == "table" and v.value then
                      text = text .. v.value .. "\n"
                    end
                  end
                elseif type(contents) == "table" and contents.value then
                  text = contents.value
                end

                return {
                  kind = "markdown",
                  value = text
                      :gsub("\\%.", ".")   -- unescape dots
                      :gsub("\\%-", "-")   -- unescape -
                      :gsub("\\%(", "(")   --
                      :gsub("\\%[", "[")   --
                      :gsub("\\%<", "<")   --
                      :gsub("\\%)", ")")   --
                      :gsub("\\%]", "]")   --
                      :gsub("\\%>", ">")   --
                      :gsub("\\%*", "*")   --
                      :gsub("&nbsp;", " ") -- fix spaces
                      :gsub("\\_", "_")    -- unescape underscores
                      :gsub("\\`", "`"),   -- unescape backticks
                }
              end

              -- Enhanced window configuration with proper focus management
              local opts = vim.tbl_extend("force", config or {}, {
                border = "rounded",
                focusable = true,
                style = "minimal",
                max_width = 80,
                max_height = 15,
                wrap = true,
                title = " Documentation ",
                title_pos = "center",
                close_events = { "BufHidden" },
              })
              local bufnr = {}
              local winnr = {}
              for _, client in ipairs(clients) do
                if client.name == "roslyn" or client.name == "gopls" then
                  local cleaned = normalize_hover(result.contents)
                  local new_result = { contents = cleaned }
                  -- Use default hover handler, but with cleaned contents
                  bufnr, winnr = vim.lsp.handlers["textDocument/hover"](err, new_result, ctx, opts)
                else
                  bufnr, winnr = vim.lsp.handlers["textDocument/hover"](err, result, ctx, opts)
                end
              end

              if winnr and vim.api.nvim_win_is_valid(winnr) then
                vim.defer_fn(function()
                  if vim.api.nvim_win_is_valid(winnr) then
                    local original_buf = vim.api.nvim_get_current_buf()

                    vim.keymap.set('n', '<Tab>', function()
                      if vim.api.nvim_win_is_valid(winnr) then
                        vim.api.nvim_set_current_win(winnr)
                      end
                    end, { buffer = original_buf, desc = "Focus hover window", nowait = true })

                    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
                      vim.keymap.set('n', '<Esc>', function()
                        if vim.api.nvim_win_is_valid(winnr) then
                          vim.api.nvim_win_close(winnr, true)
                        end
                      end, { buffer = bufnr, nowait = true, silent = true })

                      vim.keymap.set('n', 'q', function()
                        if vim.api.nvim_win_is_valid(winnr) then
                          vim.api.nvim_win_close(winnr, true)
                        end
                      end, { buffer = bufnr, nowait = true, silent = true })

                      vim.keymap.set('n', 'j', function()
                        if vim.api.nvim_win_is_valid(winnr) then
                          vim.api.nvim_win_call(winnr, function()
                            vim.cmd('normal! j')
                          end)
                        end
                      end, { buffer = bufnr, nowait = true, silent = true })

                      vim.keymap.set('n', 'k', function()
                        if vim.api.nvim_win_is_valid(winnr) then
                          vim.api.nvim_win_call(winnr, function()
                            vim.cmd('normal! k')
                          end)
                        end
                      end, { buffer = bufnr, nowait = true, silent = true })

                      vim.keymap.set('n', '<Esc>', function()
                        if vim.api.nvim_win_is_valid(winnr) then
                          vim.api.nvim_win_close(winnr, true)
                          return
                        end
                        vim.cmd("nohlsearch")
                      end, { buffer = original_buf, nowait = true, silent = true })

                      vim.api.nvim_create_autocmd("WinClosed", {
                        pattern = tostring(winnr),
                        once = true,
                        callback = function()
                          pcall(vim.keymap.del, 'n', '<Esc>', { buffer = original_buf })
                        end,
                      })
                    end
                  end
                end, 10)

                local group = vim.api.nvim_create_augroup("LspHoverEscClose_" .. winnr, { clear = true })
                vim.api.nvim_create_autocmd("WinEnter", {
                  group = group,
                  callback = function()
                    local current_win = vim.api.nvim_get_current_win()
                    if current_win == winnr and vim.api.nvim_win_is_valid(winnr) then
                      vim.keymap.set('n', '<Esc>', function()
                        if vim.api.nvim_win_is_valid(winnr) then
                          vim.api.nvim_win_close(winnr, true)
                        end
                      end, { buffer = bufnr, nowait = true, silent = true })
                    end
                  end,
                })

                vim.api.nvim_create_autocmd("WinClosed", {
                  pattern = tostring(winnr),
                  once = true,
                  callback = function()
                    pcall(vim.api.nvim_del_augroup_by_id, group)
                  end,
                })
              end
            end

            vim.lsp.buf_request(0, 'textDocument/hover', params, enhanced_hover_handler)
          end, { buffer = ev.buf, desc = "Show documentation (Enhanced & Focusable)", silent = true })
          -- Additional useful Lspsaga keymaps
          keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>",
            { buffer = ev.buf, desc = "Code actions (Lspsaga)" })
          keymap("n", "<leader>lr", "<cmd>Lspsaga rename<CR>",
            { buffer = ev.buf, desc = "Rename symbol (Lspsaga)" })
          keymap("n", "<leader>lf", "<cmd>Lspsaga finder<CR>", { buffer = ev.buf, desc = "LSP finder" })
          keymap("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { buffer = ev.buf, desc = "LSP outline" })

          -- Enhanced line diagnostics with better formatting (replacing lspsaga)
          keymap("n", "<leader>xx", function()
            -- Use vim's native diagnostics with enhanced formatting
            local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })

            if #diagnostics == 0 then
              vim.notify("No diagnostics found on current line", vim.log.levels.INFO)
              return
            end

            -- Create a comprehensive diagnostic display
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

            table.insert(lines, "Line " .. vim.fn.line('.') .. " Diagnostics:")
            table.insert(lines, "")

            for i, diagnostic in ipairs(diagnostics) do
              local icon = severity_icons[diagnostic.severity] or "󰌶"
              local severity = severity_names[diagnostic.severity] or "UNKNOWN"
              local source = diagnostic.source and (" [" .. diagnostic.source .. "]") or ""
              local code = diagnostic.code and (" (" .. diagnostic.code .. ")") or ""

              table.insert(lines, string.format("%s %s%s%s", icon, severity, source, code))
              table.insert(lines, "  " .. diagnostic.message)

              if i < #diagnostics then
                table.insert(lines, "")
              end
            end

            -- Show in a floating window with better styling
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

            -- Set buffer filetype for syntax highlighting
            vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')

            local width = math.min(80, vim.o.columns - 4)
            local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.4))

            local win = vim.api.nvim_open_win(buf, false, {
              relative = 'cursor',
              width = width,
              height = height,
              row = 1,
              col = 0,
              border = 'rounded',
              style = 'minimal',
              title = ' Line Diagnostics ',
              title_pos = 'center',
              focusable = true, -- Make it focusable for better interaction
            })

            -- Set window options
            vim.api.nvim_win_set_option(win, 'wrap', true)
            vim.api.nvim_win_set_option(win, 'linebreak', true)

            -- Auto-close on buffer change or insert mode (removed CursorMoved for stability)
            local group = vim.api.nvim_create_augroup('LineDiagnosticFloat', { clear = true })
            vim.api.nvim_create_autocmd({ 'BufLeave', 'InsertEnter' }, {
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

            -- Auto-close after 10 seconds (timeout)
            vim.defer_fn(function()
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
              end
              pcall(vim.api.nvim_del_augroup_by_id, group)
            end, 10000)

            -- Add keymap to close manually
            vim.keymap.set('n', '<Esc>', function()
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
              end
            end, { buffer = buf, nowait = true })

            vim.keymap.set('n', 'q', function()
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
              end
            end, { buffer = buf, nowait = true })
          end, { buffer = ev.buf, desc = "Line diagnostics (enhanced native)" })

          keymap("n", "<leader>xf", function()
            require("telescope.builtin").diagnostics({
              bufnr = 0,
              attach_mappings = function(prompt_bufnr, map_func)
                local actions = require("telescope.actions")
                map_func("i", "<Esc>", actions.close)
                map_func("n", "<Esc>", actions.close)
                map_func("n", "q", actions.close)
                return true
              end,
            })
          end, { buffer = ev.buf, desc = "Buffer diagnostics" })

          -- Enhanced diagnostic navigation that works with Error Lens
          keymap("n", "]x", function()
            vim.diagnostic.goto_next({
              severity = { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.ERROR },
            })
            if _G.ErrorLens and _G.ErrorLens.enabled then
              vim.defer_fn(function()
                _G.ErrorLens.refresh_current_buffer()
              end, 50)
            end
          end, { buffer = ev.buf, desc = "Next error (with Error Lens sync)" })

          keymap("n", "[x", function()
            vim.diagnostic.goto_prev({
              severity = { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.ERROR },
            })
            if _G.ErrorLens and _G.ErrorLens.enabled then
              vim.defer_fn(function()
                _G.ErrorLens.refresh_current_buffer()
              end, 50)
            end
          end, { buffer = ev.buf, desc = "Previous error (with Error Lens sync)" })
        end,
      })

      -- newer versions of mason-lspconfig
      -- Set up servers manually
      local servers = {
        "ts_ls", "html", "cssls", "tailwindcss", "svelte", "lua_ls", "graphql",
        "emmet_ls", "prismals", "pyright", "ruff", "eslint", "bashls", "roslyn",
        "gopls", "rust_analyzer", "taplo", "clangd"
      }

      for _, server_name in ipairs(servers) do
        if server_name == "lua_ls" then
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } },
                completion = { callSnippet = "Replace" },
              },
            },
          })
        elseif server_name == "bashls" then
          lspconfig.bashls.setup({
            capabilities = capabilities,
            filetypes = { "sh", "bash", "zsh" },
            init_options = {
              filetypes = { "sh", "bash", "zsh" },
            },
            settings = {
              bashIde = {
                shellcheckPath = "",
              },
            },
          })
        elseif server_name == "pyright" then
          lspconfig.pyright.setup({
            capabilities = capabilities,
            settings = {
              pyright = {
                -- Using Ruff's import organizer
                disableOrganizeImports = true,
                -- Disable some features that Ruff handles better
                disableTaggedHints = false,
              },
              python = {
                analysis = {
                  -- Enhanced type checking
                  typeCheckingMode = "strict",
                  -- Auto-import completions
                  autoImportCompletions = true,
                  -- Use workspace libraries
                  useLibraryCodeForTypes = true,
                  -- Diagnostic modes
                  diagnosticMode = "workspace",
                  -- Auto-search paths
                  autoSearchPaths = true,
                  -- Stub path
                  stubPath = "typings",
                  -- Extra paths for analysis
                  extraPaths = {},
                  -- Diagnostic severity overrides
                  diagnosticSeverityOverrides = {
                    reportMissingTypeStubs = "none",
                    reportUnknownParameterType = "none",
                    reportUnknownArgumentType = "none",
                    reportUnknownLambdaType = "none",
                    reportUnknownVariableType = "none",
                    reportUnknownMemberType = "none",
                    reportMissingParameterType = "none",
                  },
                },
              },
            },
          })
        elseif server_name == "ruff" then
          -- Ruff LSP for ultra-fast Python linting and formatting
          lspconfig.ruff.setup({
            capabilities = capabilities,
            init_options = {
              settings = {
                -- Ruff configuration
                args = {
                  "--config=pyproject.toml", -- Use pyproject.toml if available
                },
              }
            },
            -- Organize imports capability
            on_attach = function(client, bufnr)
              -- Disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
            end,
          })
        elseif server_name == "rust_analyzer" then
          -- Professional Rust LSP configuration with rust-analyzer (fallback)
          lspconfig.rust_analyzer.setup({
            capabilities = capabilities,
            filetypes = { "rust" },
            root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json"),
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  buildScripts = { enable = true },
                  allTargets = true,
                  features = "all",
                },
                procMacro = { enable = true },
                diagnostics = { enable = true, enableExperimental = true },
                completion = {
                  callable = { snippets = "fill_arguments" },
                  postfix = { enable = true },
                },
                inlayHints = {
                  enable = true,
                  chainingHints = { enable = true },
                  parameterHints = { enable = true },
                  typeHints = { enable = true },
                },
                lens = { enable = true },
                check = { command = "clippy" },
              },
            },
            on_attach = function(client, bufnr)
              if client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
              end
            end,
          })
        elseif server_name == "taplo" then
          -- TOML language server configuration (fallback)
          lspconfig.taplo.setup({
            capabilities = capabilities,
            filetypes = { "toml" },
            root_dir = lspconfig.util.root_pattern("*.toml", ".git"),
          })
        elseif server_name == "gopls" then
          -- Go language server configuration (fallback)
          lspconfig.gopls.setup({
            capabilities = capabilities,
            filetypes = { "go", "gomod", "gowork", "gotmpl" },
            root_dir = lspconfig.util.root_pattern("go.mod", "go.work", ".git"),
            settings = {
              gopls = {
                completeUnimported = true,
                usePlaceholders = true,
                analyses = {
                  unusedparams = true,
                  unreachable = true,
                  fillstruct = true,
                },
                staticcheck = true,
                gofumpt = true,
              },
            },
          })
        elseif server_name == "ts_ls" then
          -- TypeScript/JavaScript language server configuration (fallback)
          lspconfig.ts_ls.setup({
            capabilities = capabilities,
            filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
            root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json",
              ".git"),
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                },
              },
              javascript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                },
              },
            },
            on_attach = function(client, bufnr)
              if client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
              end
              local keymap = vim.keymap.set
              keymap("n", "<leader>to", function()
                vim.lsp.buf.execute_command({ command = "_typescript.organizeImports", arguments = { vim.api.nvim_buf_get_name(0) } })
              end, { buffer = bufnr, desc = "Organize imports" })
              keymap("n", "<leader>ti", function()
                vim.lsp.buf.code_action({
                  filter = function(action)
                    return action.title ==
                        "Add missing imports"
                  end,
                  apply = true
                })
              end, { buffer = bufnr, desc = "Add missing imports" })
              keymap("n", "<leader>tf", function()
                vim.lsp.buf.code_action({
                  filter = function(action)
                    return action.title:match(
                      "Fix all")
                  end,
                  apply = true
                })
              end, { buffer = bufnr, desc = "Fix all" })
              keymap("n", "<leader>tu", function()
                vim.lsp.buf.code_action({
                  filter = function(action)
                    return action.title:match(
                      "Remove unused")
                  end,
                  apply = true
                })
              end, { buffer = bufnr, desc = "Remove unused" })
            end,
          })
        elseif server_name == "clangd" then
          lspconfig.clangd.setup({
            keys = {
              { '<leader>ch', '<cmd>ClangdSwitchSourceHeader<cr>', desc = 'Switch Source/Header (C/C++)' },
            },
            root_dir = function(fname)
              return require('lspconfig.util').root_pattern(
                    'Makefile',
                    'configure.ac',
                    'configure.in',
                    'config.h.in',
                    'meson.build',
                    'meson_options.txt',
                    'build.ninja'
                  )(fname) or
                  require('lspconfig.util').root_pattern('compile_commands.json', 'compile_flags.txt')(
                    fname) or require('lspconfig.util').find_git_ancestor(
                    fname
                  )
            end,
            capabilities = {
              offsetEncoding = { 'utf-16' },
            },
            cmd = {
              'clangd',
              '--background-index',
              '--clang-tidy',
              '--header-insertion=iwyu',
              '--completion-style=detailed',
              '--function-arg-placeholders',
              '--fallback-style=llvm',
            },
            init_options = {
              usePlaceholders = true,
              completeUnimported = true,
              clangdFileStatus = true,
            },
          })
        end
      end

      -- Add filetype detection for common shell files
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { ".bashrc", ".zshrc", ".bash_profile", ".profile", ".zsh_*", ".bash_*", ".env" },
        callback = function(ev)
          vim.bo[ev.buf].filetype = "sh"
        end,
      })

      -- Add filetype detection for Python files
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.py", "*.pyi", "*.pyw", ".pythonrc", "SConstruct", "SConscript", "*.wsgi" },
        callback = function(ev)
          vim.bo[ev.buf].filetype = "python"
        end,
      })

      -- Add filetype detection for Rust files
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.rs", "*.rlib" },
        callback = function(ev)
          vim.bo[ev.buf].filetype = "rust"
        end,
      })

      -- Add filetype detection for TOML files (Cargo.toml, etc.)
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.toml", "Cargo.toml", "Cargo.lock", "pyproject.toml" },
        callback = function(ev)
          vim.bo[ev.buf].filetype = "toml"
        end,
      })

      -- Add filetype detection for Go files
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.go", "go.mod", "go.sum", "go.work", "go.work.sum", "*.gotmpl" },
        callback = function(ev)
          local filename = vim.fn.expand("%:t")
          if filename == "go.mod" or filename == "go.work" then
            vim.bo[ev.buf].filetype = "gomod"
          elseif filename == "go.sum" or filename == "go.work.sum" then
            vim.bo[ev.buf].filetype = "gosum"
          elseif vim.fn.expand("%:e") == "gotmpl" then
            vim.bo[ev.buf].filetype = "gotmpl"
          else
            vim.bo[ev.buf].filetype = "go"
          end
        end,
      })

      -- Add filetype detection for TypeScript/JavaScript files
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.ts", "*.tsx", "*.js", "*.jsx", "*.mjs", "*.cjs" },
        callback = function(ev)
          local ext = vim.fn.expand("%:e")
          if ext == "ts" then
            vim.bo[ev.buf].filetype = "typescript"
          elseif ext == "tsx" then
            vim.bo[ev.buf].filetype = "typescriptreact"
          elseif ext == "js" or ext == "mjs" or ext == "cjs" then
            vim.bo[ev.buf].filetype = "javascript"
          elseif ext == "jsx" then
            vim.bo[ev.buf].filetype = "javascriptreact"
          end
        end,
      })
    end,
  },
  {
    'p00f/clangd_extensions.nvim',
    dependencies = { 'mortepau/codicons.nvim' },
    lazy = true,
    config = function() end,
    opts = {
      inlay_hints = {
        inline = false,
      },
      ast = {
        --These require codicons (https://github.com/microsoft/vscode-codicons)
        role_icons = {
          type = '',
          declaration = '',
          expression = '',
          specifier = '',
          statement = '',
          ['template argument'] = '',
        },
        kind_icons = {
          Compound = '',
          Recovery = '',
          TranslationUnit = '',
          PackExpansion = '',
          TemplateTypeParm = '',
          TemplateTemplateParm = '',
          TemplateParamObject = '',
        },
      },
    },
  },
}
