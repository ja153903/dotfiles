return {
  {
    "folke/noice.nvim",
    config = function()
      require("noice").setup({
        cmdline = {
          view = "cmdline",
        },
      })
    end,
  },
}
