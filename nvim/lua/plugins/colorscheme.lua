return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        variant = "auto",
        transparent = true,
        saturation = 0.8,
        italic_comments = false,
        hide_fillchars = false,
        borderless_pickers = false,
        terminal_colors = true,
        cache = false,
        highlights = {
          Comment = { fg = "#696969", bg = "NONE", italic = true },
        },
        overrides = function(colors)
          return {
            Comment = { fg = colors.green, bg = "NONE", italic = true },
          }
        end,
      })

      vim.cmd.colorscheme("cyberdream")
    end,
  },
}
