local opts = {
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        any = { { find = "%d+L, %d+B" }, { find = "; after #%d+" }, { find = "; before #%d+" } },
      },
      view = "mini",
    },
    { filter = { event = "notify", find = "No information available" }, opts = { skip = true } },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = true,
  },
}
-- noice.setup() defers attaching to VimEnter, so nvim paints once, then noice
-- takes over the message area and the whole screen repaints (the startup flash).
-- Attach now, before the first paint, by doing what setup's deferred load() does.
-- ponytail: mirrors noice/init.lua's private load(); if noice changes it, revert to require("noice").setup(opts).
require("noice.config").setup(opts)
require("noice.commands").setup()
require("noice.message.router").setup()
require("noice").enable()

local map = vim.keymap.set
-- stylua: ignore start
map("c", "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, { desc = "Redirect Cmdline" })
map("n", "<leader>snl", function() require("noice").cmd("last") end, { desc = "Noice Last Message" })
map("n", "<leader>snh", function() require("noice").cmd("history") end, { desc = "Noice History" })
map("n", "<leader>sna", function() require("noice").cmd("all") end, { desc = "Noice All" })
map("n", "<leader>snd", function() require("noice").cmd("dismiss") end, { desc = "Dismiss All" })
map("n", "<leader>snt", function() require("noice").cmd("pick") end, { desc = "Noice Picker" })
map({ "i", "n", "s" }, "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, { silent = true, expr = true, desc = "Scroll Forward" })
map({ "i", "n", "s" }, "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, { silent = true, expr = true, desc = "Scroll Backward" })
-- stylua: ignore end
