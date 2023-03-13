pcall(require, "luarocks.loader")

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local ruled = require("ruled")
local naughty = require("naughty")

local dpi = beautiful.xresources.apply_dpi
beautiful.init("/home/lemon/.config/awesome/config/theme.lua")

require("config.autostart")
require("config.keybindings")
require("config.notifications")
require("config.rules")
require("config.wibar")