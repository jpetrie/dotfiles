-- Completion
vim.opt.wildmode = "longest:full"

-- Files and Paths
vim.opt.path = {".", "**"}
vim.opt.wildignore = {"*.air", "*.d", "*.dia", "*.o"}

-- Formatting
vim.opt.formatoptions = "cqj"
vim.opt.textwidth = 120

-- Indentation
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true

-- Line Handling
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.opt.showbreak="↳"
vim.opt.wrap = false

-- Search and Replace
vim.opt.hlsearch = false

-- Sessions
vim.opt.sessionoptions = "buffers,curdir,skiprtp,tabpages"

-- UI
vim.opt.laststatus = 2
vim.opt.list = true
vim.opt.listchars = "eol:¬,tab:>-,space:·,extends:▶,precedes:◀,nbsp:•"
vim.opt.number = true
vim.opt.shortmess = "filmrxWIF"
vim.opt.showcmd = false
vim.opt.signcolumn = "yes:1"

