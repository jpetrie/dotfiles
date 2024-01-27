function CustomStatusLine()
  local parts = {}

  table.insert(parts, "%t")

  if vim.lsp.buf.server_ready() then
    local issue_types = {
      {level = vim.diagnostic.severity.ERROR, symbol = ""},
      {level = vim.diagnostic.severity.WARN, symbol = ""},
      {level = vim.diagnostic.severity.INFO, symbol = ""},
      {level = vim.diagnostic.severity.HINT, symbol = ""},
    }

    for _, issue in ipairs(issue_types) do
      local count = vim.tbl_count(vim.diagnostic.get(0, {severity = issue.level}))
      if count > 0 then
        table.insert(parts, " " .. issue.symbol .. " " .. count)
      end
    end
  end

  if vim.g.statusline_winid == vim.fn.win_getid(vim.fn.winnr()) then
    table.insert(parts, "%=")
    table.insert(parts, "%l %c")
  end

  return table.concat(parts, "")
end

vim.opt.statusline = "%!v:lua.CustomStatusLine()"

-- Override the statusline for certain filetypes.
vim.api.nvim_create_autocmd({"FileType"}, {pattern = "help", callback = function() vim.opt_local.statusline = "%f" end})
vim.api.nvim_create_autocmd({"FileType"}, {pattern = "qf", callback = function() vim.opt_local.statusline = "[Quickfix]" end})
