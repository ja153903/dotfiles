return {
  {
    "embark-theme/vim",
    lazy = false,
    priority = 1000,
    name = "embark",
    config = function()
      require("config.theme").setup()
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "embark",
    },
  },
}
