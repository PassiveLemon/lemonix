local awful = require("awful")
local gears = require("gears")

local h = require("helpers")
local user = require("config.user")

local value = user.signal.default_brightness

local function emit()
  awesome.emit_signal("signal::peripheral::brightness::value", value)
end

local function brightness()
  awful.spawn.easy_async("brightnessctl get", function(cur_stdout)
  local cur = cur_stdout:gsub("\n", "")
    value = h.round(h.scale(tonumber(cur), 0, 100, 0, 65535), 0) or 0
  end)
end

brightness()

local brightness_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    brightness()
    emit()
  end,
})

local function brightness_timer_wrapper(callback)
  brightness_timer:stop()
  callback()
  emit()
  awesome.emit_signal("ui::control::notification::brightness")
  brightness_timer:start()
end

awesome.connect_signal("signal::peripheral::brightness::update", function()
  brightness_timer_wrapper(function()
    brightness()
  end)
end)

awesome.connect_signal("signal::peripheral::brightness", function(brightness_new)
  brightness_timer_wrapper(function()
    value = brightness_new
    awful.spawn("brightnessctl set " .. h.scale(brightness_new, 0, 100, 0, 65535))
  end)
end)

awesome.connect_signal("signal::peripheral::brightness::step", function(step)
  brightness_timer_wrapper(function()
    local to_value = value + (step or 0)
    value = h.clamp(to_value, 0, 100)
    awful.spawn("brightnessctl set " .. h.scale(value, 0, 100, 0, 65535))
  end)
end)

