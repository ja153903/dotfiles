return {
  {
    "wurli/cobalt.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd([[colorscheme cobalt]])
    end,
  },
}
