local M = {}

M.on_save = function(_)
  local state = {}

  local has_lantern, lantern = pcall(require, "lantern")
  if has_lantern and lantern.project() ~= nil then
    if lantern.configuration() ~= nil then
      state.configuration = lantern.configuration().name
    end

    if lantern.target() ~= nil then
      state.target = lantern.target().name
    end
  end

  return state
end

M.on_pre_load = function(_)
end

M.on_post_load = function(state)
  local has_lantern, lantern = pcall(require, "lantern")
  if has_lantern and lantern.project() ~= nil then
    local project = lantern.project()
    if state.configuration ~= nil then
      if project.configurations[state.configuration] ~= nil then
        lantern.set_configuration(state.configuration)
      end
    end

    if lantern.configuration() ~= nil and state.target ~= nil then
      local configuration = lantern.configuration()
      if configuration.targets[state.target] ~= nil then
        lantern.set_target(state.target)
      end
    end
  end
end

return M
