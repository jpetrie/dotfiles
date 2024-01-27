vim.api.nvim_create_user_command("Clean", function()
  local schematic = require("schematic")
  local project = schematic.project()
  if project ~= nil then
    require("overseer").run_template({name = project.metadata.clean_tag})
  end
end, {})

vim.api.nvim_create_user_command("Build", function()
  local schematic = require("schematic")
  local project = schematic.project()
  if project ~= nil then
    require("overseer").run_template({name = project.metadata.build_tag})
  end
end, {})

vim.api.nvim_create_user_command("Run", function()
  local schematic = require("schematic")
  local project = schematic.project()
  if project ~= nil then
    local dap = require("dap")
    local configuration = dap.configurations[project.metadata.debug_tag]
    dap.run(configuration)
  end
end, {})
