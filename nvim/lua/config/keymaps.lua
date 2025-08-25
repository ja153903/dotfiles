-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle ZenMode
vim.keymap.set("n", "<leader>z", function()
  require("zen-mode").toggle()
end, { desc = "Toggle ZenMode" })
