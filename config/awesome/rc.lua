local gears = require("gears")
local delayed_call = require("gears.timer").delayed_call
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local mpc = require("mpc")

-- error handling
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "an error occurred during startup!",
		text = awesome.startup_errors,
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- prevent internal errors from being reported
		if in_error then return end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "an error occurred!",
			text = tostring(err),
		})

		in_error = false
	end)
end

-- apply theme
beautiful.init(awful.util.getdir("config") .. "/themes/default/theme.lua")
local mod = "Mod4"

-- apply notification theming
naughty.config.padding = beautiful.notification_padding
naughty.config.spacing = beautiful.notification_spacing

naughty.config.defaults.border_width = beautiful.notification_border_width
naughty.config.defaults.margin = beautiful.notification_margin
naughty.config.defaults.position = beautiful.notification_position
naughty.config.defaults.icon_size = beautiful.notification_icon_size or beautiful.notification_height - 2*beautiful.notification_margin

naughty.config.presets.critical.bg = beautiful.bg_urgent
naughty.config.presets.critical.fg = beautiful.fg_urgent

-- set up layouts
awful.layout.layouts = {
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile,
	awful.layout.suit.tile.top,

	awful.layout.suit.max,
	awful.layout.suit.floating,
}

-- set up display
local tags = {"1", "2", "3", "4", "5", "6", "7", "8", "9"}

local function update_wallpaper(s)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s)
	end
end

screen.connect_signal("property::geometry", update_wallpaper)

local workspace_btns = gears.table.join(
	awful.button(
		{}, 1,
		function(t) t:view_only() end
	),
	awful.button(
		{mod}, 1,
		function(t)
			if client.focus then
				client.focus:move_to_tag(t)
			end
		end
	),
	awful.button(
		{}, 3,
		awful.tag.viewtoggle
	),
	awful.button(
		{mod}, 3,
		function(t)
			if client.focus then
				client.focus:toggle_tag(t)
			end
		end
	)
)

-- global widgets
local clock_widget = wibox.widget {
	-- time
	{
		{
			format = "%-l:%M ",
			widget = wibox.widget.textclock,
			align = "left",
		},
		widget = wibox.container.background,
		fg = beautiful.fg_focus,
	},
	-- date
	{
		format = "%b, %-e %A",
		widget = wibox.widget.textclock,
		align = "left",
	},
	widget = wibox.layout.flex.horizontal,
}

local mpd_conn
local music_text = wibox.widget.textbox()
local music_widget = wibox.widget {
	{
		music_text,
		widget = wibox.container.margin,
		left = 25,
	},
	widget = wibox.container.background,
	fg = beautiful.fg_focus,
	buttons = gears.table.join(
		awful.button({}, 1, function() mpd_conn:toggle_play() end),
		awful.button({}, 3, function() mpd_conn:send("next") end),
		awful.button({mod}, 3, function() mpd_conn:send("previous") end)
	),
}

awful.screen.connect_for_each_screen(function(s)
	s.padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 35,
	}

	awful.tag(tags, s, awful.layout.layouts[1])

	update_wallpaper(s)

	-- per-screen widgets
	local workspace_widget = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.noempty,
		buttons = workspace_btns,
		widget_template = {
			{
				id = "text_role",
				widget = wibox.widget.textbox,
			},
			widget = wibox.container.margin,
			left = 5,
			right = 5,
		},
	}

	if s == screen.primary then
		workspace_widget = wibox.widget {
			workspace_widget,
			music_widget,
			widget = wibox.layout.fixed.horizontal,
		}
	end

	-- bars
	local bar = wibox {
		widget = wibox.widget {
			workspace_widget,
			clock_widget,
			widget = wibox.layout.align.horizontal,
		},
		screen = s,
		type = "dock",
		visible = true,
		width = s.geometry.width - 10,
		height = 30,
		bg = beautiful.bg_normal,
	}

	awful.placement.bottom(bar, {
		offset = {y = -5},
		attach = true,
	})
