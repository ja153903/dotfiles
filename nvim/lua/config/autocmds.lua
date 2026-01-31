-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_user_command("CopyRelPath", function()
  local filepath = vim.fn.expand("%:p")
  local cwd = vim.fn.getcwd()
  local relative_path = vim.fn.fnamemodify(filepath, ":s?" .. cwd .. "/??")
  vim.fn.setreg("+", relative_path)
  print("Copied to clipboard: " .. relative_path)
end, {})
vim.api.nvim_create_user_command("CopyAbsPath", "call setreg('+', expand('%:p'))", {})

vim.api.nvim_create_user_command("CopyClaudePath", function()
  local rel_path = vim.fn.expand("%:.")
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local result = "@" .. rel_path .. ":" .. row
  vim.fn.setreg("+", result)
  print("Copied to clipboard: " .. result)
end, {})
