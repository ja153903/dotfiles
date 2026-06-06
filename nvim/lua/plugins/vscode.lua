if not vim.g.vscode then
  return {}
end

local vscode = require("vscode")

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>sw",
        function()
          vscode.call("references-view.findReferences")
        end,
        desc = "Find all references",
        mode = { "n", "x" },
      },
      {
        "<leader>sg",
        function()
          vscode.call("workbench.action.findInFiles")
        end,
        desc = "Grep (find in files)",
      },
      {
        "<leader>ff",
        function()
          vscode.call("workbench.action.quickOpen")
        end,
        desc = "Find files",
      },
    },
  },
}