end)

-- keybinds
local keybinds
local locked_keybinds
local client_keybinds

locked_keybinds = gears.table.join(
	awful.key(
		{mod, "Control", "Shift"}, "q",
		function()
			root.keys(keybinds)
			for c in awful.client.iterate(function(_) return true end) do
				c:keys(client_keybinds)
			end
			naughty.notify { title = "system", message = "restored keybinds" }
		end,
		{description = "restore keybindings", group = "awesome"}
	)
)

keybinds = gears.table.join(
	-- awesome
	awful.key(
		{mod}, "q",
		awesome.restart,
		{description = "restart awesome", group = "awesome"}
	),
	awful.key(
		{mod, "Shift"}, "q",
		awesome.quit,
		{description = "quit awesome", group = "awesome"}
	),
	awful.key(
		{mod, "Control", "Shift"}, "q",
		function()
			root.keys(locked_keybinds)
			for c in awful.client.iterate(function(_) return true end) do
				c:keys({})
			end
			naughty.notify { title = "system", message = "disabled keybinds" }
		end,
		{description = "disable keybindings", group = "awesome"}
	),

	-- apps
	awful.key(
		{mod}, "c",
		function() awful.spawn.with_shell("env WINIT_HIDPI_FACTOR=1 alacritty") end,
		{description = "launch terminal", group = "apps"}
	),
	awful.key(
		{mod}, "f",
		function() awful.spawn("emacs") end,
		{description = "launch emacs", group = "apps"}
	),
	awful.key(
		{mod}, "w",
		function() awful.spawn("firefox") end,
		{description = "launch web browser", group = "apps"}
	),
	awful.key(
		{mod}, "r",
		function() awful.spawn("rofi -normal-window -theme ~/.config/rofi/theme.rasi -show run") end,
		{description = "show launcher", group = "apps"}
	),
	awful.key(
		{mod}, "e",
		function() awful.spawn("/home/max/bin/rofi-emoji") end,
		{description = "show emoji picker", group = "apps"}
	),
	awful.key(
		{}, "Print",
		function() awful.spawn("flameshot gui") end,
		{description = "take a screenshot", group = "apps"}
	),

	-- workspace
	awful.key(
		{mod}, "space",
		function() awful.layout.inc(1) end,
		{description = "switch to next layout", group = "workspace"}
	),
	awful.key(
		{mod, "Shift"}, "space",
		function() awful.layout.inc(-1) end,
		{description = "switch to previous layout", group = "workspace"}
	),
	awful.key(
		{mod}, "Tab",
		function() awful.client.focus.byidx(1) end,
		{description = "focus next client", group = "workspace"}
	),
	awful.key(
		{mod, "Shift"}, "Tab",
		function() awful.client.focus.byidx(-1) end,
		{description = "focus previous client", group = "workspace"}
	),
	awful.key(
		{mod}, "h",
		function() awful.client.focus.global_bydirection("left") end,
		{description = "focus client to the left", group = "workspace"}
	),
	awful.key(
		{mod}, "j",
		function() awful.client.focus.global_bydirection("down") end,
		{description = "focus client below", group = "workspace"}
	),
	awful.key(
		{mod}, "k",
		function() awful.client.focus.global_bydirection("up") end,
		{description = "focus client above", group = "workspace"}
	),
	awful.key(
		{mod}, "l",
		function() awful.client.focus.global_bydirection("right") end,
		{description = "focus client to the right", group = "workspace"}
	),
	awful.key(
		{mod}, "BackSpace",
		function() awful.screen.focus_relative(1) end,
		{description = "focus next monitor", group = "workspace"}
	),
	awful.key(
		{mod, "Shift"}, "BackSpace",
		function() awful.screen.focus_relative(-1) end,
		{description = "focus previous monitor", group = "workspace"}
	),
	awful.key(
		{mod}, "n",
		function() awful.tag.incmwfact(-0.05) end,
		{description = "decrease master factor", group = "workspace"}
	),
	awful.key(
		{mod}, "m",
		function() awful.tag.incmwfact(0.05) end,
		{description = "increase master factor", group = "workspace"}
	)
)

