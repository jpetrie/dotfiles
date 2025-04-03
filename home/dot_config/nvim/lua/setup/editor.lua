-- Files and Paths
vim.opt.wildignore = {"*.air", "*.d", "*.dia", "*.o"}

-- Formatting
vim.opt.formatoptions = "cro/qj"
vim.opt.textwidth = 120

-- Indentation
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true

-- Ensure C++ access specifiers use the indent level of their enclosing brace.
vim.opt.cinoptions = "g0"

-- Line Handling
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.opt.showbreak="↳"
vim.opt.wrap = false

return {
  {
    "nvim-lua/plenary.nvim",
  },
  {
    "nvim-tree/nvim-web-devicons",
  },
}
