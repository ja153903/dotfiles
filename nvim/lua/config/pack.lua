local function gh(repo)
  return "https://github.com/" .. repo
end

-- Must exist before vim.pack.add so it also fires on first install.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

local editing = {
  gh("folke/flash.nvim"),
  gh("nvim-mini/mini.ai"),
  gh("nvim-mini/mini.surround"),
  gh("monaqa/dial.nvim"),
  gh("gbprod/yanky.nvim"),
}

if vim.g.vscode then
  vim.pack.add(editing)
  return
end

vim.pack.add(vim.list_extend(editing, {
  -- core / ui
  gh("folke/snacks.nvim"),
  { src = gh("embark-theme/vim"), name = "embark" },
  gh("craftzdog/solarized-osaka.nvim"),
  gh("nvim-mini/mini.icons"),
  gh("MunifTanjim/nui.nvim"),
  gh("folke/noice.nvim"),
  gh("akinsho/bufferline.nvim"),
  gh("folke/which-key.nvim"),

  -- editor
  gh("nvim-lua/plenary.nvim"),
  gh("nvim-mini/mini.pairs"),
  gh("nvim-mini/mini.hipatterns"),
  gh("folke/ts-comments.nvim"),
  gh("lewis6991/gitsigns.nvim"),
  gh("folke/trouble.nvim"),
  gh("folke/todo-comments.nvim"),
  gh("MagicDuck/grug-far.nvim"),
  gh("folke/persistence.nvim"),
  { src = gh("ThePrimeagen/harpoon"), version = "harpoon2" },
  gh("smjonas/inc-rename.nvim"),
  { src = gh("mikavilpas/yazi.nvim"), version = vim.version.range("*") },
  gh("esmuellert/codediff.nvim"),

  -- treesitter
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  { src = gh("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" },
  gh("windwp/nvim-ts-autotag"),

  -- completion / lsp / format / lint
  -- tagged releases ship the prebuilt fuzzy-matcher binary
  { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
  gh("folke/lazydev.nvim"),
  gh("mason-org/mason.nvim"),
  gh("neovim/nvim-lspconfig"),
  gh("b0o/SchemaStore.nvim"),
  gh("stevearc/conform.nvim"),
  gh("mfussenegger/nvim-lint"),

  -- languages
  gh("MeanderingProgrammer/render-markdown.nvim"),
  { src = gh("chomosuke/typst-preview.nvim"), version = vim.version.range("1.*") },
}))
