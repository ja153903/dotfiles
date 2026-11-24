-- mason puts its bin/ on PATH; servers themselves come from nvim-lspconfig's lsp/*.lua
require("mason").setup()
require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    { path = "snacks.nvim", words = { "Snacks" } },
  },
})

-- mason packages to keep installed on a fresh machine
local tools = {
  "basedpyright",
  "json-lsp",
  "lua-language-server",
  "markdown-toc",
  "markdownlint-cli2",
  "marksman",
  "oxfmt",
  "oxlint",
  "prettier",
  "prettypst",
  "ruff",
  "shfmt",
  "stylua",
  "taplo",
  "tinymist",
  "tsc",
  "yaml-language-server",
}
-- after the UI is up: the registry check costs ~30ms and nothing at startup needs it
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    local registry = require("mason-registry")
    registry.refresh(function()
      for _, name in ipairs(tools) do
        local ok, pkg = pcall(registry.get_package, name)
        if not ok then
          vim.notify("mason: unknown package " .. name, vim.log.levels.WARN)
        elseif not pkg:is_installed() then
          pkg:install()
        end
      end
    end)
  end,
})

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

local servers = {
  ["*"] = {
    capabilities = { workspace = { fileOperations = { didRename = true, willRename = true } } },
  },
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        codeLens = { enable = true },
        completion = { callSnippet = "Replace" },
        doc = { privateName = { "^_" } },
        hint = {
          enable = true,
          setType = false,
          paramType = true,
          paramName = "Disable",
          semicolon = "Disable",
          arrayIndex = "Disable",
        },
      },
    },
  },
  oxlint = {
    root_dir = function(bufnr, on_dir)
      local markers = { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" }
      local git = vim.fs.root(bufnr, ".git")
      local root = git and vim.fs.root(git, markers) or vim.fs.root(bufnr, markers)
      if root then
        on_dir(root)
      end
    end,
    settings = { fixKind = "all" },
  },
  -- push diagnostics: pull mode re-runs a full analysis on every attach/refresh
  basedpyright = { init_options = { disablePullDiagnostics = true } },
  ruff = {
    on_attach = function(client)
      client.server_capabilities.hoverProvider = false -- basedpyright owns hover
    end,
  },
  jsonls = {
    before_init = function(_, config)
      config.settings.json.schemas =
        vim.list_extend(config.settings.json.schemas or {}, require("schemastore").json.schemas())
    end,
    settings = { json = { format = { enable = true }, validate = { enable = true } } },
  },
  yamlls = {
    capabilities = { textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } } },
    before_init = function(_, config)
      config.settings.yaml.schemas =
        vim.tbl_deep_extend("force", config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
    end,
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = {
        keyOrdering = false,
        format = { enable = true },
        validate = true,
        schemaStore = { enable = false, url = "" },
      },
    },
  },
  tsc = {},
  taplo = {},
  marksman = {},
  tinymist = { settings = { exportPdf = "onSave" } },
  ocamllsp = {
    root_markers = { { "dune-project", "dune-workspace" }, { "*.opam", "esy.json", "package.json" }, ".git" },
  },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  if name ~= "*" then
    vim.lsp.enable(name)
  end
end

local function code_action(kind)
  return function()
    vim.lsp.buf.code_action({ apply = true, context = { only = { kind }, diagnostics = {} } })
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_keys", { clear = true }),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local function map(mode, lhs, rhs, desc, method, extra)
      if method and not client:supports_method(method, ev.buf) then
        return
      end
      vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = ev.buf, desc = desc }, extra or {}))
    end
    local P = Snacks.picker
    -- stylua: ignore start
    map("n", "<leader>cl", function() P.lsp_config() end, "Lsp Info")
    map("n", "gd", function() P.lsp_definitions() end, "Goto Definition", "textDocument/definition")
    map("n", "gr", function() P.lsp_references() end, "References", nil, { nowait = true })
    map("n", "gI", function() P.lsp_implementations() end, "Goto Implementation")
    map("n", "gy", function() P.lsp_type_definitions() end, "Goto T[y]pe Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
    map("n", "K", function() return vim.lsp.buf.hover() end, "Hover")
    map("n", "gK", function() return vim.lsp.buf.signature_help() end, "Signature Help", "textDocument/signatureHelp")
    map("i", "<c-k>", function() return vim.lsp.buf.signature_help() end, "Signature Help", "textDocument/signatureHelp")
    map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action", "textDocument/codeAction")
    map("n", "<leader>cA", code_action("source"), "Source Action", "textDocument/codeAction")
    map("n", "<leader>co", code_action("source.organizeImports"), "Organize Imports", "textDocument/codeAction")
    map({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, "Run Codelens", "textDocument/codeLens")
    map("n", "<leader>cR", function() Snacks.rename.rename_file() end, "Rename File", "workspace/willRenameFiles")
    map("n", "<leader>cr", function() return ":IncRename " .. vim.fn.expand("<cword>") end, "Rename (inc-rename.nvim)", "textDocument/rename", { expr = true })
    map("n", "<leader>ss", function() P.lsp_symbols() end, "LSP Symbols", "textDocument/documentSymbol")
    map("n", "<leader>sS", function() P.lsp_workspace_symbols() end, "LSP Workspace Symbols", "workspace/symbol")
    map("n", "gai", function() P.lsp_incoming_calls() end, "C[a]lls Incoming", "callHierarchy/incomingCalls")
    map("n", "gao", function() P.lsp_outgoing_calls() end, "C[a]lls Outgoing", "callHierarchy/outgoingCalls")
    map("n", "]]", function() Snacks.words.jump(vim.v.count1) end, "Next Reference", "textDocument/documentHighlight")
    map("n", "[[", function() Snacks.words.jump(-vim.v.count1) end, "Prev Reference", "textDocument/documentHighlight")
    map("n", "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, "Next Reference", "textDocument/documentHighlight")
    map("n", "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, "Prev Reference", "textDocument/documentHighlight")
    -- stylua: ignore end
  end,
})

require("typst-preview").setup({})
