local map_options = {noremap = true, silent = true}

-- Neovim Mappings

-- Diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, map_options)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, map_options)

-- Search
vim.keymap.set("n", "[ll", "?\\%>120v.\\+<CR>", map_options)
vim.keymap.set("n", "]ll", "/\\%>120v.\\+<CR>", map_options)


-- Plugin Mappings

-- DAP
vim.keymap.set("n", "<LEADER>db", function() require("dap").toggle_breakpoint() end, map_options)
vim.keymap.set("n", "<F9>", function() require("dap").step_over() end, map_options)
vim.keymap.set("n", "<LEADER>ds", function() require("dap").terminate() require("dapui").close() end, map_options)

-- DAP UI
vim.keymap.set("n", "dt", function() require("dapui").toggle() end, map_options)

-- Flip
vim.keymap.set("n", "<LEADER>a", ":FlipNext<CR>", map_options)
vim.keymap.set("n", "<LEADER>A", ":FlipPrevious<CR>", map_options)

-- Overseer
vim.keymap.set("n", "<LEADER>tl", function() require("overseer").toggle({enter = false}) end, map_options)

-- Schematic
vim.keymap.set("n", "<LEADER>K", ":Clean<CR>", map_options)
vim.keymap.set("n", "<LEADER>b", ":Build<CR>", map_options)
vim.keymap.set("n", "<LEADER>r", ":Run<CR>", map_options)

-- Snapshot
vim.keymap.set("n", "<LEADER>ss", ":SnapSave<CR>", map_options)
vim.keymap.set("n", "<LEADER>sl", ":SnapLoad<CR>", map_options)

-- Telescope
local telescope = require("telescope.builtin")

vim.keymap.set("n", "<LEADER>of", telescope.find_files, map_options)
vim.keymap.set("n", "<LEADER>ob", telescope.buffers, map_options)
vim.keymap.set("n", "<LEADER>ov", function() return telescope.find_files({cwd = "~/.config/nvim", follow = true}) end, {})
vim.keymap.set("n", "<LEADER>fg", telescope.live_grep, map_options)
vim.keymap.set("n", "<LEADER>fh", telescope.help_tags, map_options)
