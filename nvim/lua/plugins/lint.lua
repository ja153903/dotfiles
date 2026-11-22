local lint = require("lint")

lint.linters_by_ft = {
  fish = { "fish" },
  markdown = { "markdownlint-cli2" },
}
lint.linters["markdownlint-cli2"].prepend_args = { "--config", vim.fn.stdpath("config") .. "/.markdownlint.yaml" }

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("user_lint", { clear = true }),
  callback = function()
    lint.try_lint()
  end,
})
