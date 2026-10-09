---@module "hover"
--- Custom LSP hover with enhanced UX for Neovim.
--- Based on OXY2DEV's lsp_hover.lua with additional features:
--- - ESC to close hover window
--- - Tab/Shift-Tab to focus and scroll hover window
--- - Quadrant-aware positioning
--- - Per-language-server styling
--- - Markdown rendering via markview.nvim
--- - Wrapped text with linebreak

local hover = {}

---@class hover.style Style for the hover window.
---@field condition? fun(client_name: string, result: table, context: table): boolean
---@field width? integer | fun(client_name: string, result: table, context: table): integer
---@field height? integer | fun(client_name: string, result: table, context: table): integer
---@field winhl? string | fun(client_name: string, result: table, context: table): string
---@field winopts? table | fun(client_name: string, result: table, context: table): table

---@class hover.style__static
---@field width? integer
---@field height? integer
---@field winhl? string
---@field winopts? table

--- Configuration for hover styles per language server
---@type table<string, hover.style>
hover.config = {
	default = {
		width = function()
			return math.floor(vim.o.columns * 0.5)
		end,
		height = function()
			return math.floor(vim.o.lines * 0.4)
		end,
	},

	lua_ls = {
		condition = function(client_name)
			return client_name == "lua_ls"
		end,
		winopts = {
			footer_pos = "right",
			footer = {
				{ " 󰢱 LuaLS ", "@function" }
			}
		}
	},

	basedpyright = {
		condition = function(client_name)
			return client_name == "basedpyright"
		end,
		winopts = {
			footer_pos = "right",
			footer = {
				{ " 󰌠 BasedPyright ", "@constant" }
			}
		}
	},

	pyright = {
		condition = function(client_name)
			return client_name == "pyright"
		end,
		winopts = {
			footer_pos = "right",
			footer = {
				{ " 󰌠 Pyright ", "@constant" }
			}
		}
	},

	ruff = {
		condition = function(client_name)
			return client_name == "ruff"
		end,
		winopts = {
			footer_pos = "right",
			footer = {
				{ " 󰌠 Ruff ", "@constant" }
			}
		}
	},

	typescript = {
		condition = function(client_name)
			return client_name == "ts_ls" or client_name == "vtsls"
		end,
		winopts = {
			footer_pos = "right",
			footer = {
				{ " 󰛦 TypeScript ", "@keyword" }
			}
		}
	},

	rust_analyzer = {
		condition = function(client_name)
			return client_name == "rust_analyzer"
		end,
		winopts = {
			footer_pos = "right",
			footer = {
				{ " 󱘗 Rust Analyzer ", "@type" }
			}
		}
	},

	gopls = {
		condition = function(client_name)
			return client_name == "gopls"
		end,
		winopts = {
			footer_pos = "right",
			footer = {
				{ " 󰟓 Gopls ", "@type" }
			}
		}
	},

	clangd = {
		condition = function(client_name)
			return client_name == "clangd"
		end,
		winopts = {
			footer_pos = "right",
			footer = {
				{ " 󰙲 Clangd ", "@type" }
			}
		}
	},

	roslyn = {
		condition = function(client_name)
			return client_name == "roslyn"
		end,
		winopts = {
			footer_pos = "right",
			footer = {
				{ " 󰌛 Roslyn ", "@type" }
			}
		}
	},
}

--- Gets LSP style for a given client
---@param client_name string
---@param result table
---@param context table
---@return hover.style__static
local function get_style(client_name, result, context)
	local keys = vim.tbl_keys(hover.config)
	local result_style = hover.config.default

	table.sort(keys)

	for _, key in ipairs(keys) do
		if key ~= "default" then
			local val = hover.config[key]
			local ran_cond, cond = pcall(val.condition, client_name, result, context)
			if ran_cond and cond then
				result_style = vim.tbl_deep_extend("force", result_style, val)
				break
			end
		end
	end

	local final_val = {}
	for k, v in pairs(result_style) do
		if type(v) ~= "function" then
			final_val[k] = v
		elseif k ~= "condition" then
			local can_eval, value = pcall(v, client_name, result, context)
			if can_eval then
				final_val[k] = value
			end
		end
	end

	return final_val
