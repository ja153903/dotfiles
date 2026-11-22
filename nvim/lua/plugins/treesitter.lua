local TS = require("nvim-treesitter")

-- async; already-installed parsers are skipped
TS.install({
  "bash",
  "c",
  "diff",
  "fish",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "ocaml",
  "printf",
  "python",
  "query",
  "regex",
  "toml",
  "tsx",
  "typescript",
  "typst",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
})

local function has_query(lang, query)
  return lang and vim.treesitter.query.get(lang, query) ~= nil
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not (lang and vim.treesitter.language.add(lang)) then
      return
    end
    pcall(vim.treesitter.start, ev.buf)
    if has_query(lang, "indents") then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
    if has_query(lang, "folds") then
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
    if has_query(lang, "textobjects") then
      local move = require("nvim-treesitter-textobjects.move")
      for key, spec in pairs({
        ["]f"] = { "goto_next_start", "@function.outer", "Next Function Start" },
        ["]c"] = { "goto_next_start", "@class.outer", "Next Class Start" },
        ["]a"] = { "goto_next_start", "@parameter.inner", "Next Parameter Start" },
        ["]F"] = { "goto_next_end", "@function.outer", "Next Function End" },
        ["]C"] = { "goto_next_end", "@class.outer", "Next Class End" },
        ["]A"] = { "goto_next_end", "@parameter.inner", "Next Parameter End" },
        ["[f"] = { "goto_previous_start", "@function.outer", "Prev Function Start" },
        ["[c"] = { "goto_previous_start", "@class.outer", "Prev Class Start" },
        ["[a"] = { "goto_previous_start", "@parameter.inner", "Prev Parameter Start" },
        ["[F"] = { "goto_previous_end", "@function.outer", "Prev Function End" },
        ["[C"] = { "goto_previous_end", "@class.outer", "Prev Class End" },
        ["[A"] = { "goto_previous_end", "@parameter.inner", "Prev Parameter End" },
      }) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          -- keep ]c/[c as diff-hunk motions in diff mode
          if vim.wo.diff and key:find("[cC]") then
            return vim.cmd("normal! " .. key)
          end
          move[spec[1]](spec[2], "textobjects")
        end, { buffer = ev.buf, desc = spec[3], silent = true })
      end
    end
  end,
})

require("nvim-treesitter-textobjects").setup({ move = { set_jumps = true } })
require("nvim-ts-autotag").setup({})
