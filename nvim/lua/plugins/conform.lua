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
          typescript = { "biome", "prettier", "prettierd", stop_after_first = true },
          typescriptreact = { "biome", "prettier", "prettierd", stop_after_first = true },
          javascript = { "biome", "prettier", "prettierd", stop_after_first = true },
          javascriptreact = { "biome", "prettier", "prettierd", stop_after_first = true },
          python = { "ruff_format", stop_after_first = true, lsp_format = "fallback" },
          ocaml = { "ocamlformat" },
          rust = { "rustfmt" },
          typst = { "prettypst" },
        },
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          injected = { options = { ignore_errors = true } },
          biome = {
            require_cwd = true,
          },
          prettier = { require_cwd = true },
          prettierd = { require_cwd = true },
          ruff_format = { require_cwd = true },
        },
      }
      return opts
    end,
  },
}
