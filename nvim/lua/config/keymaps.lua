-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

if vim.g.vscode then
  vim.keymap.del("n", "<leader>e")
  vim.keymap.del("n", "<leader>l")
  vim.keymap.del("n", "<leader>sg")
end