end

---@type integer?, integer? Hover buffer & window
hover.buffer, hover.window = nil, nil

---@type "top_left" | "top_right" | "bottom_left" | "bottom_right" | "center"?
hover.quad = nil

--- Prepares the buffer for the hover window
hover.__prepare = function()
	if not hover.buffer or not vim.api.nvim_buf_is_valid(hover.buffer) then
		hover.buffer = vim.api.nvim_create_buf(false, true)

		-- Close on 'q' key
		vim.api.nvim_buf_set_keymap(hover.buffer, "n", "q", "", {
			callback = function()
				if hover.window and vim.api.nvim_win_is_valid(hover.window) then
					vim.api.nvim_win_close(hover.window, true)
				end
				if hover.quad then
					hover.update_quad(hover.quad, false)
					hover.quad = nil
				end
				-- Return focus to previous window
				local prev_win = vim.fn.win_getid(vim.fn.winnr("#"))
				if prev_win and vim.api.nvim_win_is_valid(prev_win) then
					vim.api.nvim_set_current_win(prev_win)
				end
			end,
			desc = "Close hover window"
		})

		-- ESC to close
		vim.api.nvim_buf_set_keymap(hover.buffer, "n", "<Esc>", "", {
			callback = function()
				if hover.window and vim.api.nvim_win_is_valid(hover.window) then
					vim.api.nvim_win_close(hover.window, true)
				end
				if hover.quad then
					hover.update_quad(hover.quad, false)
					hover.quad = nil
				end
				local prev_win = vim.fn.win_getid(vim.fn.winnr("#"))
				if prev_win and vim.api.nvim_win_is_valid(prev_win) then
					vim.api.nvim_set_current_win(prev_win)
				end
			end,
			desc = "Close hover window (ESC)"
		})

		-- Tab to focus hover window and enable scrolling
		vim.api.nvim_buf_set_keymap(hover.buffer, "n", "<Tab>", "", {
			callback = function()
				if hover.window and vim.api.nvim_win_is_valid(hover.window) then
					vim.api.nvim_set_current_win(hover.window)
					-- Enable cursor movement in hover window
					vim.wo[hover.window].cursorline = true
				end
			end,
			desc = "Focus hover window (Tab)"
		})

		-- Shift-Tab to return to source window
		vim.api.nvim_buf_set_keymap(hover.buffer, "n", "<S-Tab>", "", {
			callback = function()
				local prev_win = vim.fn.win_getid(vim.fn.winnr("#"))
				if prev_win and vim.api.nvim_win_is_valid(prev_win) then
					vim.api.nvim_set_current_win(prev_win)
					if hover.window and vim.api.nvim_win_is_valid(hover.window) then
						vim.wo[hover.window].cursorline = false
					end
				end
			end,
			desc = "Return to source window (Shift-Tab)"
		})

		-- Allow scrolling with j/k when focused
		vim.api.nvim_buf_set_keymap(hover.buffer, "n", "j", "", {
			callback = function()
				if hover.window and vim.api.nvim_win_is_valid(hover.window) then
					vim.api.nvim_win_call(hover.window, function()
						vim.cmd("normal! j")
					end)
				end
			end,
			desc = "Scroll down in hover"
		})

		vim.api.nvim_buf_set_keymap(hover.buffer, "n", "k", "", {
			callback = function()
				if hover.window and vim.api.nvim_win_is_valid(hover.window) then
					vim.api.nvim_win_call(hover.window, function()
						vim.cmd("normal! k")
					end)
				end
			end,
			desc = "Scroll up in hover"
		})

		-- Page down/up
		vim.api.nvim_buf_set_keymap(hover.buffer, "n", "<C-f>", "", {
			callback = function()
				if hover.window and vim.api.nvim_win_is_valid(hover.window) then
					vim.api.nvim_win_call(hover.window, function()
						vim.cmd("normal! <C-f>")
					end)
				end
			end,
			desc = "Page down in hover"
		})

		vim.api.nvim_buf_set_keymap(hover.buffer, "n", "<C-b>", "", {
			callback = function()
				if hover.window and vim.api.nvim_win_is_valid(hover.window) then
					vim.api.nvim_win_call(hover.window, function()
						vim.cmd("normal! <C-b>")
					end)
				end
			end,
			desc = "Page up in hover"
		})

		-- Close on cursor leave (optional, can be disabled)
		vim.api.nvim_create_autocmd("WinLeave", {
			buffer = hover.buffer,
			callback = function()
				-- Give a small delay before closing to allow intentional focus
				vim.defer_fn(function()
					if hover.window and vim.api.nvim_win_is_valid(hover.window) then
						local cur_win = vim.api.nvim_get_current_win()
						if cur_win ~= hover.window then
							pcall(vim.api.nvim_win_close, hover.window, true)
							if hover.quad then
								hover.update_quad(hover.quad, false)
								hover.quad = nil
							end
						end
					end
				end, 100)
			end
		})
	end
