-- Project root for pickers/explorer/terminal: nearest git root, else cwd.
-- ponytail: LazyVim also asked attached LSP clients first; add that if git roots prove wrong.
return function()
  return vim.fs.root(0, ".git") or vim.uv.cwd()
end
