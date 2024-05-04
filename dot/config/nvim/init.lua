local lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazy) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazy
  })
end
vim.opt.rtp:prepend(lazy)

local options = {
  dev = {
    path = "~/Developer",
    fallback = true,
  },
}

local plugins = {
  {
    "folke/neodev.nvim",
    opts = {},
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/nvim-cmp",
      "hrsh7th/vim-vsnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(arguments) vim.fn["vsnip#anonymous"](arguments.body) end
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = {
          ["<DOWN>"] = cmp.mapping.select_next_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<UP>"] = cmp.mapping.select_prev_item(),
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<TAB>"] = cmp.mapping.confirm({select = true}),
        },
        sources = cmp.config.sources({{name = "nvim_lsp"}, {name = "vsnip"}}, {{name = "buffer"}})
      })
    end,
  },
  {
    "jpetrie/flip",
    dev = true,
    opts = {
      include_path = true,
    }
  },
  {
    "jpetrie/lightswitch",
    dev = true,
    opts = {}
  },
  {
    "jpetrie/schematic",
    dev = true,
    opts = {
      on_project_loaded = function(project)
        local filter = function()
          local active = require("schematic").project()
          return active ~= nil and active.name == project.name
        end

        project.metadata.clean_tag = "Clean (" .. project.name .. ")"
        project.metadata.build_tag = "Build (" .. project.name .. ")"
        project.metadata.debug_tag = "Debug (" .. project.name .. ")"

        -- Set up Overseer tasks.
        local overseer = require("overseer")
        overseer.register_template({
          name = project.metadata.build_tag,
          builder = function()
            return {
              cmd = {"make"},
              args = {"-j", "4", "-C", project.config().directory, project.target().name},
              name = "Build " .. project.target().name .. " (" .. project.config().name .. ")",
            }
          end,
          condition = {callback = filter},
        })

        overseer.register_template({
          name = project.metadata.clean_tag,
          builder = function()
            return {
              cmd = {"make"},
              args = {"-j", "4", "-C", project.config().directory, "clean"},
              name = project.metadata.clean_tag,
            }
          end,
          condition = {callback = filter},
        })

        -- Set up DAP configuration.
        local dap = require("dap")
        dap.configurations[project.metadata.debug_tag] = {
          name = project.metadata.debug_tag,
          preLaunchTask = project.metadata.build_tag,
          program = function()
            return project.target().path
          end,
          request = "launch",
          type = "cpp",
        }

        -- Set up DAP UI.
        local dapui = require("dapui")
        dap.listeners.before.attach.dapui_config = function() dapui.open() end
        dap.listeners.before.launch.dapui_config = function() dapui.open() end
      end
    }
  },
  {
    "jpetrie/snapshot",
    dev = true,
    opts = {
      allow_paths = {
        "~/.config/nvim",
        "~/Developer",
      },
    }
  },
  {
    "jpetrie/turnip",
    dev = true,
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true

      -- Prevent flicker on launch (see https://github.com/neovim/neovim/issues/19362).
      vim.fn.system("defaults read -g AppleInterfaceStyle")
      if (vim.v.shell_error == 0) then
        vim.opt.background = "dark"
      else
        vim.opt.background = "light"
      end

      vim.cmd("colorscheme turnip")
    end,
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      dap.adapters.cpp = {
        type = "executable",
        command = "/opt/homebrew/opt/llvm/bin/lldb-vscode",
        name = "lldb",
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  },
  {
    "numToStr/Comment.nvim",
    opts = {},
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.2",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("telescope").setup()
      require("telescope").load_extension("fzf")
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
    "rcarriga/nvim-dap-ui",
    dependencies = {"nvim-neotest/nvim-nio"},
    opts = {
      layouts = {{
        position = "bottom",
        size = 10,
        elements = {{id = "repl", size = 0.5}, {id = "scopes", size = 0.5}}
      }}
    },
  },
  {
    "stevearc/overseer.nvim",
    config = function()
      require("overseer").setup({})

      -- Replace JSON decoders with overseer's. This allows for comments and trailing commas. 
      local json_decode = require("overseer.json").decode
      require("dap.ext.vscode").json_decode = json_decode
      require("schematic").json_decode = json_decode
    end,
  },
}

-- Define the leaders before initializing lazy.nvim, or remaps that use them won't be correct.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Setup Lazy.
require("lazy").setup(plugins, options)

-- Setup everything else.
require("jpetrie/commands")
require("jpetrie/keymaps")
require("jpetrie/lsp")
require("jpetrie/options")
require("jpetrie/statusline")

