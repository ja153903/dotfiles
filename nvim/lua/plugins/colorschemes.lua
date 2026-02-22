return {
  {
    "everviolet/nvim",
    name = "evergarden",
    priority = 1000, -- Colorscheme plugin is loaded first before any other plugins
    config = function()
      require("evergarden").setup({
        theme = {
          variant = "winter", -- 'winter'|'fall'|'spring'|'summer'
          accent = "cherry",
        },
        editor = {
          transparent_background = true,
          override_terminal = true,
          sign = { color = "none" },
          float = {
            color = "none",
            solid_border = false,
          },
          completion = {
            color = "surface0",
          },
        },
        style = {
          tabline = { "reverse" },
          search = { "italic", "reverse" },
          incsearch = { "italic", "reverse" },
          types = { "italic" },
          keyword = { "italic" },
          comment = { "italic" },
        },
        overrides = {},
        color_overrides = {},
      })
      vim.cmd([[colorscheme evergarden]])
    end,
  },
}
