vim.opt.wildmode = "longest:full"

return {
  {
    "saghen/blink.cmp",

    -- Requesting a specific version will download binaries, avoiding the need to build locally.
    version = "1.*",
    opts = {
      keymap = {preset = "enter"},
    },
  },
}

