-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.hl = vim.highlight
vim.opt.list = false
vim.opt.termguicolors = true
vim.opt.guicursor = {
  "n-v-c-sm:block", -- normal, visual, command: steady block
  "i-ci-ve:ver25-blinkon500-blinkoff500-blinkwait500", -- insert: blinking vertical bar
  "r-cr-o:hor20", -- replace, operator-pending: steady horizontal bar
}
-- Source - https://stackoverflow.com/a/78627671
-- Posted by Daniel Macak, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-01-30, License - CC BY-SA 4.0

vim.o.cmdheight = 4

vim.g.lsp_enabled = false
