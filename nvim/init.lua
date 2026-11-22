vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.pack")

if vim.g.vscode then
  require("config.vscode")
  return
end

require("config.theme").setup()
for _, name in ipairs({
  "snacks",
  "ui",
  "noice",
  "lualine",
  "editor",
  "treesitter",
  "blink",
  "lsp",
  "conform",
  "lint",
  "markdown",
  "flash",
  "yazi",
  "codediff",
}) do
  require("plugins." .. name)
end
require("config.keymaps")
require("config.autocmds")
