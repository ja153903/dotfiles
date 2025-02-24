-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_user_command("CopyRelPath", "call setreg('+', expand('%'))", {})

local function set_filetype_settings(lang, width, tabstop)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = lang,
    command = string.format("setlocal shiftwidth=%d tabstop=%d", width, tabstop),
  })
end

set_filetype_settings("cpp", 4, 4)
set_filetype_settings("c", 4, 4)
