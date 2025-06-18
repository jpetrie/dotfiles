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

-- clangd launch is done from here since it is only applicable when there is a project loaded.
vim.api.nvim_create_autocmd({"FileType"}, {pattern = "cpp", callback = function(_)
  local project = require("schematic").project()
  if project ~= nil then
    vim.lsp.start({
      name = "clangd",
      cmd = {"clangd", "--compile-commands-dir=" .. project.config.directory},
      root_dir = project.directory,
    })
  end
end})

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

            -- Stop any clangd servers for this project in order to start them back up with a different
            -- compilation database.
            for _, client in ipairs(vim.lsp.get_clients()) do
              if client.name == "clangd" and client.root_dir == project.directory then
                client:stop()
              end
            end

            -- Restart clangd for the new configuration. The first invocation should not attempt reuse otherwise
            -- it can match with clients that were shut down above.
            local reuse = false
            for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
              if vim.bo[buffer].filetype == "cpp" then
                local client_id = vim.lsp.start({
                  name = "clangd",
                  cmd = {"clangd", "--compile-commands-dir=" .. project.config.directory},
                  root_dir = project.directory,
                }, {
                  reuse_client = function(_, _)
                    return reuse
                  end,
                  bufnr = buffer,
                })

                if client_id ~= nil then
                  reuse = true
                end
              end
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
          vim.cmd("wall")
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

