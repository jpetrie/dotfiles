local function register_task_template(task, name)
  local overseer = require("overseer")
  local schematic = require("schematic")
  overseer.register_template({
    name = task,
    builder = function()
      local project = schematic.project()
      if project ~= nil then
        return {
          name = name .. " (" .. project.target.name .. "/" .. project.config.name .. ")",
          cmd = project.target.tasks[task],
          components = {
            "default",
            {"on_output_quickfix", open_on_match = true, close = true, items_only = true},
          },
        }
      end
      return nil
    end
  })
end

return {
  {
    "jpetrie/schematic",
    config = function()
      local overseer = require("overseer")
      local schematic = require("schematic")
      schematic.setup({
        hooks = {
          clean = function(_)
            overseer.run_template({name = "clean"})
          end,
          build = function(_)
            overseer.run_template({name = "build"})
          end,
          run = function(_)
            overseer.run_template({name = "run", autostart = false}, function(task)
              if task then
                task:add_component({"dependencies", task_names = {"build"}, sequential = true})
                task:start()
              end
            end)
          end,
          config_set = function(project)
            if vim.fn.isdirectory(project.config.directory) == 0 then
              vim.notify("Schematic configuration directory does not exist.", vim.log.levels.WARN)
            end
          end,
        }
      })

      -- Create Overseer task templates for clean, build and run actions.
      register_task_template("clean", "Clean")
      register_task_template("build", "Build")
      register_task_template("run", "Run")

      -- Setup key mappings.
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

