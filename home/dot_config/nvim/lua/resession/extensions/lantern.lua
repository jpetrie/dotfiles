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
  if has_lantern then
    if state.configuration ~= nil then
      lantern.set_configuration(state.configuration)
    end

    if state.target ~= nil then
      lantern.set_target(state.target)
    end
  end
end

return M
