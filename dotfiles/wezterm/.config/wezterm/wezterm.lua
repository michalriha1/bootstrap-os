local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Helper function to check if vim is running
local function is_vim(pane)
	local process_name = pane:get_foreground_process_name()
	return process_name and (process_name:find("vim") or process_name:find("nvim"))
end

-- Helper function to create vim-aware navigation
local function vim_aware_navigation(direction, vim_key)
	return wezterm.action_callback(function(window, pane)
		if not is_vim(pane) then
			window:perform_action(act.ActivatePaneDirection(direction), pane)
		else
			pane:send_text(vim_key)
		end
	end)
end

config.leader = {
	key = "Space",
	mods = "CTRL",
	timeout_milliseconds = 1000,
}

config.keys = {
	{
		key = "o",
		mods = "CMD",
		action = wezterm.action.QuickSelectArgs({
			label = "open url",
			patterns = {
				"https?://\\S+",
			},
			skip_action_on_paste = true,
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wezterm.log_info("opening: " .. url)
				wezterm.open_with(url)
			end),
		}),
	},
	{
		key = "s",
		mods = "LEADER",
		action = act.ShowLauncherArgs({
			flags = "FUZZY|WORKSPACES",
		}),
	},
	{ key = "j", mods = "LEADER", action = act.SwitchWorkspaceRelative(1) },
	{ key = "k", mods = "LEADER", action = act.SwitchWorkspaceRelative(-1) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{
		key = "Escape",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local tab = window:mux_window():active_tab()
			tab:set_zoomed(false)
			window:perform_action(wezterm.action.ActivatePaneByIndex(1), pane)
		end),
	},
	{
		key = "`",
		mods = "CMD",
		action = wezterm.action_callback(function(window, pane)
			local tab = window:mux_window():active_tab()
			local panes = tab:panes_with_info()

			if #panes == 1 then
				pane:split({ direction = "Bottom" })
			else
				local first_pane = panes[1].pane
				local is_zoomed = panes[1].is_zoomed

				if not is_zoomed then
					first_pane:activate()
					window:perform_action(act.TogglePaneZoomState, first_pane)
				else
					window:perform_action(act.ActivatePaneDirection("Down"), pane)
				end
			end
		end),
	},
	{
		key = "Enter",
		mods = "CMD",
		action = wezterm.action.SplitPane({ direction = "Right" }),
	},
	{
		key = "Enter",
		mods = "CMD|SHIFT",
		-- action = wezterm.action.SplitPane({ direction = "Down", top_level = true }),
		action = wezterm.action.SplitPane({ direction = "Down" }),
	},
	{ key = "l", mods = "ALT", action = wezterm.action.ShowLauncher },
	{ key = "t", mods = "CMD", action = act.SwitchToWorkspace({ spawn = { cwd = wezterm.home_dir } }) },
	-- Vim-style pane navigation
	{ key = "h", mods = "CTRL", action = vim_aware_navigation("Left", "\x08") },
	{ key = "j", mods = "CTRL", action = vim_aware_navigation("Down", "\x0a") },
	{ key = "k", mods = "CTRL", action = vim_aware_navigation("Up", "\x0b") },
	{ key = "l", mods = "CTRL", action = vim_aware_navigation("Right", "\x0c") },
	{
		key = "f",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			local home = os.getenv("HOME")
			local paths = {
				home .. "/workspace",
				home .. "/workspace/work",
				home .. "/workspace/personal",
				home .. "/.config",
				home .. "/Documents/Obsidian",
			}

			local find_cmd = "find " .. table.concat(paths, " ") .. " -mindepth 1 -maxdepth 1 -type d 2>/dev/null"

			local success, stdout, stderr = wezterm.run_child_process({
				"bash",
				"-c",
				find_cmd,
			})

			if success then
				-- Collect entries and count name occurrences
				local entries = {}
				local name_count = {}
				for line in stdout:gmatch("[^\r\n]+") do
					local name = line:match("([^/]+)$")
					table.insert(entries, { path = line, name = name })
					name_count[name] = (name_count[name] or 0) + 1
				end

				local choices = {}
				for _, entry in ipairs(entries) do
					local label = entry.name
					if name_count[entry.name] > 1 then
						local parent = entry.path:match("([^/]+)/[^/]+$")
						label = entry.name .. "  (" .. parent .. ")"
					end
					table.insert(choices, {
						id = entry.path,
						label = label,
					})
				end

				window:perform_action(
					act.InputSelector({
						title = "Select Project",
						choices = choices,
						fuzzy = true,
						action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
							if id and label then
								inner_window:perform_action(
									act.SwitchToWorkspace({
										name = label,
										spawn = { cwd = id },
									}),
									inner_pane
								)
							end
						end),
					}),
					pane
				)
			end
		end),
	},
	{ key = "LeftArrow", mods = "CMD|SHIFT", action = act.RotatePanes("CounterClockwise") },
	{ key = "RightArrow", mods = "CMD|SHIFT", action = act.RotatePanes("Clockwise") },
	{ key = "x", mods = "CTRL|CMD", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "LeftArrow", mods = "OPT", action = act.SendKey({ key = "b", mods = "ALT" }) },
	{ key = "RightArrow", mods = "OPT", action = act.SendKey({ key = "f", mods = "ALT" }) },
}

config.equalize_panes = true
config.cursor_blink_ease_out = "EaseOut"
config.cursor_blink_rate = 800
config.enable_kitty_keyboard = true
-- config.default_cursor_style = "BlinkingBar"

-- General
config.font_size = 12.5
config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
config.line_height = 1.15
config.cell_width = 0.9

config.window_padding = {
	left = 30,
	right = 30,
	-- top = 30,
	-- bottom = 50,
}

config.max_fps = 120
-- config.pixel_scroll_sensitivity = 0.1
-- config.pixel_scroll_sensitivity = 2

config.color_scheme = "Catppuccin Frappe"
config.colors = {
	foreground = "#FFFFFF",
	background = "#2B2B2B",
	split = "#383838",
	ansi = {
		"#1d1d1d", -- black (used as box bg by pi themes) 1d1d1d vs 1d1f21
		"#e78284", -- red
		"#a6d189", -- green
		"#e5c890", -- yellow
		"#8caaee", -- blue
		"#f4b8e4", -- magenta
		"#81c8be", -- cyan
		"#b5bfe2", -- white
	},
}
config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.8,
}

config.window_decorations = "RESIZE"
config.enable_tab_bar = false

config.notification_handling = "SuppressFromFocusedPane"

return config
