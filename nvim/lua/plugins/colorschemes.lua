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
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "day", -- The theme comes in three styles, `storm`, a darker variant `night` and `day`
      light_style = "day", -- The theme is used when the background is set to light
      transparent = true, -- Enable this to disable setting the background color
      terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
      styles = {
        -- Style to be applied to different syntax groups
        -- Value is any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        -- Background styles. Can be "dark", "transparent" or "normal"
        sidebars = "transparent", -- style for sidebars, see below
        floats = "transparent", -- style for floating windows
      },
      day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
      dim_inactive = false, -- dims inactive windows
      lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
      cache = true, -- When set to true, the theme will be cached for better performance
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-day",
    },
  },
}
