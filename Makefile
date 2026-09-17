UNAME_S := $(shell uname -s)

.PHONY: format check test

format:
	stylua . --check || stylua .

check:
	stylua . --check

test:
	nvim --headless '+lua for _, m in ipairs({"core.init","core.options","core.commands","core.keymaps","core.autocmds"}) do local ok, err = pcall(require, m); if not ok then vim.notify(err, vim.log.levels.ERROR); os.exit(1) end end; os.exit(0)'