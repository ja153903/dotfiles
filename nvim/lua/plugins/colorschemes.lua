return {
  -- {
  --   "ja153903/embark-theme-vim",
  --   dir = vim.fn.expand("~/programming/oss/embark-theme-vim"),
  --   dev = true,
  --   lazy = false,
  --   priority = 1000,
  --   name = "embark",
  -- },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized-osaka",
    },
  },
}
