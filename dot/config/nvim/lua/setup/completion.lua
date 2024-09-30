vim.opt.wildmode = "longest:full"

return {
  {
    "hrsh7th/cmp-buffer",
  },
  {
    "hrsh7th/cmp-cmdline",
  },
  {
    "hrsh7th/cmp-path",
  },
  {
    "hrsh7th/cmp-nvim-lsp",
  },
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(arguments)
            vim.snippet.expand(arguments.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = {
          ["<DOWN>"] = cmp.mapping.select_next_item(),
          ["<UP>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<TAB>"] = cmp.mapping.confirm({select = true}),
        },
        sources = cmp.config.sources({
          {name = "nvim_lsp"},
          {name = "buffer"},
        })
      })

      -- Enable command-line completion for search.
      cmp.setup.cmdline({"/", "?" }, {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            {name = "buffer"},
          }
        }
      )

      -- Enable command-line completion for command mode.
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({{name = "path"}}, {{ name = 'cmdline' }}),
        matching = {disallow_symbol_nonprefix_matching = false}
      })
    end,
  },
}

