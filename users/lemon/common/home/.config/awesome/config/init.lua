local b = require("beautiful")
b.init(require("config.theme"))

require("config.user")
require("config.keybindings")
require("config.notifications")
require("config.rules")

local awful = require("awful")
awful.spawn("xset b off")

