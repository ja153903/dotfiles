local root = require("config.root")

-- In floating terminals pass <C-hjkl> through; in split terminals move windows.
local function term_nav(dir)
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

require("snacks").setup({
  animate = { enabled = true },
  bigfile = { enabled = true },
  dashboard = { enabled = false },
  explorer = { enabled = true },
  indent = { enabled = false },
  input = { enabled = true },
  notifier = { enabled = true },
  picker = {
    enabled = true,
    actions = {
      trouble_open = function(...)
        return require("trouble.sources.snacks").actions.trouble_open.action(...)
      end,
    },
    win = { input = { keys = { ["<a-t>"] = { "trouble_open", mode = { "n", "i" } } } } },
  },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
  terminal = {
    win = {
      keys = {
        nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
        nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
        nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
        nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
        hide_slash = { "<C-/>", "hide", desc = "Hide Terminal", mode = "t" },
        hide_underscore = { "<c-_>", "hide", desc = "which_key_ignore", mode = "t" },
      },
    },
  },
})

local map = vim.keymap.set
local P = Snacks.picker

-- picker source scoped to the project root (or cwd when root = false)
local function pick(source, opts)
  return function()
    P[source](vim.tbl_extend("force", { cwd = root() }, opts or {}))
  end
end

-- stylua: ignore start
map("n", "<leader>,", function() P.buffers() end, { desc = "Buffers" })
map("n", "<leader>/", pick("grep"), { desc = "Grep (Root Dir)" })
map("n", "<leader>:", function() P.command_history() end, { desc = "Command History" })
map("n", "<leader><space>", pick("files"), { desc = "Find Files (Root Dir)" })
map("n", "<leader>n", function() P.notifications() end, { desc = "Notification History" })
map("n", "<leader>un", function() Snacks.notifier.hide() end, { desc = "Dismiss All Notifications" })
-- find
map("n", "<leader>fb", function() P.buffers() end, { desc = "Buffers" })
map("n", "<leader>fB", function() P.buffers({ hidden = true, nofile = true }) end, { desc = "Buffers (all)" })
map("n", "<leader>fc", function() P.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Config File" })
map("n", "<leader>ff", pick("files"), { desc = "Find Files (Root Dir)" })
map("n", "<leader>fF", function() P.files() end, { desc = "Find Files (cwd)" })
map("n", "<leader>fg", function() P.git_files() end, { desc = "Find Files (git-files)" })
map("n", "<leader>fr", function() P.recent() end, { desc = "Recent" })
map("n", "<leader>fR", function() P.recent({ filter = { cwd = true } }) end, { desc = "Recent (cwd)" })
map("n", "<leader>fp", function() P.projects() end, { desc = "Projects" })
map("n", "<leader>fe", function() Snacks.explorer({ cwd = root() }) end, { desc = "Explorer Snacks (root dir)" })
map("n", "<leader>fE", function() Snacks.explorer() end, { desc = "Explorer Snacks (cwd)" })
map("n", "<leader>e", "<leader>fe", { desc = "Explorer Snacks (root dir)", remap = true })
map("n", "<leader>E", "<leader>fE", { desc = "Explorer Snacks (cwd)", remap = true })
map("n", "<leader>fT", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
map("n", "<leader>ft", function() Snacks.terminal(nil, { cwd = root() }) end, { desc = "Terminal (Root Dir)" })
map({ "n", "t" }, "<c-/>", function() Snacks.terminal.focus(nil, { cwd = root() }) end, { desc = "Terminal (Root Dir)" })
map({ "n", "t" }, "<c-_>", function() Snacks.terminal.focus(nil, { cwd = root() }) end, { desc = "which_key_ignore" })
-- git
map("n", "<leader>gd", function() P.git_diff() end, { desc = "Git Diff (hunks)" })
map("n", "<leader>gD", function() P.git_diff({ base = "origin", group = true }) end, { desc = "Git Diff (origin)" })
map("n", "<leader>gs", function() P.git_status() end, { desc = "Git Status" })
map("n", "<leader>gS", function() P.git_stash() end, { desc = "Git Stash" })
map("n", "<leader>gi", function() P.gh_issue() end, { desc = "GitHub Issues (open)" })
map("n", "<leader>gI", function() P.gh_issue({ state = "all" }) end, { desc = "GitHub Issues (all)" })
map("n", "<leader>gp", function() P.gh_pr() end, { desc = "GitHub Pull Requests (open)" })
map("n", "<leader>gP", function() P.gh_pr({ state = "all" }) end, { desc = "GitHub Pull Requests (all)" })
map("n", "<leader>gL", function() P.git_log() end, { desc = "Git Log (cwd)" })
map("n", "<leader>gb", function() P.git_log_line() end, { desc = "Git Blame Line" })
map("n", "<leader>gf", function() P.git_log_file() end, { desc = "Git Current File History" })
map("n", "<leader>gl", pick("git_log"), { desc = "Git Log" })
map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })
map({ "n", "x" }, "<leader>gY", function()
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = "Git Browse (copy)" })
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function() Snacks.lazygit({ cwd = root() }) end, { desc = "Lazygit (Root Dir)" })
  map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
