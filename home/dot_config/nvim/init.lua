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

-- Completion
vim.opt.completeopt = {"menuone", "noinsert"}

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
-- Commands

-- Reveal the current buffer in the Finder.
vim.api.nvim_create_user_command("Reveal", function() vim.system({"open", "-R", vim.api.nvim_buf_get_name(0)}) end, {})

-- Populate the quickfix list with TODO comments.
vim.api.nvim_create_user_command("Todo", "silent grep! TODO: | copen", {})


-- =====================================================================================================================
-- Keymaps

-- Edit init.lua.
vim.keymap.set("n", "ev", ":e $MYVIMRC<CR>", {desc = "Edit init.lua"})

vim.keymap.set("i", "<C-space>", "<C-y>", {desc = "Accept current completion"})
vim.keymap.set("i", "<C-j>", "<C-n>", {desc = "Select next completion"})
vim.keymap.set("i", "<C-k>", "<C-p>", {desc = "Select prior completion"})

-- Jump to long lines.
vim.keymap.set("n", "]ll", "/\\%>" .. vim.o.textwidth .. "v.\\+<CR>", {desc = "Jump to next long line"})
vim.keymap.set("n", "[ll", "?\\%>" .. vim.o.textwidth .. "v.\\+<CR>", {desc = "Jump to prior long line"})

-- Find references.
vim.keymap.set("n", "qr", ":Refs<CR>", {desc = "Set quickfix to symbol references"})

-- Flip between file counterparts.
vim.keymap.set("n", "<LEADER>a", ":Flip next<CR>", {desc = "Flip to the next counterpart"})

-- Invoke Lantern tasks.
vim.keymap.set("n", "<LEADER>k", function() require("lantern").clean() end, {desc = "Clean the current Lantern target"})
vim.keymap.set("n", "<LEADER>b", function() require("lantern").build() end, {desc = "Build the current Lantern target"})
vim.keymap.set("n", "<LEADER>r", function() require("lantern").run() end, {desc = "Run the current Lantern target"})

-- Launch Telescope.
vim.keymap.set("n", "<LEADER>of", ":Telescope find_files<CR>", {desc = "File files"})
vim.keymap.set("n", "<LEADER>ob", ":Telescope buffers<CR>", {desc = "Find buffers"})
vim.keymap.set("n", "<LEADER>fg", ":Telescope live_grep<CR>", {desc = "Find in files"})
vim.keymap.set("n", "<LEADER>fh", ":Telescope help_tags<CR>", {desc = "Find in help"})

-- Session management.
vim.keymap.set("n", "<leader>ss", require("resession").save)
vim.keymap.set("n", "<leader>sl", require("resession").load)
vim.keymap.set("n", "<leader>sd", require("resession").delete)


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

-- Only start clangd when a suitable Lantern project exists.
vim.api.nvim_create_autocmd("FileType", {pattern = "cpp", callback = function(_)
  local has_lantern, lantern = pcall(require, "lantern")
  if has_lantern and lantern.configuration() ~= nil then
    -- Try to launch a version of clangd installed by Homebrew, as it should be newer. Otherwise fall back to the
    -- version installed by the OS.
    local clangd_path = "/opt/homebrew/opt/llvm/bin/clangd"
    if not vim.fn.executable(clangd_path) then
      clangd_path = "clangd"
    end

    vim.lsp.start({
      name = "clangd",

      -- Passing --log=error causes clangd to only write actual errors to stderr (by default, it will write pretty much
      -- everything to stderr, which bloats the LSP log very quickly).
      cmd = {clangd_path, "--log=error", "--compile-commands-dir=" .. lantern.configuration().directory},
      root_dir = lantern.project().directory,
    })
  end

  vim.treesitter.start()
end})

vim.api.nvim_create_autocmd("LspAttach", {callback = function(_)
  -- When a language server is active, replace the built-in gd keymap.
  vim.keymap.set("n", "gd", ":lua vim.lsp.buf.definition()<CR>", {desc = "Go to the definition of the symbol under the cursor"})
end })

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
-- Plugin Setup

require("lantern").setup({
  exclude_binary_directory_patterns = {"Xcode"},
  save_before_task = true,
  run_task = function(command)
    local task = require("overseer").new_task({
      cmd = command,
      components = {
        {
          "on_output_quickfix",
          errorformat = vim.o.errorformat,
          items_only = true,
          open_on_match = true,
          close = true,
        },
        "default"
      }
    })

    task:start()
  end,
})

require("lightswitch").setup({})

require("nvim-treesitter").install({"c", "cmake", "cpp", "doxygen", "objc"})

require("mini.completion").setup({
  lsp_completion = {
    source_func = "omnifunc"
  },
  mappings = {
    -- The default for this is <C-space>, which has been mapped to <C-y> earlier in this file to accept a completion.
    force_twostep = ""
  }
})

local icons = require("mini.icons")
icons.setup()
icons.mock_nvim_web_devicons()
icons.tweak_lsp_kind("prepend")

require("overseer").setup()

require("quicker").setup()

require("resession").setup({
  extensions = {
    lantern = {},
  },
  buf_filter = function(buffer)
    -- Do not save any of the filetypes in this list with the session, defer to the default implementation for
    -- everything else.
    local skip_filetypes = {"gitcommit", "help"}
    if vim.list_contains(skip_filetypes, vim.bo[buffer].filetype) then
      return false
    end

    return require("resession").default_buf_filter(buffer)
  end
})

require("telescope").load_extension("fzy_native")

require("turnip").setup({
  custom_groups = {
    ["@keyword.doxygen"] = {fg = "green_faint"},
    ["@keyword.modifier.doxygen"] = {link = "Comment"},
    ["@punctuation.bracket.doxygen"] = {fg = "gray_slate"},
  }
})

vim.api.nvim_create_autocmd("VimEnter", {callback = function(_)
  local resession = require("resession")
  local lantern = require("lantern")
  lantern.scan()

  -- If Neovim started with no arguments and without reading from stdin, try to load the session for the active project
  -- if one exists.
  if vim.fn.argc(-1) == 0 and not vim.g.using_stdin and lantern.project() ~= nil then
    resession.load(lantern.project().name, {silence_errors = true})
  end
end})

vim.api.nvim_create_autocmd("VimLeavePre", {callback = function(_)
  -- If an active session exists, save it.
  local resession = require("resession")
  local session = resession.get_current_session_info()
  if session ~= nil then
    resession.save(session.name)
  end
end})

vim.cmd("colorscheme turnip")

