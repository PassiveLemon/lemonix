local awful = require("awful")
local gears = require("gears")

local function emit(value)
  awesome.emit_signal("signal::peripheral::volume::value", value)
end

local function volume()
  awful.spawn.easy_async("pamixer --get-volume-human", function(value)
    value = value:gsub("\n", ""):gsub("%%", "")
    if value == "muted" then
      value = -1
    else
      value = tonumber(value)
    end
    emit(value)
  end)
end

volume()

local volume_timer = gears.timer({
  timeout = 2,
  autostart = true,
  callback = function()
    volume()
  end,
})

awesome.connect_signal("signal::peripheral::volume::update", function()
  volume_timer:stop()
  volume()
  volume_timer:start()
end)

awesome.connect_signal("signal::peripheral::volume", function(volume_new)
  volume_timer:stop()
  awful.spawn("pamixer --set-volume " .. volume_new)
  volume_timer:start()
end)