end
-- grep
map("n", "<leader>sb", function() P.lines() end, { desc = "Buffer Lines" })
map("n", "<leader>sB", function() P.grep_buffers() end, { desc = "Grep Open Buffers" })
map("n", "<leader>sg", pick("grep"), { desc = "Grep (Root Dir)" })
map("n", "<leader>sG", function() P.grep() end, { desc = "Grep (cwd)" })
map({ "n", "x" }, "<leader>sw", pick("grep_word"), { desc = "Visual selection or word (Root Dir)" })
map({ "n", "x" }, "<leader>sW", function() P.grep_word() end, { desc = "Visual selection or word (cwd)" })
-- search
map("n", '<leader>s"', function() P.registers() end, { desc = "Registers" })
map("n", "<leader>s/", function() P.search_history() end, { desc = "Search History" })
map("n", "<leader>sa", function() P.autocmds() end, { desc = "Autocmds" })
map("n", "<leader>sc", function() P.command_history() end, { desc = "Command History" })
map("n", "<leader>sC", function() P.commands() end, { desc = "Commands" })
map("n", "<leader>sd", function() P.diagnostics() end, { desc = "Diagnostics" })
map("n", "<leader>sD", function() P.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
map("n", "<leader>sh", function() P.help() end, { desc = "Help Pages" })
map("n", "<leader>sH", function() P.highlights() end, { desc = "Highlights" })
map("n", "<leader>si", function() P.icons() end, { desc = "Icons" })
map("n", "<leader>sj", function() P.jumps() end, { desc = "Jumps" })
map("n", "<leader>sk", function() P.keymaps() end, { desc = "Keymaps" })
map("n", "<leader>sl", function() P.loclist() end, { desc = "Location List" })
map("n", "<leader>sM", function() P.man() end, { desc = "Man Pages" })
map("n", "<leader>sm", function() P.marks() end, { desc = "Marks" })
map("n", "<leader>sR", function() P.resume() end, { desc = "Resume" })
map("n", "<leader>sq", function() P.qflist() end, { desc = "Quickfix List" })
map("n", "<leader>su", function() P.undo() end, { desc = "Undotree" })
map("n", "<leader>uC", function() P.colorschemes() end, { desc = "Colorschemes" })
-- scratch / profiler
map("n", "<leader>.", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })
map("n", "<leader>dps", function() Snacks.profiler.scratch() end, { desc = "Profiler Scratch Buffer" })
map({ "n", "x" }, "<localleader>r", function() Snacks.debug.run() end, { desc = "Run Lua" })

-- toggles
local function autoformat_toggle(buffer)
  return Snacks.toggle({
    name = "Auto Format (" .. (buffer and "Buffer" or "Global") .. ")",
    get = function()
      if buffer and vim.b.autoformat ~= nil then return vim.b.autoformat end
      return vim.g.autoformat
    end,
    set = function(state)
      if buffer then vim.b.autoformat = state else vim.g.autoformat = state; vim.b.autoformat = nil end
    end,
  })
end
autoformat_toggle(false):map("<leader>uf")
autoformat_toggle(true):map("<leader>uF")
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")
Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.animate():map("<leader>ua")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.scroll():map("<leader>uS")
Snacks.toggle.profiler():map("<leader>dpp")
Snacks.toggle.profiler_highlights():map("<leader>dph")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
Snacks.toggle.zen():map("<leader>uz")
-- stylua: ignore end
