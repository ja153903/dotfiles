return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
    },
    init = function()
      -- Install the conform formatter on VeryLazy
      LazyVim.on_very_lazy(function()
        LazyVim.format.register({
          name = "conform.nvim",
          priority = 100,
          primary = true,
          format = function(buf)
            require("conform").format({ bufnr = buf })
          end,
          sources = function(buf)
            local ret = require("conform").list_formatters(buf)
            ---@param v conform.FormatterInfo
            return vim.tbl_map(function(v)
              return v.name
            end, ret)
          end,
        })
      end)
    end,
    opts = function()
      local plugin = require("lazy.core.config").plugins["conform.nvim"]
      ---@type conform.setupOpts
      local opts = {
        default_format_opts = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_format = "fallback", -- not recommended to change
        },
        formatters_by_ft = {
          lua = { "stylua" },
          fish = { "fish_indent" },
          sh = { "shfmt" },
          cpp = { "clang-format" },
          c = { "clang-format" },
          typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
          javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
          javascriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
          python = { "ruff_format", stop_after_first = true, lsp_format = "fallback" },
          ocaml = { "ocamlformat" },
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
