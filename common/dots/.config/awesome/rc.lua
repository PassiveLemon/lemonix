local awful = require("awful")
local beautiful = require("beautiful")

beautiful.init("~/.config/awesome/config/theme.lua")

local autostart = os.getenv("HOME") .. "/.config/autostart/"
awful.spawn.easy_async_with_shell("test -f " .. autostart .. "awesome.sh && echo true || echo false", function(fileTest)
  fileTest = fileTest:gsub("\n", "")
  if fileTest == "true" then
    awful.spawn.easy_async_with_shell("sh " .. autostart .. "awesome.sh")
  end
end)

require("config.notifications")
require("config.keybindings")
require("config.rules")
require("ui.wibar")
