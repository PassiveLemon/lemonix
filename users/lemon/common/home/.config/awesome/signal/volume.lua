local awful = require("awful")
local gears = require("gears")

local function emit(value)
  awesome.emit_signal("signal::peripheral::volume::value", value)
end

local value

local function volume()
  awful.spawn.easy_async("pamixer --get-volume-human", function(value_stdout)
    value = value_stdout:gsub("\n", ""):gsub("%%", "")
    if value == "muted" then
      value = -1
    else
      value = tonumber(value) or 50
    end
    emit(value)
  end)
end

volume()

local volume_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    volume()
  end,
})

local function volume_timer_wrapper(callback)
  volume_timer:stop()
  callback()
  volume_timer:start()
end

awesome.connect_signal("signal::peripheral::volume::update", function()
  volume_timer_wrapper(function()
    volume()
    awesome.emit_signal("ui::control::notification::volume")
  end)
end)

awesome.connect_signal("signal::peripheral::volume", function(volume_new)
  volume_timer_wrapper(function()
    awful.spawn("pamixer --set-volume " .. volume_new)
    emit(volume_new)
  end)
end)

awesome.connect_signal("signal::peripheral::volume::step", function(step)
  volume_timer_wrapper(function()
    value = (value + (step or 0))
    awful.spawn("pamixer --set-volume " .. value)
    emit(value)
  end)
end)

awesome.connect_signal("signal::peripheral::volume::mute", function()
  volume_timer_wrapper(function()
    awful.spawn("pamixer -t", function()
      volume()
    end)
  end)
end)

