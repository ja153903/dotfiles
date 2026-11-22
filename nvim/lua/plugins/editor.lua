require("plugins.editing")

local map = vim.keymap.set

-- ponytail: plain mini.pairs; LazyVim's wrapper also skipped pairing inside strings / before word chars.
require("mini.pairs").setup({ modes = { insert = true, command = true, terminal = false } })
require("ts-comments").setup({})
require("persistence").setup({})
require("inc_rename").setup({})
require("todo-comments").setup({})
require("grug-far").setup({ headerMaxWidth = 80 })
require("trouble").setup({ modes = { lsp = { win = { position = "right" } } } })

-- ponytail: hex colors only; LazyVim's Tailwind class highlighter was dropped with the tailwind extra.
local hi = require("mini.hipatterns")
hi.setup({
  highlighters = {
    hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
    shorthand = {
      pattern = "()#%x%x%x()%f[^%x%w]",
      group = function(_, _, data)
        local m = data.full_match
        if m == "#add" then
          return
        end
        local r, g, b = m:sub(2, 2), m:sub(3, 3), m:sub(4, 4)
        return MiniHipatterns.compute_hex_color_group("#" .. r .. r .. g .. g .. b .. b, "bg")
      end,
      extmark_opts = { priority = 2000 },
    },
  },
})

require("gitsigns").setup({
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "▎" },
    untracked = { text = "▎" },
  },
  signs_staged = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "▎" },
  },
  on_attach = function(buffer)
    local gs = package.loaded.gitsigns
    local function bmap(mode, l, r, desc)
      map(mode, l, r, { buffer = buffer, desc = desc, silent = true })
    end
    local function nav(diffkey, dir)
      return function()
        if vim.wo.diff then
          vim.cmd.normal({ diffkey, bang = true })
        else
          gs.nav_hunk(dir)
        end
      end
    end
    bmap("n", "]h", nav("]c", "next"), "Next Hunk")
    bmap("n", "[h", nav("[c", "prev"), "Prev Hunk")
    bmap("n", "]H", function()
      gs.nav_hunk("last")
    end, "Last Hunk")
    bmap("n", "[H", function()
      gs.nav_hunk("first")
    end, "First Hunk")
    bmap({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
    bmap({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
    bmap("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
    bmap("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
    bmap("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
    bmap("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
    bmap("n", "<leader>ghb", function()
      gs.blame_line({ full = true })
    end, "Blame Line")
    bmap("n", "<leader>ghB", function()
      gs.blame()
    end, "Blame Buffer")
    bmap("n", "<leader>ghd", gs.diffthis, "Diff This")
    bmap("n", "<leader>ghD", function()
      gs.diffthis("~")
    end, "Diff This ~")
    bmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
  end,
})
Snacks.toggle({
  name = "Git Signs",
  get = function()
    return require("gitsigns.config").config.signcolumn
  end,
  set = function(state)
    require("gitsigns").toggle_signs(state)
  end,
}):map("<leader>uG")

-- trouble / quickfix
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
map("n", "<leader>cs", "<cmd>Trouble symbols toggle<cr>", { desc = "Symbols (Trouble)" })
map("n", "<leader>cS", "<cmd>Trouble lsp toggle<cr>", { desc = "LSP references/definitions/... (Trouble)" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
local function trouble_or_qf(dir)
  return function()
    local trouble = require("trouble")
    if trouble.is_open() then
      trouble[dir]({ skip_groups = true, jump = true })
    else
      local ok, err = pcall(vim.cmd[dir == "next" and "cnext" or "cprev"])
      if not ok then
        vim.notify(err, vim.log.levels.ERROR)
      end
    end
  end
end
map("n", "[q", trouble_or_qf("prev"), { desc = "Previous Trouble/Quickfix Item" })
map("n", "]q", trouble_or_qf("next"), { desc = "Next Trouble/Quickfix Item" })

-- todo-comments
map("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next Todo Comment" })
map("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous Todo Comment" })
map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Todo (Trouble)" })
map(
  "n",
  "<leader>xT",
  "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
  { desc = "Todo/Fix/Fixme (Trouble)" }
)
map("n", "<leader>st", function()
  Snacks.picker.todo_comments()
end, { desc = "Todo" })
map("n", "<leader>sT", function()
  Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
end, { desc = "Todo/Fix/Fixme" })

-- grug-far
map({ "n", "x" }, "<leader>sr", function()
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  require("grug-far").open({
    transient = true,
    prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
  })
end, { desc = "Search and Replace" })

-- persistence
map("n", "<leader>qs", function()
  require("persistence").load()
end, { desc = "Restore Session" })
map("n", "<leader>qS", function()
  require("persistence").select()
end, { desc = "Select Session" })
map("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, { desc = "Restore Last Session" })
map("n", "<leader>qd", function()
  require("persistence").stop()
end, { desc = "Don't Save Current Session" })

-- harpoon
local harpoon = require("harpoon")
harpoon:setup({
  menu = { width = vim.api.nvim_win_get_width(0) - 4 },
  settings = { save_on_toggle = true },
})
map("n", "<leader>H", function()
  harpoon:list():add()
end, { desc = "Harpoon File" })
map("n", "<leader>h", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon Quick Menu" })
for i = 1, 9 do
  map("n", "<leader>" .. i, function()
    harpoon:list():select(i)
  end, { desc = "Harpoon to File " .. i })
end

-- which-key
local wk = require("which-key")
wk.setup({
  preset = "helix",
  spec = {
    {
      mode = { "n", "x" },
      { "<leader><tab>", group = "tabs" },
      { "<leader>c", group = "code" },
      { "<leader>dp", group = "profiler" },
      { "<leader>f", group = "file/find" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "hunks" },
      { "<leader>q", group = "quit/session" },
      { "<leader>s", group = "search" },
      { "<leader>sn", group = "noice" },
      { "<leader>u", group = "ui" },
      { "<leader>x", group = "diagnostics/quickfix" },
      { "[", group = "prev" },
      { "]", group = "next" },
      { "g", group = "goto" },
      { "gs", group = "surround" },
      { "z", group = "fold" },
      {
        "<leader>b",
        group = "buffer",
        expand = function()
          return require("which-key.extras").expand.buf()
        end,
      },
      {
        "<leader>w",
        group = "windows",
        proxy = "<c-w>",
        expand = function()
          return require("which-key.extras").expand.win()
        end,
      },
      { "gx", desc = "Open with system app" },
    },
  },
})
map("n", "<leader>?", function()
  wk.show({ global = false })
end, { desc = "Buffer Keymaps (which-key)" })
map("n", "<c-w><space>", function()
  wk.show({ keys = "<c-w>", loop = true })
end, { desc = "Window Hydra Mode (which-key)" })