end

--- Tracks which quadrants are in use to avoid overlap
---@param quad "top_left" | "top_right" | "bottom_left" | "bottom_right" | "center"
---@param state boolean
hover.update_quad = function(quad, state)
	if not _G.__used_quads then
		_G.__used_quads = {
			top_left = false,
			top_right = false,
			bottom_left = false,
			bottom_right = false
		}
	end

	if quad ~= "center" then
		_G.__used_quads[quad] = state
	end
end

--- Calculates window position and border based on cursor position
---@param window integer
---@param w integer
---@param h integer
---@return string|string[], "editor"|"cursor", "NE"|"NW"|"SE"|"SW", integer, integer
hover.__win_args = function(window, w, h)
	local cursor = vim.api.nvim_win_get_cursor(window)
	local screenpos = vim.fn.screenpos(window, cursor[1], cursor[2])

	local screen_width = vim.o.columns - 2
	local screen_height = vim.o.lines - vim.o.cmdheight - 2

	local quad_pref = { "bottom_right", "bottom_left", "top_right", "top_left" }
	local quads = {
		center = {
			relative = "editor",
			anchor = "NW",
			row = math.ceil((vim.o.lines - h) / 2),
			col = math.ceil((vim.o.columns - w) / 2),
			border = "rounded"
		},

		top_left = {
			condition = function()
				if h >= screenpos.row then
					return false
				elseif screenpos.curscol <= w then
					return false
				end
				return true
			end,
			relative = "cursor",
			border = { "╭", "─", "╮", "│", "┤", "─", "╰", "│" },
			anchor = "SE",
			row = 0,
			col = 1
		},

		top_right = {
			condition = function()
				if h >= screenpos.row then
					return false
				elseif screenpos.curscol + w > screen_width then
					return false
				end
				return true
			end,
			relative = "cursor",
			border = { "╭", "─", "╮", "│", "╯", "─", "├", "│" },
			anchor = "SW",
			row = 0,
			col = 0
		},

		bottom_left = {
			condition = function()
				if screenpos.row + h > screen_height then
					return false
				elseif screenpos.curscol <= w then
					return false
				end
				return true
			end,
			relative = "cursor",
			border = { "╭", "─", "┤", "│", "╯", "─", "╰", "│" },
			anchor = "NE",
			row = 1,
			col = 1
		},

		bottom_right = {
			condition = function()
				if screenpos.row + h > screen_height then
					return false
				elseif screenpos.curscol + w > screen_width then
					return false
				end
				return true
			end,
			relative = "cursor",
			border = { "├", "─", "╮", "│", "╯", "─", "╰", "│" },
			anchor = "NW",
			row = 1,
			col = 0
		}
	}

	for _, pref in ipairs(quad_pref) do
		if _G.__used_quads and _G.__used_quads[pref] == true then
			goto continue
		end

		if not quads[pref] then
			goto continue
		end

		local quad = quads[pref]
		local ran_cond, cond = pcall(quad.condition)

		if ran_cond and cond then
			hover.quad = pref
			return quad.border, quad.relative, quad.anchor, quad.row, quad.col
		end

		::continue::
	end

	hover.quad = "center"
	local fallback = quads.center
	return fallback.border, fallback.relative, fallback.anchor, fallback.row, fallback.col
