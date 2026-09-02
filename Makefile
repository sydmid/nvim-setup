UNAME_S := $(shell uname -s)

.PHONY: format check test

format:
	stylua . --check || stylua .

check:
	stylua . --check

test:
	nvim --headless '+lua local ok, err = pcall(require, "core.init"); if not ok then vim.notify(err, vim.log.levels.ERROR); vim.cmd("cquit") end; if ok then vim.cmd("q") end' +q