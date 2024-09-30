local function on_attach(_, buffer)
  -- Enable omnifunc integration.
  vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", {buf = buffer})

  -- Override built-in functions with LSP-based implementations.
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, {buffer = buffer})
  vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer = buffer})
end

return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lsp = require("lspconfig")
      lsp.clangd.setup({
        capabilities = capabilities,
        flags = {},
        on_attach = on_attach,
        on_new_config = function(new_config, new_root)
          local project = require("schematic").scan(new_root)
          if project ~= nil then
            -- If the LSP server is restarted, `cmd` will be the full previous command, so simply appending the
            -- compile commands directory argument will continually grow `cmd`. Only the first instance of the argument
            -- is respected by clangd anyway.
            new_config.cmd = {new_config.cmd[1], "--compile-commands-dir=" .. project.config.directory}
          end
        end
      })

      lsp.lua_ls.setup({
        capabilities = capabilities,
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if vim.uv.fs_stat(path.."/.luarc.json") or vim.uv.fs_stat(path.."/.luarc.jsonc") then
              return
            end
          end

          client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
              version = "LuaJIT",
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                "${3rd}/luv/library",
              }
            }
          })
        end,
        settings = {
          Lua = {}
        }
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {"c", "cmake", "cpp", "gitignore", "json", "query", "rust", "lua", "vim", "vimdoc"},
        sync_install = false,
        auto_install = false,
        indent = {
          enable = false,
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            keymaps = {
              ["i,"] = "@parameter.inner",
              ["a,"] = "@parameter.outer",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["],"] = "@parameter.outer",
            },
            goto_previous_start = {
              ["[,"] = "@parameter.outer",
            },
          },
        },
      })
    end,
  },
}

