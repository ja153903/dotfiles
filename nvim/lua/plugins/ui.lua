local map = vim.keymap.set

require("mini.icons").setup({
  file = {
    [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
    ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
  },
  filetype = { dotenv = { glyph = "", hl = "MiniIconsYellow" } },
})
MiniIcons.mock_nvim_web_devicons()

require("bufferline").setup({
  options = {
    close_command = function(n)
      Snacks.bufdelete(n)
    end,
    right_mouse_command = function(n)
      Snacks.bufdelete(n)
    end,
    diagnostics = "nvim_lsp",
    always_show_bufferline = false,
    diagnostics_indicator = function(_, _, diag)
      local ret = (diag.error and " " .. diag.error .. " " or "") .. (diag.warning and " " .. diag.warning or "")
      return vim.trim(ret)
    end,
    offsets = { { filetype = "snacks_layout_box" } },
  },
})
-- keep bufferline in sync after session restore
vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
  callback = function()
    vim.schedule(function()
      pcall(nvim_bufferline)
    end)
  end,
})

-- stylua: ignore start
map("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "Toggle Pin" })
map("n", "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", { desc = "Delete Non-Pinned Buffers" })
map("n", "<leader>br", "<Cmd>BufferLineCloseRight<CR>", { desc = "Delete Buffers to the Right" })
map("n", "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "Delete Buffers to the Left" })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
map("n", "[B", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer prev" })
map("n", "]B", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer next" })
map("n", "<leader>bj", "<cmd>BufferLinePick<cr>", { desc = "Pick Buffer" })
-- stylua: ignore end
