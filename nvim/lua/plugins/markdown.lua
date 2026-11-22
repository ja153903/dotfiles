vim.filetype.add({ extension = { mdx = "markdown.mdx" } })

-- Upstream always shows the raw line when the cursor is on a wrapped table row
-- (drawn as virtual lines). Let anti_conceal decide instead, so normal mode stays rendered.
-- ponytail: patches a private render-markdown internal; if it disappears we fall back to upstream behaviour.
local ok, ui = pcall(require, "render-markdown.core.ui")
local updater = ok and ui.updater
if updater and type(updater.hide) == "function" then
  local hide = updater.hide
  updater.hide = function(self, extmark, range)
    local mark = extmark:get()
    local replace = mark.replace
    if not replace then
      return hide(self, extmark, range)
    end
    mark.replace = nil
    local hidden = hide(self, extmark, range)
    mark.replace = replace
    return hidden
  end
else
  vim.notify(
    "render-markdown internals changed; wrapped table rows will show raw under the cursor",
    vim.log.levels.WARN
  )
end

require("render-markdown").setup({
  code = { sign = false, width = "block", right_pad = 1 },
  heading = { sign = false, icons = {} },
  checkbox = { enabled = false },
  -- Render in every mode; the cursor line shows raw markdown only in insert mode.
  render_modes = true,
  anti_conceal = { disabled_modes = { "n", "c", "t" } },
  win_options = { concealcursor = { rendered = "nc" } },
})
Snacks.toggle({
  name = "Render Markdown",
  get = require("render-markdown").get,
  set = require("render-markdown").set,
}):map("<leader>um")
