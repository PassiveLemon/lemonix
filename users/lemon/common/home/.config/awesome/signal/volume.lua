local awful = require("awful")
local gears = require("gears")

-- The silent variable allows for managing mute without showing the notification. Only really used for the lockscreen
local value, mute, silent

local function emit()
  awesome.emit_signal("signal::peripheral::volume::value", value, mute)
end

local function volume()
  awful.spawn.easy_async("pamixer --get-volume-human", function(value_stdout)
    local valuex = value_stdout:gsub("\n", ""):gsub("%%", "")
    if valuex == "muted" then
      mute = true
    else
      mute = false
      value = tonumber(value) or 50
    end
  end)
end

volume()

local volume_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    volume()
    emit()
  end,
})

local function volume_timer_wrapper(callback)
  volume_timer:stop()
  callback()
  emit()
  awesome.emit_signal("ui::control::notification::volume", silent)
  volume_timer:start()
end

awesome.connect_signal("signal::peripheral::volume::update", function()
  volume_timer_wrapper(function()
    volume()
  end)
end)

awesome.connect_signal("signal::peripheral::volume", function(volume_new)
  volume_timer_wrapper(function()
    awful.spawn("pamixer --set-volume " .. volume_new)
    value = volume_new
  end)
end)

awesome.connect_signal("signal::peripheral::volume::step", function(step)
  volume_timer_wrapper(function()
    local to_value = value + (step or 0)
    if to_value > 100 then
      value = 100
    else
      value = to_value
    end
    awful.spawn("pamixer --set-volume " .. value)
  end)
end)

awesome.connect_signal("signal::peripheral::volume::mute::toggle", function(sil)
  volume_timer_wrapper(function()
    awful.spawn("pamixer -t")
    mute = not mute
    if sil then
      silent = true
    end
  end)
  silent = false
end)

awesome.connect_signal("signal::peripheral::volume::mute", function(sil)
  volume_timer_wrapper(function()
    awful.spawn("pamixer -m")
    mute = true
    if sil then
      silent = true
    end
  end)
  silent = false
end)

awesome.connect_signal("signal::peripheral::volume::unmute", function(sil)
  volume_timer_wrapper(function()
    awful.spawn("pamixer -u")
    mute = false
    if sil then
      silent = true
    end
  end)
  silent = false
end)

