return {
  -- {
  --   "sainnhe/sonokai",
  --   config = function()
  --     vim.g.sonokai_style = "andromeda"
  --     vim.g.sonokai_better_performance = 1
  --     vim.cmd([[colorscheme sonokai]])
  --   end,
  -- },

  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("github-theme").setup({
        -- ...
      })

      vim.cmd("colorscheme github_light")
    end,
  },
}