end

--- Custom hover function
---@param window? integer
hover.hover = function(window)
	window = window or vim.api.nvim_get_current_win()

	-- If hover window is already open, focus it
	if hover.window and vim.api.nvim_win_is_valid(hover.window) then
		vim.api.nvim_set_current_win(hover.window)
		vim.wo[hover.window].cursorline = true
		return
	end

	local got_position_params, position_params = pcall(vim.lsp.util.make_position_params, window, "utf-8")
	local buf = vim.api.nvim_win_get_buf(window)

	if not got_position_params then
		vim.api.nvim_echo({
			{ "  Lsp hover ", "DiagnosticVirtualTextWarn" },
			{ ": ", "@comment" },
			{ "Couldn't get position parameters!", "Comment" }
		}, false, {})
		return
	end

	vim.lsp.buf_request(buf, "textDocument/hover", position_params, function(err, result, ctx, config)
		if err then
			vim.api.nvim_echo({
				{ "  Lsp hover ", "DiagnosticVirtualTextError" },
				{ ": ", "@comment" },
				{ err.message, "Comment" }
			}, true, {})
			return
		elseif not result or not result.contents then
			vim.api.nvim_echo({
				{ "  Lsp hover ", "DiagnosticVirtualTextInfo" },
				{ ": ", "@comment" },
				{ "No information available!", "Comment" }
			}, false, {})
			return
		end

		hover.__prepare()

		local client_id = ctx.client_id
		local client = vim.lsp.get_client_by_id(client_id) or {}
		local client_name = client.name or ""

		local _config = get_style(client_name, result, ctx)
		local W = _config.width or math.floor(vim.o.columns * 0.25)
		local H = _config.height or math.floor(vim.o.lines * 0.4)

		_config.winopts = vim.tbl_extend("force", config or {}, _config.winopts or {})

		local contents = result.contents or {}
		---@type string[]
		local lines = {}

		-- Convert LSP hover contents (string, table, or list) into markdown lines
		if type(contents) == "string" then
			lines = vim.split(contents, "\n", { trimempty = true })
			vim.bo[hover.buffer].ft = "markdown"
		elseif vim.islist(contents) then
			local all_lines = {}
			for _, item in ipairs(contents) do
				if type(item) == "string" then
					local item_lines = vim.split(item, "\n", { trimempty = true })
					for _, l in ipairs(item_lines) do
						table.insert(all_lines, l)
					end
				elseif type(item) == "table" and item.value then
					local item_lines = vim.split(item.value, "\n", { trimempty = true })
					for _, l in ipairs(item_lines) do
						table.insert(all_lines, l)
					end
				end
			end
			lines = all_lines
			vim.bo[hover.buffer].ft = "markdown"
		elseif type(contents) == "table" then
			lines = vim.split(contents.value or "", "\n", { trimempty = true })
			vim.bo[hover.buffer].ft = contents.kind or "markdown"
		else
			lines = {}
			vim.bo[hover.buffer].ft = "markdown"
		end

		-- Set content with text width for wrapping
		vim.bo[hover.buffer].tw = W
		vim.api.nvim_buf_set_lines(hover.buffer, 0, -1, false, lines)

		-- Open hidden window first to calculate wrapped height
		if not hover.window or vim.api.nvim_win_is_valid(hover.window) == false then
			hover.window = vim.api.nvim_open_win(hover.buffer, false, {
				relative = "cursor",
				row = 1, col = 0,
				width = W, height = H,
				style = "minimal",
				hide = true,
			})
		end

		if hover.quad then
			hover.update_quad(hover.quad, false)
		end

		-- Set window options for better UX
		vim.wo[hover.window].wrap = true
		vim.wo[hover.window].linebreak = true
		vim.wo[hover.window].breakindent = true
		vim.wo[hover.window].conceallevel = 3
		vim.wo[hover.window].concealcursor = "ncv"
		vim.wo[hover.window].foldmethod = "manual"
		vim.wo[hover.window].cursorline = false

		-- Calculate actual wrapped height safely
		local calc_h = #lines
		if vim.api.nvim_win_text_height then
			local ok_h, res_h = pcall(vim.api.nvim_win_text_height, hover.window, { start_row = 0, end_row = -1 })
			if ok_h and res_h and res_h.all then
				calc_h = res_h.all
			end
		end

		H = math.max(
			1,
			math.min(
				calc_h,
				H,
				math.floor(vim.o.lines * 0.5)
			)
		)

		-- Reset content to fix syntax highlighting after height calc
		vim.api.nvim_buf_set_lines(hover.buffer, 0, -1, false, lines)

		-- Get quadrant-aware position
		local border, relative, anchor, row, col = hover.__win_args(window, W, H)

		-- Make window visible with final config
		vim.api.nvim_win_set_config(hover.window, vim.tbl_extend("force", {
			relative = relative or "cursor",
			row = row or 1, col = col or 0,
			width = W, height = H,
			anchor = anchor,
			border = border or "rounded",
			style = "minimal",
			hide = false,
		}, _config.winopts))

		vim.wo[hover.window].signcolumn = "no"

		if type(_config.winhl) == "string" then
			vim.wo[hover.window].winhl = _config.winhl
		end

		vim.api.nvim_win_set_cursor(hover.window, { 1, 0 })
		hover.update_quad(hover.quad, true)

		-- Markdown rendering via markview.nvim
		if package.loaded["markview"] and package.loaded["markview"].render then
			package.loaded["markview"].render(hover.buffer, {
				enable = true,
				hybrid_mode = false
			})
		end
	end)
