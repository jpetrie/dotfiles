return {
  {
    "stevearc/resession.nvim",
    config = function()
      local resession = require("resession")
      resession.setup({})

      -- Setup automatic save/load of directory-based sessions.
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc(-1) == 0 then
            resession.load(vim.fn.getcwd(), {dir = "dirsession", silence_errors = true})
          end
        end,
        nested = true,
      })

      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          resession.save(vim.fn.getcwd(), {dir = "dirsession", notify = false})
        end,
      })

      vim.keymap.set("n", "<LEADER>ss", resession.save)
      vim.keymap.set("n", "<LEADER>sl", resession.load)
      vim.keymap.set("n", "<LEADER>sd", resession.delete)
    end,
  }
}

