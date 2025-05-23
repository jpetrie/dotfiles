vim.opt.hlsearch = false

if vim.fn.executable("rg") then
  -- Neovim's default if rg exists is to pass -uu, which includes ignored and hidden files.
  vim.opt.grepprg = "rg --vimgrep"
end

vim.api.nvim_create_user_command("Todo", "silent grep! TODO | copen", {})

return {
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_strategy = "vertical",
          layout_config = {height = 0.95}
        }
      })
      telescope.load_extension("fzf")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<LEADER>of", builtin.find_files)
      vim.keymap.set("n", "<LEADER>ob", builtin.buffers)
      vim.keymap.set("n", "<LEADER>ov", function() return builtin.find_files({cwd = "~/.config/nvim", follow = true}) end)
      vim.keymap.set("n", "<LEADER>fg", builtin.live_grep)
      vim.keymap.set("n", "<LEADER>fh", builtin.help_tags)
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"
  },
}

