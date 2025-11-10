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

local function set_filetype_settings(lang, width, tabstop)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = lang,
    command = string.format("setlocal shiftwidth=%d tabstop=%d", width, tabstop),
  })
end

set_filetype_settings("cpp", 2, 2)
set_filetype_settings("c", 2, 2)
set_filetype_settings("roc", 4, 4)
