local M = {}

function M.setup()
  require("core.options.ui").setup()

  local opt = vim.opt

  vim.g.mapleader = " "
  vim.g.maplocalleader = "\\"

  opt.iskeyword:remove("-")
  opt.fixendofline = false
  opt.endofline = true
  opt.binary = false
  opt.bomb = false
  opt.fileformat = "unix"

  opt.cursorline = true
  opt.showmode = false
  opt.number = true
  opt.relativenumber = true
  opt.showmatch = true
  opt.visualbell = true
  opt.belloff = "all"

  opt.hlsearch = true
  opt.incsearch = true
  opt.ignorecase = true
  opt.smartcase = true

  opt.tabstop = 4
  opt.softtabstop = 4
  opt.shiftwidth = 4
  opt.shiftround = true
  opt.expandtab = true
  opt.smartindent = true

  opt.foldmethod = "expr"
  opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  opt.foldlevel = 99
  opt.foldenable = true
  opt.foldlevelstart = 99

  opt.timeoutlen = 300
  opt.ttimeoutlen = 0

  opt.matchpairs:append("<:>")
  opt.termguicolors = true
  opt.background = "dark"
  opt.signcolumn = "yes:1"
  opt.updatetime = 200
  opt.scrolloff = 8
  opt.sidescrolloff = 5
  opt.wrap = true
  opt.mouse = "a"
  opt.backspace = "indent,eol,start"
  opt.clipboard:append("unnamedplus")
  opt.splitright = true
  opt.splitbelow = true
  opt.swapfile = false

  opt.autoindent = true
  opt.autoread = true
  opt.autowrite = true
  opt.backup = false
  opt.backupskip = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim"
  opt.breakat = [[\ \t;:,!?]]
  opt.breakindentopt = "shift:2,min:20"
  opt.cmdheight = 1
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
  opt.list = false
  opt.listchars = "tab:→ ,nbsp:␣,trail:·,extends:→,precedes:←,space:·"
  opt.magic = true
  opt.mousescroll = "ver:3,hor:6"
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
  opt.smarttab = true
  opt.smoothscroll = true
  opt.splitkeep = "screen"
  opt.startofline = false
  opt.switchbuf = "usetab,uselast"
  opt.synmaxcol = 2500
  opt.timeout = true
  opt.ttimeout = true
  opt.undofile = true
  opt.viewoptions = "cursor,curdir,slash,unix"
  opt.virtualedit = "block"
  opt.whichwrap = "h,l,<,>,[,],~"
  opt.wildignore = ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**"
  opt.wildignorecase = true
  opt.winblend = 0
  opt.winminwidth = 10
  opt.winwidth = 30
  opt.wrapscan = true
  opt.writebackup = false
end

return M
