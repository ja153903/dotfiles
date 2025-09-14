if vim.env.VSCODE then
  vim.g.vscode = true
end

local function is_git_merge()
  return vim.env.GIT_MERGE_FILE ~= nil or vim.env.GIT_INDEX_FILE ~= nil or vim.fn.expand("%:t"):match("^MERGE_") ~= nil
end

if not is_git_merge() then
  require("config.lazy")
end
