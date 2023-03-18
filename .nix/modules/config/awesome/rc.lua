pcall(require, "luarocks.loader")

local beautiful = require("beautiful")

local dpi = beautiful.xresources.apply_dpi
beautiful.init("/home/lemon/.config/awesome/config/theme.lua")

require("config.autostart")
require("config.keybindings")
require("config.notifications")
require("config.rules")
require("config.wibar")