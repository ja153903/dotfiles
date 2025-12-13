return {
  -- Using lazy.nvim
  -- {
  --   "deparr/tairiki.nvim",
  --   lazy = false,
  --   priority = 1000, -- recommended if you use tairiki as your default theme
  --   config = function()
  --     require("tairiki").setup({
  --       palette = "dark", -- main palette, available options: dark, light, dimmed, tomorrow, light_legacy
  --       default_dark = "tomorrow",
  --       default_light = "light",
  --       transparent = false, -- don't set background colors
  --       terminal = false, -- override nvim terminal colors
  --       end_of_buffer = false, -- show end of buffer filler lines (tildes)
  --       visual_bold = false, -- bolden visual selections
  --       cmp_itemkind_reverse = false, -- reverse fg/bg on nvim-cmp item kinds
  --
  --       diagnostics = {
  --         darker = false, -- darken diagnostic virtual text
  --         background = true, -- add background to diagnostic virtual text
  --         undercurl = true, -- use undercurls for inline diagnostics
  --       },
  --
  --       -- style for different syntactic tokens
  --       -- see :help nvim_set_hl() for available keys
  --       code_style = {
  --         comments = { italic = true },
  --         conditionals = {},
  --         keywords = {},
  --         functions = {},
  --         strings = {},
  --         variables = {},
  --         parameters = {},
  --         types = {},
  --       },
  --
  --       -- lualine theme config
  --       lualine = {
  --         transparent = false, -- remove background from center section
  --       },
  --
  --       -- which plugins to enable
  --       plugins = {
  --         all = false, -- enable all supported plugins
  --         none = false, -- ONLY set groups listed in :help highlight-groups (see lua/tairiki/groups/neovim.lua). Manually enabled plugins will also be ignored
  --         auto = false, -- auto detect installed plugins, currently lazy.nvim only
  --
  --         -- or enable/disable plugins manually
  --         -- see lua/tairiki/groups/init.lua for the full list of available plugins
  --         -- either the key or value from the M.plugins table can be used as the key here
  --         --
  --         -- setting a specific plugin manually overrides `all` and `auto`
  --         treesitter = true,
  --         semantic_tokens = true,
  --       },
  --
  --       -- optional function to modify or add colors to the palette
  --       -- palette definitions are in lua/tairiki/palette
  --       colors = function(colors, opts) end,
  --
  --       -- optional function to override highlight groups
  --       highlights = function(groups, colors, opts) end,
  --     })
  --     vim.cmd([[colorscheme tairiki]])
  --   end,
  -- },
  -- {
  --   "Mofiqul/vscode.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     -- Lua:
  --     vim.o.background = "light"
  --
  --     local c = require("vscode.colors").get_colors()
  --     require("vscode").setup({
  --       -- Alternatively set style in setup
  --       -- style = 'light'
  --
  --       -- Enable transparent background
  --       transparent = false,
  --
  --       -- Enable italic comment
  --       italic_comments = true,
  --
  --       -- Enable italic inlay type hints
  --       italic_inlayhints = true,
  --
  --       -- Underline `@markup.link.*` variants
  --       underline_links = true,
  --
  --       -- Disable nvim-tree background color
  --       disable_nvimtree_bg = true,
  --
  --       -- Apply theme colors to terminal
  --       terminal_colors = true,
  --     })
  --     -- require('vscode').load()
  --
  --     -- load the theme without affecting devicon colors.
  --     vim.cmd.colorscheme("vscode")
  --   end,
  -- },
  -- {
  --   "projekt0n/github-nvim-theme",
  --   name = "github-theme",
  --   lazy = false, -- make sure we load this during startup if it is your main colorscheme
  --   priority = 1000, -- make sure to load this before all the other start plugins
  --   config = function()
  --     require("github-theme").setup({
  --       -- ...
  --     })
  --
  --     vim.cmd("colorscheme github_light")
  --   end,
  -- },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = { -- :h background
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false, -- disables setting the background color.
        float = {
          transparent = false, -- enable transparent floating windows
          solid = false, -- use solid styling for floating windows, see |winborder|
        },
        show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
          enabled = false, -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        no_italic = true, -- Force no italic
        no_bold = true, -- Force no bold
        no_underline = false, -- Force no underline
        styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
          comments = { "italic" }, -- Change the style of comments
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
          -- miscs = {}, -- Uncomment to turn off hard-coded styles
        },
        lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
            ok = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
        color_overrides = {},
        custom_highlights = {},
        default_integrations = true,
        auto_integrations = false,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
          -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },
      })

      -- setup must be called before loading
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
