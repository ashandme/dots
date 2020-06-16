local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local awful = require("awful")
local config_path = awful.util.getdir("config")

local theme = {}

theme.font          = "Iosevka Term"
theme.mono_font     = "Iosevka Term"


theme.bg_normal     = "#080b0a"
theme.bg_bright     = "#1b1c1b"
theme.bg_focus      = "#a7ccdb"
theme.bg_urgent     = "#181b1a"
theme.bg_systray    = theme.transparent

theme.fg_normal     = "#4d798b"
theme.fg_focus      = "#a7ccdb"
theme.fg_urgent     = "#2399c5"
theme.fg_minimize   = "#000000"

theme.useless_gap   = dpi(0)
theme.border_width  = dpi(0)
theme.border_normal = theme.bg_normal
theme.border_focus  = theme.bg_focus
theme.border_marked = theme.bg_bright

theme.border_radius = 5

theme.notification_margin = 15
theme.notification_padding = 30
theme.notification_spacing = 5
theme.notification_border_width = 0
theme.notification_bg = theme.bg_urgent
theme.notification_fg = theme.fg_normal
theme.notification_position = "bottom_right"
theme.notification_icon_size = 40

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = dpi(50)
theme.menu_width  = dpi(50)

theme.wallpaper = function(s)
    return "/home/me/Downloads/wall.jpg"
end

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
