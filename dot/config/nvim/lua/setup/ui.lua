vim.opt.number = true
vim.opt.shortmess = "filmrxWIF"
vim.opt.showcmd = false
vim.opt.signcolumn = "yes:1"

vim.opt.list = true
vim.opt.listchars = "eol:¬,tab:>-,space:·,multispace:|·,extends:▶,precedes:◀,nbsp:•"

vim.opt.statusline = "%!v:lua.BuildStatusLine()"

-- Reconfigure the right-click popup menu.
vim.cmd("aunmenu PopUp.Inspect")
vim.cmd("aunmenu PopUp.-1-")
vim.cmd("aunmenu PopUp.How-to\\ disable\\ mouse")
vim.cmd("anoremenu PopUp.-1- <Nop>")
vim.cmd("anoremenu PopUp.Inspect <Cmd>Inspect<CR>")

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

    local overseer = package.loaded["overseer"]
    if overseer ~= nil then
      local tasks = overseer.list_tasks({status = overseer.STATUS.RUNNING})
      if #tasks > 0 then
        table.insert(parts, "⠶" .. #tasks .. " ")
      end
    end

    local schematic = package.loaded["schematic"]
    if schematic ~= nil then
      local project = schematic.project()
      if project ~= nil then
        table.insert(parts, "[" .. project.name .. "] " .. project.target.name .. "/" .. project.config.name)
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
      -- Prevent flicker on launch (see https://github.com/neovim/neovim/issues/19362).
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
    "stevearc/dressing.nvim",
    opts = {},
  },
}

