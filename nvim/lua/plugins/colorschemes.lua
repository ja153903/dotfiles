return {
  -- Lazy
  {
    "vague2k/vague.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- NOTE: you do not need to call setup if you don't want to.
      require("vague").setup({ -- optional configuration here
      })

      vim.cmd([[colorscheme vague]])
    end,
  },
}
