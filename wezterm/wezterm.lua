-- Pull in the wezterm API
local wezterm = require("wezterm")

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback({ "mononoki", "Noto Color Emoji" })

config.freetype_load_flags = "NO_HINTING"

config.font_size = 14

config.color_scheme = "duskfox"

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

tabline.setup({
	options = {
		icons_enabled = true,
		tabs_enabled = true,
		theme = "duskfox",
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

for i = 1, 8 do
	-- CTRL+ALT + number to move to that position
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL|ALT",
		action = wezterm.action.MoveTab(i - 1),
	})
end

return config
