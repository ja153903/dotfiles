return {
  -- {
  --   "embark-theme/vim",
  --   -- lazy = false,
  --   -- priority = 1000,
  --   name = "embark",
  -- },
  {
    "oskarnurm/koda.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
  },
  {
    "datsfilipe/vesper.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
  },
  {
    "Mofiqul/vscode.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- vim.o.background = "light"

      local c = require("vscode.colors").get_colors()
      require("vscode").setup({
        -- Alternatively set style in setup
        -- style = 'light'

        -- Enable transparent background
        transparent = true,

        -- Enable italic comment
        italic_comments = true,

        -- Enable italic inlay type hints
        italic_inlayhints = true,

        -- Underline `@markup.link.*` variants
        underline_links = true,

        -- Disable nvim-tree background color
        disable_nvimtree_bg = false,

        -- Apply theme colors to terminal
        terminal_colors = true,
      })
    end,
  },
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    ---@type solarized.config
    opts = {},
    config = function(_, opts)
      -- vim.o.termguicolors = true
      -- vim.o.background = "light"
      -- require("solarized").setup(opts)
    end,
  },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  -- Using Lazy
  {
    "navarasu/onedark.nvim",
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("onedark").setup({
        style = "darker",
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