end

--- Setup function
---@param config? table<string, hover.style>
hover.setup = function(config)
	if type(config) == "table" then
		hover.config = vim.tbl_extend("force", hover.config, config)
	end

	-- Set up keymap on LspAttach
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ev)
			vim.keymap.set("n", "K", function()
				hover.hover()
			end, { buffer = ev.buf, desc = "Show LSP hover" })

			-- Map gh to show LSP hover
			vim.keymap.set("n", "gh", function()
				hover.hover()
			end, { buffer = ev.buf, desc = "Show LSP hover (gh)" })

			-- Also support <C-k> in normal mode for hover (alternative)
			vim.keymap.set("n", "<C-k>", function()
				hover.hover()
			end, { buffer = ev.buf, desc = "Show LSP hover (alternative)" })
		end
	})

	-- Auto-close on cursor move in source buffer
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		callback = function()
			local win = vim.api.nvim_get_current_win()
			if hover.window and win ~= hover.window then
				-- Check if we're in the hover window itself
				if vim.api.nvim_win_is_valid(hover.window) then
					pcall(vim.api.nvim_win_close, hover.window, true)
					if hover.quad then
						hover.update_quad(hover.quad, false)
						hover.quad = nil
					end
				end
			end
		end
	})

	-- Close hover on buffer leave
	vim.api.nvim_create_autocmd("BufLeave", {
		callback = function()
			if hover.window and vim.api.nvim_win_is_valid(hover.window) then
				pcall(vim.api.nvim_win_close, hover.window, true)
				if hover.quad then
					hover.update_quad(hover.quad, false)
					hover.quad = nil
				end
			end
		end
	})

	-- Close hover on insert enter
	vim.api.nvim_create_autocmd("InsertEnter", {
		callback = function()
			if hover.window and vim.api.nvim_win_is_valid(hover.window) then
				pcall(vim.api.nvim_win_close, hover.window, true)
				if hover.quad then
					hover.update_quad(hover.quad, false)
					hover.quad = nil
				end
			end
		end
	})
end

return hover