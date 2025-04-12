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

set_filetype_settings("cpp", 2, 2)
set_filetype_settings("c", 2, 2)
set_filetype_settings("roc", 4, 4)

-- make .roc files have the correct filetype
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.roc" },
  command = "set filetype=roc",
})

-- add roc tree-sitter
local parsers = require("nvim-treesitter.parsers").get_parser_configs()

parsers.roc = {
  install_info = {
    url = "https://github.com/faldor20/tree-sitter-roc",
    files = { "src/parser.c", "src/scanner.c" },
  },
}
