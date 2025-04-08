vim.opt.number = true
vim.opt.shortmess = "filmrxWIF"
vim.opt.showcmd = false
vim.opt.signcolumn = "yes:1"

vim.opt.list = true
vim.opt.listchars = "eol:¬,tab:>-,space:·,multispace:|·,extends:▶,precedes:◀,nbsp:•"

vim.opt.colorcolumn = "+1"

vim.opt.statusline = "%!v:lua.BuildStatusLine()"

-- Run a single background timer to periodically update the task spinner and redraw the statusline.
local task_status = ""
local tick_index = 0
local tick_timer = vim.uv.new_timer()
if tick_timer ~= nil then
  local interval = 250
  tick_timer:start(interval, interval, vim.schedule_wrap(function()
    local overseer = package.loaded["overseer"]
    if overseer ~= nil then
      local glyphs = {"·  ", "·· ", "···", " ··", "  ·", "   "}
      local tasks = overseer.list_tasks({status = overseer.STATUS.RUNNING})
      if #tasks == 0 then
        tick_index = -1
        task_status = ""
      else
        tick_index = (tick_index + 1) % #glyphs
        task_status = "[" .. #tasks .. glyphs[1 + tick_index] .. "] "
      end

      vim.cmd("redrawstatus")
    end
  end))
end

function BuildStatusLine()
  local window = vim.g.statusline_winid
  local buffer = vim.api.nvim_win_get_buf(window)
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buffer), ":~")
  local parts = {}

  table.insert(parts, path)
  if #path > 0 then
    table.insert(parts, " ")
  end

  if window == vim.api.nvim_get_current_win() then
    table.insert(parts, "%l:%v%=")

    table.insert(parts, task_status)

    local schematic = package.loaded["schematic"]
    if schematic ~= nil then
      local project = schematic.project()
      if project ~= nil then
        table.insert(parts, project.name .. "/" .. project.target.name .. "/" .. project.config.name)
      end
    end
  end

  return table.concat(parts, "")
end

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "󱥸",
    },
  },
  virtual_text = {
    current_line = true,
  },
})

return {
  {
    "jpetrie/lightswitch",
    opts = {},
  },
  {
    "jpetrie/turnip",
    lazy = false,
    priority = 1000,
    config = function()
      -- Prevent flicker on launch (see https://github.com/neovim/neovim/issues/19362). Note that while nvim does now
      -- support DEC mode 2031 (see https://github.com/neovim/neovim/pull/31350), which in theory should render this
      -- (and the entire Lightswitch plugin) obsolete, the flicker still occurs when relying on nvim's built-in behavior
      -- and thus both are still neccessary.
      vim.fn.system("defaults read -g AppleInterfaceStyle")
      if (vim.v.shell_error == 0) then
        vim.opt.background = "dark"
      else
        vim.opt.background = "light"
      end

      -- Activate.
      vim.cmd("colorscheme turnip")
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    opts = {
      close_if_last_window = true,
    },
    keys = {
      {"<leader>tt", "<cmd>Neotree toggle<cr>", desc = "Toggle Neotree"},
      {"<leader>tr", "<cmd>Neotree filesystem reveal<cr>", desc = "Reveal current file in Neotree"},
    },
  },
}

