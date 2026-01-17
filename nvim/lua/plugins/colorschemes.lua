return {
  -- Lua with Lazy.nvim:
  {
    "Mofiqul/adwaita.nvim",
    lazy = false,
    priority = 1000,
    -- configure and set on startup
    config = function()
      vim.o.background = "light"
      vim.g.adwaita_disable_cursorline = true -- to disable cursorline
      vim.cmd("colorscheme adwaita")
    end,
  },
}
