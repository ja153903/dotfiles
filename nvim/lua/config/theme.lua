local M = {}
local mode_file = vim.fn.stdpath("config") .. "/theme-mode"
local watcher
local current

function M.mode()
  local file = io.open(mode_file, "r")
  if not file then
    return "dark"
  end
  local mode = file:read("*l")
  file:close()
  return mode == "light" and "light" or "dark"
end

function M.apply()
  local mode = M.mode()
  if mode == current then
    return
  end
  vim.o.background = mode
  require("onedark").setup({ style = mode })
  require("onedark").load()
  current = mode
end

function M.setup()
  M.apply()
  if watcher then
    return
  end
  watcher = assert(vim.uv.new_fs_event())
  local started, error = watcher:start(vim.fn.resolve(vim.fn.stdpath("config")), {}, function(error, filename)
    if error then
      vim.schedule(function()
        vim.notify("Theme watcher failed: " .. error, vim.log.levels.ERROR)
      end)
    elseif filename == "theme-mode" then
      vim.schedule(M.apply)
    end
  end)
  assert(started, error)
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      watcher:stop()
      watcher:close()
    end,
  })
end

return M
