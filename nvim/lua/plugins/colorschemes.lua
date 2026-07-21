return {
  {
    "ja153903/embark-theme-vim",
    dir = vim.fn.expand("~/programming/oss/embark-theme-vim"),
    dev = true,
    lazy = false,
    priority = 1000,
    name = "embark",
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "embark",
    },
  },
}
