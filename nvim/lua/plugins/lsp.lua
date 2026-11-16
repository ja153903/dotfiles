return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- upstream's `tsc` config probes for a `tsc` binary before `tsgo`, and
        -- picks up classic TypeScript (which has no `--lsp`) instead. Only ever
        -- look for tsgo.
        tsgo = {
          cmd = function(dispatchers, config)
            local cmd = "tsgo"
            if (config or {}).root_dir then
              local local_cmd = vim.fs.joinpath(config.root_dir, "node_modules/.bin", "tsgo")
              if vim.fn.executable(local_cmd) == 1 then
                cmd = local_cmd
              end
            end
            return vim.lsp.rpc.start({ cmd, "--lsp", "--stdio" }, dispatchers)
          end,
        },
        -- mason has ty installed; keep it from auto-enabling alongside basedpyright
        ty = { enabled = false },
        -- Neovim re-pulls diagnostics on every attach/refresh and each pull kicks
        -- off a full analysis pass (+ progress popup). Push mode analyzes once.
        basedpyright = {
          -- read from initializationOptions only (not settings)
          init_options = { disablePullDiagnostics = true },
        },
        tinymist = {
          settings = {
            exportPdf = "onSave",
          },
        },
      },
      inlay_hints = {
        enabled = false,
      },
    },
  },
  {
    "chomosuke/typst-preview.nvim",
    lazy = false, -- or ft = 'typst'
    version = "1.*",
    opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  },
}
