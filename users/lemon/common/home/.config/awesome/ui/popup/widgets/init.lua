local user = require("config.user")

local widgets = { }

if user.control.brightness then
  widgets.brightness = require("ui.popup.widgets.brightness")
else
  widgets.brightness = { }
end

if user.control.music then
  widgets.music = require("ui.popup.widgets.music")
else
  widgets.music = { }
end

if user.control.power then
  widgets.power = require("ui.popup.widgets.power")
else
  widgets.power = { }
end

if user.control.volume then
  widgets.volume = require("ui.popup.widgets.volume")
else
  widgets.volume = { }
end

return widgets

