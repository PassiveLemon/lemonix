pcall(require, "luarocks.loader")

local beautiful = require("beautiful")

local dpi = beautiful.xresources.apply_dpi
beautiful.init("/home/lemon/.config/awesome/config/theme.lua")

require("config.autostart")
require("config.keybindings")
require("config.notifications")
require("config.rules")
require("config.wibar")

awful.spawn("xrandr --output DP-0 --primary --mode 1920x1080 --rate 143.9 --rotate normal --output DP-2 --mode 1920x1080 --rate 143.9 --rotate normal --left-of DP-0")
