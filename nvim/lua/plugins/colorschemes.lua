return {
  {
    "tanvirtin/monokai.nvim",
  },
  { "EdenEast/nightfox.nvim" }, -- lazy
  {
    "oskarnurm/koda.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "koda-glade",
    },
  },
}
