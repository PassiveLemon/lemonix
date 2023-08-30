local awful = require("awful")
local beautiful = require("beautiful")

beautiful.init("~/.config/awesome/config/theme.lua")

require("config.autostart") -- These are under the users in this repository
require("config.keybindings")
require("config.notifications")
require("config.rules")
require("modules.watches.cpu")
require("ui.wibar")
