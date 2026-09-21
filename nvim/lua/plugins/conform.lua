return {
  {
    "stevearc/conform.nvim",
    opts = function()
      ---@type conform.setupOpts
      local opts = {
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
          python = { "ruff_format", stop_after_first = true, lsp_format = "fallback" },
          ocaml = { "ocamlformat" },
          rust = { "rustfmt" },
          typst = { "prettypst" },
          haskell = { "ormolu" },
        },
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          injected = { options = { ignore_errors = true } },
          ruff_format = { require_cwd = true },
          ["clang-format"] = {
            command = "/opt/homebrew/bin/clang-format",
          },
        },
      }
      return opts
    end,
  },
}
