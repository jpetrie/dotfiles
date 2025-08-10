vim.opt.wildmode = "longest:full"

return {
  {
    "saghen/blink.cmp",

    -- Requesting a specific tag will download binaries, avoiding the need to build locally.
    tag = "v1.6.0",
    opts = {
      keymap = {
        preset = "none",
        ["<C-CR>"] = {"accept"},
        ["<C-n>"] = {"select_next", "fallback"},
        ["<C-p>"] = {"select_prev", "fallback"},
      },
    },
  },
}

