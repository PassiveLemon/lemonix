local awful = require("awful")
local gears = require("gears")

local h = require("helpers")

local value, max

local function emit()
  awesome.emit_signal("signal::peripheral::brightness::value", value)
end

local function brightness()
  awful.spawn.easy_async("brightnessctl get", function(cur_stdout)
    local cur = cur_stdout:gsub("\n", "")
    awful.spawn.easy_async("brightnessctl max", function(max_stdout)
      max = max_stdout:gsub("\n", "")
      value = h.round(((cur / max) * 100), 0)
    end)
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

local function normalize_from_awm(num)
  -- Brightnessctl returns a max of 65535 so we can just divide that by 100 and multiply by the new brightness (which is a slider from 0 - 100)
  -- I would like a solution that doesn't rely on the magic number but it's not very important
  return (num * 655.35)
end

awesome.connect_signal("signal::peripheral::brightness::update", function()
  brightness_timer_wrapper(function()
    brightness()
  end)
end)

awesome.connect_signal("signal::peripheral::brightness", function(brightness_new)
  brightness_timer_wrapper(function()
    awful.spawn("brightnessctl set " .. normalize_from_awm(brightness_new))
    value = brightness_new
  end)
end)

awesome.connect_signal("signal::peripheral::brightness::step", function(step)
  brightness_timer_wrapper(function()
    local to_value = value + (step or 0)
    if to_value > 100 then
      value = 100
    else
      value = to_value
    end
    awful.spawn("brightnessctl set " .. normalize_from_awm(value))
  end)
end)