client_keybinds = gears.table.join(
	-- actions
	awful.key(
		{mod}, "x",
		function(c) 
			c:kill()
			client.focus = mouse.current_client
		end,
		{description = "close", group = "client"}
	),
	awful.key(
		{mod, "Shift"}, "f",
		function(c)
			c.floating = not c.floating
			c.above = c.floating
		end,
		{description = "toggle floating", group = "client"}
	),
	awful.key(
		{mod, "Control", "Shift"}, "f",
		function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{description = "toggle fullscreen", group = "client"}
	),
	awful.key(
		{mod, "Shift"}, "m",
		function(c)
			c.maximized = not c.maximized
		end,
		{description = "toggle maximixed", group = "client"}
	),
	awful.key(
		{mod, "Shift"}, "t",
		function(c) awful.titlebar.toggle(c) end,
		{description = "toggle titlebar", group = "client"}
	),

	-- positioning
	awful.key(
		{mod, "Control"}, "h",
		function(c)
			if c.first_tag.layout == awful.layout.suit.floating or c.floating then
				c:relative_move(-25, 0, 0, 0)
			else
				awful.client.swap.global_bydirection("left")
			end
		end,
		{description = "move to the left", group = "client"}
	),
	awful.key(
		{mod, "Control"}, "j",
		function(c)
			if c.first_tag.layout == awful.layout.suit.floating or c.floating then
				c:relative_move(0, 25, 0, 0)
			else
				awful.client.swap.global_bydirection("down")
			end
		end,
		{description = "move down", group = "client"}
	),
	awful.key(
		{mod, "Control"}, "k",
		function(c)
			if c.first_tag.layout == awful.layout.suit.floating or c.floating then
				c:relative_move(0, -25, 0, 0)
			else
				awful.client.swap.global_bydirection("up")
			end
		end,
		{description = "move up", group = "client"}
	),
	awful.key(
		{mod, "Control"}, "l",
		function(c)
			if c.first_tag.layout == awful.layout.suit.floating or c.floating then
				c:relative_move(25, 0, 0, 0)
			else
				awful.client.swap.global_bydirection("right")
			end
		end,
		{description = "move to the right", group = "client"}
	),
	awful.key(
		{mod, "Control"}, "c",
		awful.placement.centered,
		{description = "move to center", group = "client"}
	),

	-- resizing
	awful.key(
		{mod, "Shift"}, "h",
		function(c) c.width = c:relative_move(0, 0, -25, 0) end,
		{description = "decrease width", group = "client"}
	),
	awful.key(
		{mod, "Shift"}, "j",
		function(c) c:relative_move(0, 0, 0, 25) end,
		{description = "increase height", group = "client"}
	),
	awful.key(
		{mod, "Shift"}, "k",
		function(c) c:relative_move(0, 0, 0, -25) end,
		{description = "decrease height", group = "client"}
	),
	awful.key(
		{mod, "Shift"}, "l",
		function(c) c:relative_move(0, 0, 25, 0) end,
		{description = "increase width", group = "client"}
	),
	awful.key(
		{mod}, "u",
		function(c) awful.client.incwfact(-0.1, c) end,
		{description = "decrease window factor", group = "client"}
	),
	awful.key(
		{mod}, "i",
		function(c) awful.client.incwfact(0.1, c) end,
		{description = "increase window factor", group = "client"}
	)
)

-- tag keybinds, uses raw keycodes
for i,v in pairs(tags) do
	keybinds = gears.table.join(keybinds,
		awful.key(
			{mod}, "#" .. i + 9,
			function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end,
			{description = "switch to tag ["..v.."]", group = "workspace"}
		),
		awful.key(
			{mod, "Control"}, "#" .. i + 9,
			function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end,
			{description = "toggle tag ["..v.."]", group = "workspace"}
		),
		awful.key(
			{mod, "Shift"}, "#" .. i + 9,
			function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end,
			{description = "move focused client to tag ["..v.."]", group = "workspace"}
		)
	)
