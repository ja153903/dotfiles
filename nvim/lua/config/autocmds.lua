-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_user_command("CopyRelPath", "call setreg('+', fnamemodify(expand('%'), ':.'))", {})
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

-- make .roc files have the correct filetype
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.roc" },
  command = "set filetype=roc",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.orig", "MERGE_*", "COMMIT_EDITMSG" },
  callback = function()
    vim.diagnostic.enable(false)
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      vim.lsp.buf_detach_client(0, client.id)
    end
  end,
})
