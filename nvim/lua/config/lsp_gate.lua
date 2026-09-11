-- LSP is off by default. mason-lspconfig auto-enables installed servers
-- synchronously the moment nvim-lspconfig loads (on BufReadPre/BufNewFile
-- for the very first buffer), before any VeryLazy-timed hook can react.
-- Gating vim.lsp.enable itself (registered here from init.lua, before
-- lazy.nvim and therefore any plugin loads) stops the client before it ever
-- spawns; stopping after LspAttach instead let servers start, error out
-- mid-handshake, and print noise before being killed.
local M = { enabled = false }
local pending = {}
local pending_start = {}

local real_enable = vim.lsp.enable
vim.lsp.enable = function(name, enable)
  if enable == false or M.enabled then
    return real_enable(name, enable)
  end
  for _, nm in ipairs(vim._ensure_list(name)) do
    pending[nm] = true
  end
end

-- rustaceanvim (and possibly other plugins) call vim.lsp.start() directly
-- instead of vim.lsp.enable(), bypassing the gate above entirely.
local real_start = vim.lsp.start
vim.lsp.start = function(config, opts)
  if M.enabled then
    return real_start(config, opts)
  end
  table.insert(pending_start, { config = config, opts = opts })
end

function M.toggle()
  M.enabled = not M.enabled
  if M.enabled then
    real_enable(vim.tbl_keys(pending))
    for _, req in ipairs(pending_start) do
      real_start(req.config, req.opts)
    end
    pending_start = {}
    vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
  else
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      vim.lsp.stop_client(client.id)
    end
  end
  vim.notify("LSP " .. (M.enabled and "enabled" or "disabled"))
end

return M
