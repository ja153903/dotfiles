-- Ported from LazyVim's default autocmds, then personal user commands.
local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- reload files changed outside nvim
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.hl_op()
  end,
})

-- equalize splits when the terminal resizes
autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- restore last cursor position
autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(ev)
    local buf = ev.buf
    if vim.bo[buf].filetype == "gitcommit" or vim.b[buf].last_loc_restored then
      return
    end
    vim.b[buf].last_loc_restored = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close utility windows with q
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "checkhealth", "gitsigns-blame", "grug-far", "help", "lspinfo", "notify", "qf", "startuptime" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
      end, { buffer = ev.buf, silent = true, desc = "Quit buffer" })
    end)
  end,
})

autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = "man",
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
  end,
})

autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

autocmd("FileType", {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- create missing parent dirs on save
autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(ev)
    if ev.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_user_command("CopyRelPath", function()
  local filepath = vim.fn.expand("%:p")
  local cwd = vim.fn.getcwd()
  local relative_path = vim.fn.fnamemodify(filepath, ":s?" .. cwd .. "/??")
  vim.fn.setreg("+", relative_path)
  print("Copied to clipboard: " .. relative_path)
end, {})
vim.api.nvim_create_user_command("CopyAbsPath", "call setreg('+', expand('%:p'))", {})

vim.api.nvim_create_user_command("CopyAiPath", function()
  local rel_path = vim.fn.expand("%:.")
  local result = "@" .. rel_path
  vim.fn.setreg("+", result)
  print("Copied to clipboard: " .. result)
end, {})

-- NOTE: this user command takes the class the PDF is for as an argument
vim.api.nvim_create_user_command("Export", function(opts)
  local class = opts.fargs[1]
  local DST_DIR = vim.env.PERSONAL_SITE_ASSET_PATH
  local filepath = vim.fn.expand("%:p")

  local parts = vim.split(filepath, "/", { plain = true })
  local last3 = vim.list_slice(parts, #parts - 2)

  local resulting_filepath = DST_DIR .. last3[1] .. "/" .. class .. "/" .. last3[2] .. "/" .. last3[3]

  -- run os.execute instead
  vim.fn.system({ "cp", filepath, resulting_filepath })
end, { nargs = "*" })
