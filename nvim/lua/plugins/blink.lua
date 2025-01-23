return {
  {
    "saghen/blink.cmp",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      completion = {
        accept = {
          -- experimental auto-brackets support
          auto_brackets = {
            enabled = false,
          },
        },
      },
    },
  },
}
