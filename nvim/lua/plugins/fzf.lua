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
        files = {
          formatter = "path.dirname_first",
        },
        fzf_opts = {
          ["--delimiter"] = "/",
          ["--with-nth"] = "-2..",
        },
      })
    end,
  },
}
