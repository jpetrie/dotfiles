return {
  {
    "jpetrie/schematic",
    config = function()
      local schematic = require("schematic")
      schematic.setup({
        use_task_runner = "overseer",
      })

      vim.keymap.set("n", "<LEADER>k", function()
        local project = schematic.project()
        if project ~= nil then
          project:clean()
        end
      end)

      vim.keymap.set("n", "<LEADER>b", function()
        local project = schematic.project()
        if project ~= nil then
          project:build()
        end
      end)

      vim.keymap.set("n", "<LEADER>r", function()
        local project = schematic.project()
        if project ~= nil then
          project:run()
        end
      end)
    end,
  },
  {
    "stevearc/overseer.nvim",
    config = function()
      local overseer = require("overseer")
      overseer.setup({})

      vim.keymap.set("n", "<LEADER>tl", function() overseer.toggle({direction = "bottom"}) end)
    end
  },
}

