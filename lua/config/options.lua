local opt = vim.opt

-- Configure word boundaries to treat hyphens as separators
opt.iskeyword:remove("-")

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- File handling settings
opt.fixendofline = false -- Don't automatically add newline at end of file
opt.endofline = true     -- Don't enforce final newline
opt.binary = false       -- Keep as text file but preserve exact content
opt.bomb = false         -- Don't add BOM (Byte Order Mark)
opt.fileformat = "unix"  -- Use Unix line endings consistently

-- UI settings
opt.cursorline = true
opt.showmode = false      -- Show current mode
opt.number = true         -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.showmatch = true      -- Show matching brackets
opt.visualbell = true     -- Use visual bell instead of beeping
opt.belloff = "all"       -- Disable all bells

-- Search settings
opt.hlsearch = true   -- Highlight search results
opt.incsearch = true  -- Incremental search
opt.ignorecase = true -- Case insensitive search
opt.smartcase = true  -- Smart case sensitivity

-- Indentation settings
opt.tabstop = 4        -- Tab width
opt.softtabstop = 4    -- Soft tab width
opt.shiftwidth = 4     -- Indent width
opt.shiftround = true  -- Round indent to multiple of shiftwidth
opt.expandtab = true   -- Use spaces instead of tabs
opt.smartindent = true -- Smart autoindenting

-- Folding settings
opt.foldmethod = "expr"                     -- Use expression for folding
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- Use built-in treesitter folding (Neovim 0.10+)
opt.foldlevel = 99                          -- Start with all folds open
opt.foldenable = true                       -- Enable folding
opt.foldlevelstart = 99                     -- Start with all folds open

-- Timing settings
opt.timeoutlen = 300 -- Faster timeout for key sequences
opt.ttimeoutlen = 0  -- Eliminate escape delay completely

-- Additional settings
opt.matchpairs:append("<:>") -- Add <> to matching pairs
opt.termguicolors = true     -- True color support
opt.background = "dark"
opt.signcolumn = "yes:1"     -- Always show sign column with fixed width of 2
opt.updatetime = 200
opt.scrolloff = 8            -- Keep lines visible around cursor
opt.sidescrolloff = 8        -- Keep columns visible around cursor
opt.wrap = true              -- Wrap long lines
opt.mouse = "a"              -- Enable mouse in all modes

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- cursor settings - comprehensive blinking configuration
-- This sets cursor shapes and enables blinking for all modes
-- opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"

-- Also set via vim.cmd to ensure it takes effect immediately
-- vim.cmd('set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor')

-- Additional
opt.autoindent = true
opt.autoread = true
opt.autowrite = true
opt.backup = false
opt.backupskip = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim"
opt.breakat = [[\ \	;:,!?]]
opt.breakindentopt = "shift:2,min:20"
opt.cmdheight = 1 -- 0, 1, 2
opt.cmdwinheight = 5
opt.complete = ".,w,b,k,kspell"
opt.completeopt = "fuzzy,menuone,noselect,popup"
opt.concealcursor = "niv"
opt.conceallevel = 0
opt.cursorcolumn = false
opt.diffopt = "filler,iwhite,internal,linematch:60,algorithm:patience"
opt.display = "lastline"
opt.encoding = "utf-8"
opt.equalalways = false
opt.errorbells = true
opt.fileformats = "unix,mac,dos"
opt.formatoptions = "1jcroql"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --hidden --vimgrep --smart-case --"
opt.helpheight = 12
opt.hidden = true
opt.history = 2000
opt.inccommand = "nosplit"
opt.infercase = true
opt.jumpoptions = "stack"
opt.laststatus = 3
opt.linebreak = true
-- Default: do NOT show invisible whitespace; toggle with <leader>tw (see keymaps)
opt.list = false
opt.listchars = "tab:→ ,nbsp:␣,trail:·,extends:→,precedes:←,space:·"
opt.magic = true
opt.mousescroll = "ver:3,hor:6"
-- Do NOT adjust the following option (pumblend) if you're using transparent background
opt.pumblend = 0
opt.pumheight = 15
opt.redrawtime = 1500
opt.ruler = true
opt.sessionoptions = "blank,buffers,curdir,help,tabpages,winsize,winpos,terminal,localoptions"
opt.shada = "!,'500,<50,@100,s10,h"
opt.shortmess = "aoOTIcF"
opt.showbreak = "↳  "
opt.showcmd = false
opt.showtabline = 2
opt.sidescrolloff = 5
opt.smarttab = true
opt.smoothscroll = true
opt.splitkeep = "screen"
opt.startofline = false
opt.switchbuf = "usetab,uselast"
opt.synmaxcol = 2500
opt.timeout = true
opt.ttimeout = true
opt.undofile = true
-- Please do NOT set `updatetime` to above 500, otherwise most plugins may not function correctly
opt.viewoptions = "cursor,curdir,slash,unix"
opt.virtualedit = "block"
opt.whichwrap = "h,l,<,>,[,],~"
opt.wildignore =
".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**"
opt.wildignorecase = true
-- Do NOT adjust the following option (winblend) if you're using transparent background
opt.winblend = 0
opt.winminwidth = 10
opt.winwidth = 30
opt.wrapscan = true
opt.writebackup = false