return {
  {
    "stevearc/resession.nvim",
    config = function()
      local resession = require("resession")
      resession.setup({
        buf_filter = function(buffer)
          -- Do not save the filetypes in this list to the session.
          local skip = {"gitcommit", "help"}
          if vim.list_contains(skip, vim.bo[buffer].filetype) then
            return false
          end

          -- For everything not explicitly skipped, fall back to the default behavior.
          return resession.default_buf_filter(buffer)
        end,
      })

      -- If the last window contained only a filtered-out buffer, restoring the session will bring up a "[No Name]"
      -- buffer. In that case, try to switch to a previously-restored buffer. This could be removed in the future if
      -- https://github.com/stevearc/resession.nvim/pull/74 or a similar solution is implemented.
      resession.add_hook("post_load", function()
        if #vim.api.nvim_buf_get_name(0) == 0 and #vim.api.nvim_list_bufs() > 1 then
          vim.cmd("bp")
        end
      end)

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

