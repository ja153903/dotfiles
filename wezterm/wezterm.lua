-- Pull in the wezterm API
local wezterm = require("wezterm")

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

config.font = wezterm.font_with_fallback({ "Monaspace Krypton", "MonaspiceKr Nerd Font", "Noto Color Emoji" })

-- or, changing the font size and color scheme.
config.font_size = 12
config.color_scheme = "Vs Code Dark+ (Gogh)"

config.leader = { key = "e", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "n",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
}

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32

tabline.setup({
	options = {
		icons_enabled = true,
		theme = "GruvboxDark",
		tabs_enabled = true,
		theme_overrides = {},
		section_separators = "",
		component_separators = "",
		tab_separators = "",
	},
	sections = {
		tabline_a = {},
		tabline_b = {},
		tabline_c = {},
		tab_active = {
			"index",
			{ "cwd", padding = { left = 0, right = 1 } },
		},
		tab_inactive = { "index", { "cwd", padding = { left = 0, right = 1 } } },
		tabline_x = { "ram", "cpu" },
		tabline_y = { "battery" },
		tabline_z = { "datetime" },
	},
	extensions = {},
})

-- Finally, return the configuration to wezterm:
return config
