local wezterm = require("wezterm")

local custom = wezterm.color.get_builtin_schemes()["Solarized Dark - Patched"]
custom.background = "#00141A"
custom.foreground = "#FFF"
custom.tab_bar = {
  background = "#00141A",
  active_tab = {
    bg_color = "#063642",
    fg_color = "#FFF",
  },
  inactive_tab = {
    bg_color = "#00141A",
    fg_color = "#FFF",
  },
  new_tab = {
    bg_color = "#002B36",
    fg_color = "#EEE8D5",
  },
}

return custom
