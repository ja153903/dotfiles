local function buffer_has_toc(_, ctx)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
    if line:find("<!%-%- toc %-%->") then
      return true
    end
  end
  return false
end

local function buffer_has_markdownlint_diagnostics(_, ctx)
  return vim.iter(vim.diagnostic.get(ctx.buf)):any(function(d)
    return d.source == "markdownlint"
  end)
end

local markdown = { "prettier", "markdownlint-cli2", "markdown-toc" }

require("conform").setup({
  default_format_opts = { timeout_ms = 3000, async = false, quiet = false, lsp_format = "fallback" },
  -- toggled with <leader>uf (global) / <leader>uF (buffer)
  format_on_save = function(buf)
    local enabled = vim.b[buf].autoformat
    if enabled == nil then
      enabled = vim.g.autoformat
    end
    return enabled and {} or nil
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    fish = { "fish_indent" },
    sh = { "shfmt" },
    cpp = { "clang-format" },
    c = { "clang-format" },
    typescript = { "oxfmt" },
    typescriptreact = { "oxfmt" },
    javascript = { "oxfmt" },
    javascriptreact = { "oxfmt" },
    json = { "oxfmt" },
    jsonc = { "oxfmt" },
    python = { "ruff_format", stop_after_first = true, lsp_format = "fallback" },
    ocaml = { "ocamlformat" },
    rust = { "rustfmt" },
    typst = { "prettypst" },
    haskell = { "ormolu" },
    markdown = markdown,
    ["markdown.mdx"] = markdown,
  },
  ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
  formatters = {
    injected = { options = { ignore_errors = true } },
    ruff_format = { require_cwd = true },
    ["clang-format"] = { command = "/opt/homebrew/bin/clang-format" },
    ["markdown-toc"] = { condition = buffer_has_toc },
    ["markdownlint-cli2"] = { condition = buffer_has_markdownlint_diagnostics },
  },
})

vim.keymap.set({ "n", "x" }, "<leader>cf", function()
  require("conform").format()
end, { desc = "Format" })
vim.keymap.set({ "n", "x" }, "<leader>cF", function()
  require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
end, { desc = "Format Injected Langs" })
