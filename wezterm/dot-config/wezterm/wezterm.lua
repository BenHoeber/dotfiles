local wezterm = require("wezterm")
local config = {}
local act = wezterm.action

config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font_with_fallback({
	"FiraMono Nerd Font",
	"Noto Color Emoji",
	"Noto Emoji",
}) -- config.color_scheme = "Red Scheme"

config.colors = {
	-- The default background color
	background = "#1d1f21",
	-- The default text color
	foreground = "#c5c8c6",
}
config.window_padding = {
	left = 4,
	right = 4,
	top = 4,
	bottom = 4,
}
config.initial_cols = 91
config.initial_rows = 50

config.keys = {
	{
		key = "f",
		mods = "CTRL|SHIFT",
		action = act.Search({ CaseInSensitiveString = "" }),
	},
}
config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = 'NONE',
		action = act.ScrollByLine(-3),
	},
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = 'NONE',
		action = act.ScrollByLine(3),
	},
}

config.key_tables = {
	search_mode = {
		{ key = "Enter",  mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "n",      mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "p",      mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "r",      mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "u",      mods = "CTRL", action = act.CopyMode("ClearPattern") },
		{
			key = "PageUp",
			mods = "NONE",
			action = act.CopyMode("PriorMatchPage"),
		},
		{
			key = "PageDown",
			mods = "NONE",
			action = act.CopyMode("NextMatchPage"),
		},
		{ key = "UpArrow",   mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
	},
}
return config
