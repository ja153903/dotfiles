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
      animate = { enabled = true },
      indent = { enabled = false },
      dashboard = { enabled = false },
      picker = {
        layout = {
          layout = {
            backdrop = false,
            row = 0,
            col = 0,
            width = 0,
            height = 0,
            border = "none",
            box = "vertical",
            { win = "input", height = 1, border = "bottom" },
            { win = "list", flex = 1, border = "none" },
            { win = "preview", height = 0.3, border = "top" },
          },
        },
      },
    },
  },
}
