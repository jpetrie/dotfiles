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

-- Spelling
vim.opt.spell = true
vim.opt.spellfile = vim.fs.abspath("~/.config/nvim/spell/custom.utf-8.add")

-- On startup, if any .add files are newer than their .spl files, update them.
vim.api.nvim_create_autocmd("VimEnter", {pattern = "*", callback = function()
  for _, add_file in ipairs(vim.opt.spellfile:get()) do
    local spl_file = add_file .. ".spl"
    if vim.fn.filereadable(add_file) == 1 then
      local add_time = vim.fn.getftime(add_file)
      local spl_time = vim.fn.getftime(spl_file)
      if add_time > spl_time or spl_time == -1 then
        vim.cmd("silent! mkspell! " .. spl_file .. " " .. add_file)
      end
    end
  end
end
})

return {
  {
    "nvim-lua/plenary.nvim",
  },
  {
    "nvim-tree/nvim-web-devicons",
  },
}
