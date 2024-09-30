-- Jump to next/prior long line.
vim.keymap.set("n", "]ll", "/\\%>120v.\\+<CR>")
vim.keymap.set("n", "[ll", "?\\%>120v.\\+<CR>")

-- Jump to next/prior diagnostic.
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)

return {
  {
    "jpetrie/flip",
    config = function()
      require("flip").setup({
        include_path = false,
      })

      vim.keymap.set("n", "<LEADER>a", ":FlipNext<CR>")
      vim.keymap.set("n", "<LEADER>A", ":FlipPrevious<CR>")
    end,
  },
}

