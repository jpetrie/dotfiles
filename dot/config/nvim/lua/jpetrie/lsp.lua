local function on_attach(_, buffer)
  -- Enable omnifunc integration.
  vim.api.nvim_buf_set_option(buffer, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Override built-in functions with LSP-based implementations.
  local map_options = {noremap = true, silent = true, buffer = buffer}
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_options)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, map_options)
end

local lsp = require("lspconfig")

lsp.clangd.setup({
  flags = {},
  on_attach = on_attach,
  on_new_config = function(new_config, new_root)
    local project = require("schematic").load(new_root)
    if project ~= nil and project.active_config > 0 then
      local config = project.configs[project.active_config]

      -- If the LSP server is restarted, `cmd` will be the full previous command, so simply appending the
      -- compile commands directory argument will continually grow `cmd`. Only the first instance of the argument is
      -- respected by clangd anyway.
      new_config.cmd = {new_config.cmd[1], "--compile-commands-dir=" .. config.directory}
    end
  end
})

lsp.lua_ls.setup({
  on_attach = on_attach
})
