return {
  {
    "sainnhe/gruvbox-material",
    lazy = false, -- load at start
    priority = 1000, -- load first
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox-material",
    },
  },
}
