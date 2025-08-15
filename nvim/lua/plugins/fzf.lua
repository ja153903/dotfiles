return {
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- or if using mini.icons/mini.nvim
    -- dependencies = { "echasnovski/mini.icons" },
    config = function()
      require("fzf-lua").setup({
        winopts = { fullscreen = true },
        previewers = {
          builtin = {
            snacks_image = { enabled = false, render_inline = false },
          },
        },
      })
    end,
  },
}
