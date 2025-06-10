local opt = vim.opt

-- System clipboard integration
opt.clipboard = "unnamedplus"

-- File handling settings
opt.fixendofline = false          -- Don't automatically add newline at end of file
opt.endofline = false             -- Don't enforce final newline
opt.binary = false                -- Keep as text file but preserve exact content
opt.bomb = false                  -- Don't add BOM (Byte Order Mark)
opt.fileformat = "unix"           -- Use Unix line endings consistently

-- UI settings
opt.cursorline = true
opt.showmode = true               -- Show current mode
opt.number = true                 -- Show line numbers
opt.relativenumber = true         -- Show relative line numbers
opt.showmatch = true              -- Show matching brackets
opt.visualbell = true             -- Use visual bell instead of beeping
opt.belloff = "all"               -- Disable all bells
t_vb = ""                         -- Disable visual bell effect

-- Search settings
opt.hlsearch = true               -- Highlight search results
opt.incsearch = true              -- Incremental search
opt.ignorecase = true             -- Case insensitive search
opt.smartcase = true              -- Smart case sensitivity

-- Indentation settings
opt.tabstop = 4                   -- Tab width
opt.softtabstop = 4               -- Soft tab width
opt.expandtab = true
opt.shiftwidth = 4                -- Indent width
opt.shiftround = true             -- Round indent to multiple of shiftwidth
opt.expandtab = true              -- Use spaces instead of tabs
opt.smartindent = true            -- Smart autoindenting

-- Folding settings
opt.foldmethod = "expr"           -- Use expression for folding
opt.foldexpr = "nvim_treesitter#foldexpr()" -- Use treesitter for folding
opt.foldlevel = 99                -- Start with all folds open
opt.foldenable = true             -- Enable folding
opt.foldlevelstart = 99           -- Start with all folds open

-- Timing settings
opt.timeoutlen = 300              -- Reasonable timeout for key sequences (300ms for telescope stability)
opt.ttimeoutlen = 0               -- Eliminate escape delay completely

-- Additional settings
opt.matchpairs:append("<:>")      -- Add <> to matching pairs
opt.termguicolors = true          -- True color support
opt.background = "dark"
opt.signcolumn = "yes"
opt.updatetime = 100              -- Faster updates
opt.scrolloff = 8                 -- Keep lines visible around cursor
opt.sidescrolloff = 8             -- Keep columns visible around cursor
opt.wrap = false                  -- Don't wrap lines
opt.mouse = "a"                   -- Enable mouse in all modes
opt.signcolumn = "yes"            -- Always show sign column

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- Set cursor to block shape in all modes
-- opt.guicursor = "" -- Empty string makes cursor block in all modes
-- opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
