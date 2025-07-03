return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "enter",
    },
    sources = {
      min_keyword_length = function(ctx)
        return ctx.update_type == "manual" and 0 or 3
      end,
    },
  },
}
