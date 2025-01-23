return {
  {
    "folke/noice.nvim",
    config = function()
      require("noice").setup({
        lsp = {
          hover = {
            silent = true,
          },
        },
        views = {
          cmdline_popup = {
            backend = "popup",
            relative = "editor",
            focusable = false,
            enter = false,
            zindex = 200,
            position = {
              row = "50%",
              col = "50%",
            },
            size = {
              min_width = 60,
              width = "auto",
              height = "auto",
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = {
                Normal = "NoiceCmdlinePopup",
                FloatTitle = "NoiceCmdlinePopupTitle",
                FloatBorder = "NoiceCmdlinePopupBorder",
                IncSearch = "",
                CurSearch = "",
                Search = "",
              },
              winbar = "",
              foldenable = false,
              cursorline = false,
            },
          },
        },
      })
    end,
  },
}
