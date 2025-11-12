return {
  {
    "tiesen243/vercel.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("vercel").setup({
        transparent = false, -- Boolean: Sets the background to transparent (Default: false)
        italics = {
          comments = true, -- Boolean: Italicizes comments (Default: true)
          keywords = false, -- Boolean: Italicizes keywords (Default: true)
          functions = false, -- Boolean: Italicizes functions (Default: true)
          strings = false, -- Boolean: Italicizes strings (Default: true)
          variables = false, -- Boolean: Italicizes variables (Default: true)
          bufferline = false, -- Boolean: Italicizes bufferline (Default: false)
        },
        overrides = {}, -- A dictionary of group names, can be a function returning a dictionary or a table.
      })

      -- This must be called before setting the colorscheme, otherwise it will always default to light mode
      vim.cmd.colorscheme("vercel")
    end,
  },
  {
    "wurli/cobalt.nvim",
    enabled = false,
    -- lazy = false,
    -- priority = 1000,
    config = function()
      -- vim.cmd([[colorscheme cobalt]])
    end,
  },
  {
    "Mofiqul/vscode.nvim",
    -- lazy = false,
    -- priority = 1000,
    enabled = false,
    config = function()
      local c = require("vscode.colors").get_colors()
      require("vscode").setup({
        -- Alternatively set style in setup
        -- style = 'light'

        -- Enable transparent background
        transparent = false,

        -- Enable italic comment
        italic_comments = true,

        -- Enable italic inlay type hints
        italic_inlayhints = true,

        -- Underline `@markup.link.*` variants
        underline_links = true,

        -- Disable nvim-tree background color
        disable_nvimtree_bg = true,

        -- Apply theme colors to terminal
        terminal_colors = true,

        -- Override colors (see ./lua/vscode/colors.lua)
        color_overrides = {
          vscLineNumber = "#FFFFFF",
        },

        -- Override highlight groups (see ./lua/vscode/theme.lua)
        group_overrides = {
          -- this supports the same val table as vim.api.nvim_set_hl
          -- use colors from this colorscheme by requiring vscode.colors!
          Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
        },
      })
      -- require("vscode").load()

      -- load the theme without affecting devicon colors.
      -- vim.cmd([[colorscheme vscode]])
    end,
  },
}
