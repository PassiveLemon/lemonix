local user = require("config.user")

local widgets = { }

if user.bar.battery  then
  widgets.battery = require("ui.bar.widgets.battery")
else
  widgets.battery = { }
end

if user.bar.brightness then
  widgets.brightness = require("ui.bar.widgets.brightness")
else
  widgets.brightness = { }
end

if user.bar.cpu then
  widgets.cpu = require("ui.bar.widgets.cpu")
else
  widgets.cpu = { }
end

if user.bar.memory then
  widgets.memory = require("ui.bar.widgets.memory")
else
  widgets.memory = { }
end

if user.bar.music then
  widgets.music = require("ui.bar.widgets.music")
else
  widgets.music = { }
end

if user.bar.systray then
  widgets.systray = require("ui.bar.widgets.systray")
else
  widgets.systray = { }
end

if user.bar.taglist then
  widgets.taglist = require("ui.bar.widgets.taglist")
else
  widgets.taglist = { }
end

if user.bar.tasklist then
  widgets.tasklist = require("ui.bar.widgets.tasklist")
else
  widgets.tasklist = { }
end

if user.bar.time then
  widgets.time = require("ui.bar.widgets.time")
else
  widgets.time = { }
end

if user.bar.utility then
  widgets.utility = require("ui.bar.widgets.utility")
else
  widgets.utility = { }
end

return widgets

