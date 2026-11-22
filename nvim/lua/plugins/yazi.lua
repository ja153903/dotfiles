-- netrw is disabled in options.lua so yazi handles directories
require("yazi").setup({
  open_for_directories = true,
  keymaps = { show_help = "<f1>" },
})

vim.keymap.set({ "n", "v" }, "<leader>fm", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" })
vim.keymap.set("n", "<leader>cw", "<cmd>Yazi cwd<cr>", { desc = "Open the file manager in nvim's working directory" })
vim.keymap.set("n", "<c-up>", "<cmd>Yazi toggle<cr>", { desc = "Resume the last yazi session" })
