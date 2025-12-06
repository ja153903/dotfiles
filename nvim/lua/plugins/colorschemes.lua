return {
  -- Using lazy.nvim
  {
    "deparr/tairiki.nvim",
    lazy = false,
    priority = 1000, -- recommended if you use tairiki as your default theme
    config = function()
      vim.cmd([[colorscheme tairiki]])
    end,
  },
}