end

local client_mousebinds = gears.table.join(
	awful.button({}, 1, function(c) client.focus = c; c:raise() end),
	awful.button({mod}, 1, awful.mouse.client.move),
	awful.button({mod}, 3, awful.mouse.client.resize)
)

-- set keybinds
root.keys(keybinds)

-- client rules
awful.rules.rules = {
	-- all clients
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_color,
			focus = awful.client.focus.filter,
			raise = true,
			keys = client_keybinds,
			buttons = client_mousebinds,
			screen = awful.screen.preferred,
			placement = awful.placement.centered,
			round_corners = true,
		},
		callback = function(c)
			awful.client.setslave(c)
			c.ontop = c.floating
		end,
	},

	-- force floating on some clients
	{
		rule_any = {
			instance = {"DTA", "copyq"},
			class = {"Arandr", "Gpick", "Kruler", "MessageWin", "Sxiv", "Wpa_gui", "pinentry", "veromix", "xtightvncviewer", "Rofi"},
			name = {"Event Tester"},
			role = {"AlarmWindow", "pop-up"},
		},
		properties = {
			floating = true,
		},
	},

	-- titlebars
	{
		rule_any = {
			type = {"normal", "dialog"},
		},
		properties = {
			titlebars_enabled = true,
		}
	},

	-- very on top
	{
		rule_any = {
			class = {"Rofi"},
		},
		properties = {
			ontop = true,
		},
	},
}

-- prevent offscreen client if screens change
client.connect_signal("manage", function(c)
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
	end
end)

local function status_text(client)
	local text = ""

	if client.floating then
		text = text .. "f"
	end
	if client.maximized then
		text = text .. "x"
	end

	if text ~= "" then
		text = "[" .. text .. "]"
	end

	return text
end

-- add titlebars
client.connect_signal("request::titlebars", function(c)
	local titlebar_mousebinds = gears.table.join(
		awful.button({}, 1, function()
			client.focus = c
			c:raise()
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			client.focus = c
			c:raise()
			awful.mouse.client.resize(c)
		end)
	)

	local status_textbox = wibox.widget.textbox(status_text(c))
	awful.titlebar(c, { size = 16, position = "left" }):setup({
		{
			{
				align = "left",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			left = 25,
			layout = wibox.container.margin,
		},
		nil,
		{
			{
				align = "right",
				font = beautiful.mono_font,
				widget = status_textbox,
			},
			right = 25,
			layout = wibox.container.margin,
		},
		buttons = titlebar_mousebinds,
		layout = wibox.layout.align.horizontal,
	})

	local function upd_status_text(c)
		status_textbox.text = status_text(c)
	end
	
	c:connect_signal("property::floating", upd_status_text)
	c:connect_signal("property::maximized", upd_status_text)
end)

-- rounded corners
--[[local function rrect(c, w, h)
	return gears.shape.rounded_rect(c, w, h, beautiful.border_radius)
end

client.connect_signal("manage", function(c)
	if c.round_corners and not c.fullscreen then
		 c.shape = rrect
	end
end)

beautiful.notification_shape = rrect
]]--
-- focus follows mouse
client.connect_signal("mouse::enter", function(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
		client.focus = c
	end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- music
--[[local function mpd_err(err)
	gears.timer.start_new(10, function()
		mpd_conn:send("ping")
	end)
end]]--

mpd_conn = mpc.new(nil, nil, nil, mpd_err,
	"status", function(_, r)
		if r.state == "stop" then
			music_widget:set_visible(false)
		else
			music_widget:set_visible(true)
		end

		if r.state == "pause" then
			music_widget.fg = beautiful.fg_normal
		else
			music_widget.fg = beautiful.fg_focus
		end
	end,
	"currentsong", function(_, r)
		music_text.text = "♫ " .. r.artist .. " - " .. r.title
	end
)
