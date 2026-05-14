local wezterm = require("wezterm")
local act = wezterm.action
local opacity = 1
local transparent_bg = "rgba(22, 24, 26, " .. opacity .. ")"
local config = wezterm.config_builder()

local scheme = wezterm.color.load_scheme(wezterm.config_dir .. "/colors/modus_vivendi.toml")

config.font = wezterm.font("MonoLisa")
config.color_scheme_dirs = { wezterm.config_dir .. "/colors" }
config.color_scheme = "Modus Vivendi"

-- Performance settings
config.max_fps = 144
config.animation_fps = 60
config.cursor_blink_rate = 250

-- Tab bar stuff
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.show_tab_index_in_tab_bar = false
config.use_fancy_tab_bar = false
config.colors = {
	tab_bar = {
		background = config.window_background_image and "rgba(0, 0, 0, 0)" or transparent_bg,
		new_tab = { fg_color = scheme.background, bg_color = scheme.brights[6] },
		new_tab_hover = { fg_color = scheme.background, bg_color = scheme.foreground },
	},
}

wezterm.on("format-tab-title", function(tab, _, _, _, hover)
	local background = config.colors.brights[1]
	local foreground = config.colors.foreground

	if tab.is_active then
		background = config.colors.brights[7]
		foreground = config.colors.background
	elseif hover then
		background = config.colors.brights[8]
		foreground = config.colors.background
	end

	local title = tostring(tab.tab_index + 1)
	return {
		{ Foreground = { Color = background } },
		{ Text = "█" },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Foreground = { Color = background } },
		{ Text = "█" },
	}
end)

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
