------------------
---- MONITORS ----
------------------

-- hl.exec_scheduled_prop_refresh_immediately()
---------------------
---- MY PROGRAMS ----
---------------------
local terminal = "alacritty"
local menu = "noctalia msg panel-open launcher"
local home = os.getenv("HOME")

------------------
---- MONITORS ----
------------------
hl.monitor({
	output = "desc:AOC 25G3ZM",
	mode = "1920x1080@239.96",
	position = "0x0",
	scale = 1,
	transform = 0,
})

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
	hl.exec_cmd("hyprlock")
	hl.exec_cmd("noctalia")
	hl.exec_cmd(
		"sleep 3 && flatpak run com.rtosta.zapzap -m --enable-features=UseOzonePlatform --ozone-platform=wayland"
	)
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
	xwayland = {
		force_zero_scaling = true,
	},

	general = {
		gaps_in = 3,
		gaps_out = 8,
		border_size = 2,

		col = {
			active_border = "rgba(aea2e6aa)",
			inactive_border = "rgba(595959aa)",
		},

		resize_on_border = true,
		extend_border_grab_area = 15,
		allow_tearing = false,
		layout = "dwindle",
	},

	dwindle = {
		preserve_split = true,
		force_split = 2,
	},

	decoration = {
		rounding = 8,
		active_opacity = 0.85,
		inactive_opacity = 0.85,
		fullscreen_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 20,
			render_power = 3,
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 3,
			new_optimizations = true,
			ignore_opacity = true,
			brightness = 0.9,
			contrast = 1.7,
			noise = 0.03,
		},
	},

	animations = {
		enabled = true,
	},

	input = {
		kb_layout = "pt",
		kb_model = "pc105",
		follow_mouse = 0,
		numlock_by_default = false,
		accel_profile = "flat",
		sensitivity = 0,

		touchpad = {
			natural_scroll = true,
		},
	},

	misc = {
		vrr = 2,
		force_default_wallpaper = -1,
		disable_hyprland_logo = false,
	},
})

--------------------
---- ANIMATIONS ----
--------------------
-- Better curves imported from the sample config
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Core Apps
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())

-- Float & Pin
hl.bind(mainMod .. " + T", function()
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch pin"))
end)

-- Directional Focus Moves
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Move Active Window Directionally
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- Move Floating Window (Repeatable)
hl.bind(mainMod .. " + ALT + H", hl.dsp.exec_cmd("hyprctl dispatch moveactive -8 0"), { repeating = true })
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprctl dispatch moveactive 8 0"), { repeating = true })
hl.bind(mainMod .. " + ALT + K", hl.dsp.exec_cmd("hyprctl dispatch moveactive 0 -8"), { repeating = true })
hl.bind(mainMod .. " + ALT + J", hl.dsp.exec_cmd("hyprctl dispatch moveactive 0 8"), { repeating = true })

-- Active Window Resizing (with proper relative params)
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

-- Workspaces 1-9
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Layout Adjustments
hl.bind(mainMod .. " + plus", hl.dsp.layout("mfact +0.05"))
hl.bind(mainMod .. " + minus", hl.dsp.layout("mfact -0.05"))

-- Media & System Utilities
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("mouse:276", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -z -m region --clipboard-only"))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call lockScreen lock"), { locked = true })

local hyprScripts = "$HOME/.config/hypr/scripts"
hl.bind(
	mainMod .. " + ALT + R",
	hl.dsp.exec_cmd(hyprScripts .. "/rotate.sh"),
	{ description = "Monitor: Rotate Normal" }
)
hl.bind(
	mainMod .. " + ALT + N",
	hl.dsp.exec_cmd(hyprScripts .. "/rotate.sh 2"),
	{ description = "Monitor: Rotate 180" }
)
hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd(hyprScripts .. "/rotate.sh 1"), { description = "Monitor: Rotate 90" })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Fixes dragging issues with buggy XWayland apps (from sample config)
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- Ignores annoying maximize requests from apps (from sample config)
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Your custom rules
hl.window_rule({
	name = "brave-fullscreen-opacity",
	match = {
		class = "^brave-browser$",
		fullscreen = true,
	},
	opacity = "1.0 override 1.0 override",
})

hl.window_rule({
	name = "pip-opacity",
	match = {
		title = "^Picture-in-Picture$",
	},
	opacity = "1.0 override",
})

hl.window_rule({
	name = "float-on-current-workspace",
	match = {
		float = true,
	},
	workspace = "current",
})

hl.window_rule({
	name = "noctalia-lockscreen-focus",
	match = {
		class = "^noctalia-shell$",
		title = "^lockscreen$",
	},
	stay_focused = true,
})
