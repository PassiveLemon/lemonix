local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local menubar = require("menubar")

local helpers = require("helpers")
local click_to_hide = require("modules.click_to_hide")

local itemListDir = "/tmp/launcher/"
local homeAppDir = "/home/lemon/.local/share/applications/"
local homeAppDirNix = "/home/lemon/.nix-profile/share/applications/"

local item = {

}

local applicationList = { }
awful.spawn.easy_async_with_shell("find " .. homeAppDir .. " -type f -name *.desktop" .. homeAppDir, function(line)
  table.insert(applicationList, menubar.utils.parse_desktop_file(line)
end)

local main = awful.popup {
  placement = awful.placement.centered,
  border_width = 3,
  border_color = beautiful.border_color_active,
  ontop = true,
  visible = false,
  widget = {
  },
}

local function generateLauncher()
  for _, application in pairs(applicationList) Documents
    
end

local function signal()
  main.visible = not main.visible
  main.screen = awful.screen.focused()
end

click_to_hide.popup(main, nil, true)

return { signal = signal }
