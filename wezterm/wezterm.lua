local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

config.font = wezterm.font("MonoLisa")

-- Treat Option as Alt (mirrors ghostty's macos-option-as-alt = true)
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.keys = {
	-- Navigate panes (alt+hjkl)
	{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },

	-- shift+enter sends a literal newline
	{ key = "Enter", mods = "SHIFT", action = act.SendString("\n") },

	-- alt+p: enter split mode
	{ key = "p", mods = "ALT", action = act.ActivateKeyTable({ name = "split_mode", one_shot = true }) },

	-- alt+r: enter resize mode
	{ key = "r", mods = "ALT", action = act.ActivateKeyTable({ name = "resize_mode", one_shot = true }) },

	-- alt+t: enter tab mode
	{ key = "t", mods = "ALT", action = act.ActivateKeyTable({ name = "tab_mode", one_shot = true }) },
}

config.key_tables = {
	-- alt+p > {n,N,d,D}: new splits
	split_mode = {
		{ key = "n", action = act.SplitPane({ direction = "Right" }) },
		{ key = "N", action = act.SplitPane({ direction = "Left" }) },
		{ key = "d", action = act.SplitPane({ direction = "Down" }) },
		{ key = "D", action = act.SplitPane({ direction = "Up" }) },
	},
	-- alt+r > {L,H,J,K}: resize panes
	resize_mode = {
		{ key = "L", action = act.AdjustPaneSize({ "Right", 5 }) },
		{ key = "H", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "J", action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "K", action = act.AdjustPaneSize({ "Up", 5 }) },
	},
	-- alt+t > {l,h}: cycle tabs
	tab_mode = {
		{ key = "l", action = act.ActivateTabRelative(1) },
		{ key = "h", action = act.ActivateTabRelative(-1) },
	},
}

return config
