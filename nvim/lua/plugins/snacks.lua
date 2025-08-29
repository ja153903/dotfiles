return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
      },
      indent = { enabled = false },
      input = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      picker = {
        -- layout = {
        --   fullscreen = true,
        -- },
        sources = {
          explorer = {
            auto_close = true,
          },
        },
      },
      scope = { enabled = true },
      animate = { enabled = false },
      images = { enabled = false },
      terminal = { enabled = true },
    },
  },
}
