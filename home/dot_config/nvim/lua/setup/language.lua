vim.lsp.config("*", {
  root_markers = {".git"},
})

vim.lsp.config("cmake-language-server", {
  cmd = {"cmake-language-server"},
  root_markers = {"CMakePresets.json", ".git"},
  filetypes = {"cmake"},
})

vim.lsp.config("lua-language-server", {
  cmd = {"lua-language-server"},
  root_markers = {".luarc.json", ".luarc.jsonc"},
  filetypes = {"lua"},
  settings =  {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/luv/library",
        },
      },
    },
  },
})

vim.lsp.enable({"cmake-language-server", "lua-language-server"})

return {
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
  {
    "bezhermoso/tree-sitter-ghostty",
    build = "make nvim_install",
  },
}

