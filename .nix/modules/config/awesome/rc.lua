local awful = require("awful")
local beautiful = require("beautiful")

beautiful.init("/home/lemon/.config/awesome/config/theme.lua")

require("config.keybindings")
require("config.notifications")
require("config.rules")
require("config.wibar")

awful.spawn("xrandr --output DP-0 --primary --mode 1920x1080 --rate 143.9 --rotate normal --output DP-2 --mode 1920x1080 --rate 143.9 --rotate normal --left-of DP-0")
awful.spawn("pamixer --set-limit 100")
awful.spawn("sleep 2 ; easyeffects")
