local awful = require("awful")
local beautiful = require("beautiful")

beautiful.init("~/.config/awesome/config/theme.lua")

require("config.autostart")
require("config.keybindings")
require("config.notifications")
require("config.rules")
require("ui.wibar")