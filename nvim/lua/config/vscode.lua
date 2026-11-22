-- Running inside vscode-neovim: only editing plugins, keys delegate to VS Code.
local vscode = require("vscode")

require("plugins.flash")
require("plugins.editing")

local function call(cmd)
  return function()
    vscode.call(cmd)
  end
end

vim.keymap.set({ "n", "x" }, "<leader>sw", call("references-view.findReferences"), { desc = "Find all references" })
vim.keymap.set("n", "<leader>sg", call("workbench.action.findInFiles"), { desc = "Grep (find in files)" })
vim.keymap.set("n", "<leader>ff", call("workbench.action.quickOpen"), { desc = "Find files" })
vim.keymap.set("n", "<leader>e", call("workbench.view.explorer"), { desc = "Open File Tree" })
