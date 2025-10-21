-- Ensure Lazy is installed.
local lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazy) then
  local repository = "https://github.com/folke/lazy.nvim.git"
  local output = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", repository, lazy})
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({{"Failed to clone lazy.nvim:\n" .. output, "ErrorMsg"}}, true, {})
  end
end

if vim.fn.has("mac") ~= 0 then
  -- Prevent flicker on launch (see https://github.com/neovim/neovim/issues/19362).
  vim.fn.system("defaults read -g AppleInterfaceStyle")
  if (vim.v.shell_error == 0) then
    vim.opt.background = "dark"
  else
    vim.opt.background = "light"
  end
end

-- =====================================================================================================================
-- Options

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Files and Paths
vim.opt.wildignore = {"*.air", "*.d", "*.dia", "*.o"}

-- Formatting
vim.opt.formatoptions = "cro/qj"
vim.opt.textwidth = 120

-- Indentation
vim.opt.autoindent = true
vim.opt.cinoptions = "g0"
vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- Line Handling
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.opt.showbreak="↳"
vim.opt.wrap = false

-- Appearance and UI
vim.opt.colorcolumn = "+1"
vim.opt.list = true
vim.opt.listchars = "eol:¬,tab:>-,space:·,extends:▶,precedes:◀,nbsp:•"
vim.opt.number = true
vim.opt.ruler = false
vim.opt.shortmess = "filmrxWIF"
vim.opt.showcmd = false
vim.opt.signcolumn = "yes:1"
vim.opt.wildmode = "longest:full"

-- Search
vim.opt.hlsearch = false

if vim.fn.executable("rg") then
  -- If rg exists, Neovim will pass -uu by default (which includes ignored/hidden files); setting grepprg manually
  -- allows that option to be avoided.
  vim.opt.grepprg = "rg --vimgrep"
end

-- Statusline
vim.opt.statusline = "%!v:lua.BuildStatusLine()"


-- =====================================================================================================================
-- Keymaps

-- Edit init.lua.
vim.keymap.set("n", "ev", ":e $MYVIMRC<CR>", {desc = "Edit init.lua"})

-- Jump to long lines.
vim.keymap.set("n", "]ll", "/\\%>" .. vim.o.textwidth .. "v.\\+<CR>", {desc = "Jump to next long line"})
vim.keymap.set("n", "[ll", "?\\%>" .. vim.o.textwidth .. "v.\\+<CR>", {desc = "Jump to prior long line"})

-- Populate the quickfix list with TODO comments.
vim.api.nvim_create_user_command("Todo", "silent grep! TODO: | copen", {})


-- =====================================================================================================================
-- Statusline

-- Run a background timer to periodically update the task spinner and redraw the statusline.
local task_status = ""
local tick_index = 0
local tick_timer = vim.uv.new_timer()
if tick_timer ~= nil then
  local interval = 250
  tick_timer:start(interval, interval, vim.schedule_wrap(function()
    local has_overseer, overseer = pcall(require, "overseer")
    if has_overseer then
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

  -- Shorten the path by reducing all intermediate directory names longer than some cutoff. This provides a bit more
  -- context than simply reducing them to a single character.
  path = path:gsub("([^/]+)/", function (directory)
    local cutoff = 3
    if #directory < cutoff then
      return directory .. "/"
    else
      return vim.fn.strcharpart(directory, 0, cutoff) .. "…/"
    end
  end)

  table.insert(parts, path)
  if #path > 0 then
    table.insert(parts, " ")
  end

  if window == vim.api.nvim_get_current_win() then
    table.insert(parts, "%l:%v%=")
    table.insert(parts, task_status)

    local has_lantern, lantern = pcall(require, "lantern")
    if has_lantern then
      local project = lantern.project()
      if project ~= nil then
        table.insert(parts, project.name)
        local configuration = lantern.configuration()
        if configuration ~= nil then
          table.insert(parts, "/" .. configuration.name)
          local target = lantern.target()
          if target ~= nil then
            table.insert(parts, "/" .. target.name)
          end
        end
      end
    end
  end

  return table.concat(parts, "")
end


-- =====================================================================================================================
-- Language Servers

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


-- =====================================================================================================================
-- Diagnostics

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


-- =====================================================================================================================
-- Plugins

if not vim.uv.fs_stat(lazy) then
  -- Nothing but plugin configuration should be below this point in the file, so early-out here if Lazy is not
  -- available. This reduces the overall nesting of the plugin specifications.
  return
end

vim.opt.runtimepath:prepend(lazy)
require("lazy").setup({
  dev = {path = "~/Developer", fallback = true},
  spec = {
    {
      "bezhermoso/tree-sitter-ghostty",
      build = "make nvim_install",
    },
    {
      "folke/snacks.nvim",
      priority = 1000,
      opts = function(_, options)
        options.dashboard = {
          enabled = true,
          width = 60,
          sections = {
            {title = "Neovim " .. tostring(vim.version()), padding = 2, align = "center"},
            function()
              local has_resession, resession = pcall(require, "resession")
              local results = {}
              if has_resession then
                table.insert(results, {text = {"Recent Sessions: ───────────────────────────────────────────", hl = "SnacksDashboardKey"}})
                for index, name in ipairs(resession.list()) do
                  local key = tostring(index)
                  table.insert(results, {
                    text = {{name, width = 53, align = "left"}, {"[" .. key .. "] ", align = "right", hl = "SnacksDashboardDir"}},
                    action = function() resession.load(name) end,
                    key = key,
                    indent = 2,
                  })
                end
              end

              return results
            end,
          },
        }
        
        options.indent = {
          enabled = true,
          only_scope = true,
          animate = {enabled = false},
          filter = function (buffer)
            local ignore_filetypes = {"help", "markdown", "text"}
            return not vim.list_contains(ignore_filetypes, vim.bo[buffer].filetype)
          end,
        }

        return options
      end,
    },
    {
      "jpetrie/flip",
      opts = {},
      keys = {
        {"<LEADER>a", ":Flip next<CR>", desc = "Flip to the next counterpart"},
      }
    },
    {
      "jpetrie/lantern",
      lazy = false,
      opts = {},
      config = function(_, options)
        local lantern = require("lantern")
        lantern.setup(options)
        vim.api.nvim_create_autocmd("VimEnter", { callback = function(_) lantern.scan() end })
      end,
      keys = {
        {
          "<LEADER>k",
          function()
            require("lantern").run("clean")
          end,
          desc = "Clean the active target"
        },
        {
          "<LEADER>b",
          function()
            require("lantern").run("build")
          end,
          desc = "Build the active target"
        },
        {
          "<LEADER>r",
          function()
            require("lantern").run("run")
          end,
          desc = "Run the active target"
        },
      },
    },
    {
      "jpetrie/lightswitch",
      opts = {},
    },
    {
      "jpetrie/turnip",
      priority = 1000,
      config = function()
        vim.cmd("colorscheme turnip")
      end,
    },
    {
      "ngynkvn/gotmpl.nvim",
      opts = {},
    },
    {
      "nvim-telescope/telescope.nvim",
      opts = {
        layout_strategy = "vertical",
        layout_config = {height = 0.95}
      },
      keys = {
        {"<LEADER>of", ":Telescope find_files<CR>", desc = "File files"},
        {"<LEADER>ob", ":Telescope buffers<CR>", desc = "Find buffers"},
        {"<LEADER>fg", ":Telescope live_grep<CR>", desc = "Find in files"},
        {"<LEADER>fh", ":Telescope help_tags<CR>", desc = "Find in help"},
      },
    },
    {
      "nvim-telescope/telescope-fzy-native.nvim",
      opts = function(_, options)
        require("telescope").load_extension("fzy_native")
        return options
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      opts = {
        ensure_installed = {"c", "cmake", "cpp", "gitignore", "gotmpl", "json", "query", "rust", "lua", "vim", "vimdoc"},
        sync_install = false,
        auto_install = false,
        indent = {
          enable = false,
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      },
    },
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      main = "nvim-treesitter.configs",
      opts = {
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
      },
    },
    {
      "saghen/blink.cmp",
      tag = "v1.7.0",
      opts = {
        keymap = {
          preset = "none",
          ["<CR>"] = {"accept", "fallback"},
          ["<C-j>"] = {"select_next", "fallback"},
          ["<C-k>"] = {"select_prev", "fallback"},
        },
      },
    },
    {
      "stevearc/overseer.nvim",
      opts = {},
      keys = {
        {"<LEADER>tl", function() require("overseer").toggle({direction = "bottom"}) end, desc = "Toggle task list"},
      },
    },
    {
      "stevearc/resession.nvim",
      opts = function(_, options)
        SessionSave = function(behavior)
          local default_behavior = {prompt = true}
          behavior = vim.tbl_extend("keep", behavior or {}, default_behavior)

          local has_resession, resession = pcall(require, "resession")
          if has_resession then
            local info = resession.get_current_session_info()
            if info ~= nil then
              resession.save(info.name)
            elseif behavior ~= nil and behavior.prompt then
              local default_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
              local session_name = vim.fn.input("Save session as: ", default_name)
              if #session_name > 0 then
                resession.save(session_name)
              end
            end
          end
        end

        options.buf_filter = function(buffer)
          -- Do not save the filetypes in this list to the session.
          local skip = {"gitcommit", "help"}
          if vim.list_contains(skip, vim.bo[buffer].filetype) then
            return false
          end

          -- For everything not explicitly skipped, fall back to the default behavior.
          return require("resession").default_buf_filter(buffer)
        end

        -- When quitting, save the active session if it exists.
        vim.api.nvim_create_autocmd("VimLeavePre", {
          callback = function()
            SessionSave({prompt = false})
          end,
        })

        return options
      end,
      keys = {
        {"<LEADER>ss", function() SessionSave() end, desc = "Save the current session"},
        {"<LEADER>sl", function() require("resession").load() end, desc = "Load a session"},
        {"<LEADER>sd", function() require("resession").delete() end, desc = "Delete a session"},
      },
    }
  },
  install = {
    colorscheme = {"default"},
  },
})

