-- Text-editing plugins; also loaded under vscode-neovim.
local map = vim.keymap.set

-- mini.ai: extra a/i textobjects
local ai = require("mini.ai")
ai.setup({
  n_lines = 500,
  custom_textobjects = {
    o = ai.gen_spec.treesitter({
      a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    }),
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
    d = { "%f[%d]%d+" },
    e = {
      { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
      "^().*()$",
    },
    -- whole buffer; `ig` trims leading/trailing blank lines
    g = function(ai_type)
      local first, last = 1, vim.fn.line("$")
      if ai_type == "i" then
        first, last = vim.fn.nextnonblank(first), vim.fn.prevnonblank(last)
        if first == 0 then
          return { from = { line = 1, col = 1 } }
        end
      end
      return { from = { line = first, col = 1 }, to = { line = last, col = math.max(#vim.fn.getline(last), 1) } }
    end,
    u = ai.gen_spec.function_call(),
    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
  },
})

-- mini.surround on gs*
require("mini.surround").setup({
  mappings = {
    add = "gsa",
    delete = "gsd",
    find = "gsf",
    find_left = "gsF",
    highlight = "gsh",
    replace = "gsr",
    update_n_lines = "gsn",
  },
})

-- dial: smarter <C-a>/<C-x>
local augend = require("dial.augend")
local function cycle(elements, word)
  return augend.constant.new({ elements = elements, word = word or false, cyclic = true })
end
local default = {
  augend.integer.alias.decimal,
  augend.integer.alias.decimal_int,
  augend.integer.alias.hex,
  augend.date.alias["%Y/%m/%d"],
  augend.constant.alias.en_weekday,
  augend.constant.alias.en_weekday_full,
  cycle({ "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth" }),
  cycle({
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  }, true),
  augend.constant.alias.bool,
  augend.constant.alias.Bool,
  cycle({ "&&", "||" }),
}
local hexcolors = { augend.hexcolor.new({ case = "lower" }), augend.hexcolor.new({ case = "upper" }) }
local groups = {
  default = default,
  typescript = { augend.constant.new({ elements = { "let", "const" } }) },
  css = hexcolors,
  markdown = { cycle({ "[ ]", "[x]" }), augend.misc.alias.markdown_header },
  json = { augend.semver.alias.semver },
  lua = { cycle({ "and", "or" }, true) },
  python = { augend.constant.new({ elements = { "and", "or" } }) },
}
for name, group in pairs(groups) do
  if name ~= "default" then
    vim.list_extend(group, default)
  end
end
require("dial.config").augends:register_group(groups)

local dial_group_by_ft = {
  css = "css",
  sass = "css",
  scss = "css",
  javascript = "typescript",
  javascriptreact = "typescript",
  typescript = "typescript",
  typescriptreact = "typescript",
  json = "json",
  lua = "lua",
  markdown = "markdown",
  python = "python",
}
local function dial(increment, g)
  return function()
    local mode = vim.fn.mode(true)
    local visual = mode == "v" or mode == "V" or mode == "\22"
    local fn = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (visual and "visual" or "normal")
    return require("dial.map")[fn](dial_group_by_ft[vim.bo.filetype] or "default")
  end
end
map({ "n", "v" }, "<C-a>", dial(true), { expr = true, desc = "Increment" })
map({ "n", "v" }, "<C-x>", dial(false), { expr = true, desc = "Decrement" })
map({ "n", "x" }, "g<C-a>", dial(true, true), { expr = true, desc = "Increment" })
map({ "n", "x" }, "g<C-x>", dial(false, true), { expr = true, desc = "Decrement" })

-- yanky: yank ring
require("yanky").setup({
  system_clipboard = { sync_with_ring = not vim.env.SSH_CONNECTION },
  highlight = { timer = 150 },
})
map({ "n", "x" }, "<leader>p", function()
  if package.loaded.snacks then
    Snacks.picker.yanky()
  else
    vim.cmd("YankyRingHistory")
  end
end, { desc = "Open Yank History" })
for lhs, spec in pairs({
  y = { "YankyYank", { "n", "x" }, "Yank Text" },
  p = { "YankyPutAfter", { "n", "x" }, "Put Text After Cursor" },
  P = { "YankyPutBefore", { "n", "x" }, "Put Text Before Cursor" },
  gp = { "YankyGPutAfter", { "n", "x" }, "Put Text After Selection" },
  gP = { "YankyGPutBefore", { "n", "x" }, "Put Text Before Selection" },
  ["[y"] = { "YankyCycleForward", "n", "Cycle Forward Through Yank History" },
  ["]y"] = { "YankyCycleBackward", "n", "Cycle Backward Through Yank History" },
  ["]p"] = { "YankyPutIndentAfterLinewise", "n", "Put Indented After Cursor (Linewise)" },
  ["[p"] = { "YankyPutIndentBeforeLinewise", "n", "Put Indented Before Cursor (Linewise)" },
  ["]P"] = { "YankyPutIndentAfterLinewise", "n", "Put Indented After Cursor (Linewise)" },
  ["[P"] = { "YankyPutIndentBeforeLinewise", "n", "Put Indented Before Cursor (Linewise)" },
  [">p"] = { "YankyPutIndentAfterShiftRight", "n", "Put and Indent Right" },
  ["<p"] = { "YankyPutIndentAfterShiftLeft", "n", "Put and Indent Left" },
  [">P"] = { "YankyPutIndentBeforeShiftRight", "n", "Put Before and Indent Right" },
  ["<P"] = { "YankyPutIndentBeforeShiftLeft", "n", "Put Before and Indent Left" },
  ["=p"] = { "YankyPutAfterFilter", "n", "Put After Applying a Filter" },
  ["=P"] = { "YankyPutBeforeFilter", "n", "Put Before Applying a Filter" },
}) do
  map(spec[2], lhs, "<Plug>(" .. spec[1] .. ")", { desc = spec[3] })
end
