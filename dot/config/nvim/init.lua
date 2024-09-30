-- Ensure Lazy is installed.
local lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazy) then
  local repository = "https://github.com/folke/lazy.nvim.git"
  local output = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", repository, lazy})
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({{"Failed to clone lazy.nvim:\n" .. output, "ErrorMsg"}}, true, {})
  end
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

if vim.uv.fs_stat(lazy) then
  vim.opt.runtimepath:prepend(lazy)
  require("lazy").setup({
    dev = {
      path = "~/Developer",
      fallback = true,
    },
    spec = {
      {import = "setup"},
    },
    change_detection = {
      notify = false,
    },
    install = {
      colorscheme = {"default"},
    },
  })
end

