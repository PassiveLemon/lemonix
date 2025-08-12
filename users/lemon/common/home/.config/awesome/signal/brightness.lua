local awful = require("awful")
local gears = require("gears")

local h = require("helpers")

local function emit(value)
  awesome.emit_signal("signal::peripheral::brightness::value", value)
end

local function brightness()
  awful.spawn.easy_async("brightnessctl get", function(cur_stdout)
    local cur = cur_stdout:gsub("\n", "")
    awful.spawn.easy_async("brightnessctl max", function(max_stdout)
      local max = max_stdout:gsub("\n", "")
      local value = h.round(((cur / max) * 100), 0)
      emit(value)
    end)
  end)
end

brightness()

local brightness_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    brightness()
  end,
})

local function brightness_timer_wrapper(callback)
  brightness_timer:stop()
  callback()
  brightness_timer:start()
end

awesome.connect_signal("signal::peripheral::brightness::update", function()
  brightness_timer_wrapper(function()
    brightness()
  end)
  awesome.emit_signal("ui::control::notification::brightness")
end)

awesome.connect_signal("signal::peripheral::brightness", function(brightness_new)
  brightness_timer_wrapper(function()
    -- Brightnessctl returns a max of 65535 so we can just divide that by 100 and multiply by the new brightness (which is a slider from 0 - 100)
    -- I would like a solution that doesn't rely on the magic number but it's not very important
    awful.spawn("brightnessctl set " .. (brightness_new * 655.35))
    emit(brightness_new)
  end)
end)

awesome.connect_signal("signal::peripheral::brightness::increase", function(inc)
  brightness_timer_wrapper(function()
    awful.spawn.easy_async("brightnessctl set " .. (inc or 3) .. "%+", function()
      brightness()
    end)
  end)
  awesome.emit_signal("ui::control::notification::brightness")
end)

awesome.connect_signal("signal::peripheral::brightness::decrease", function(dec)
  brightness_timer_wrapper(function()
    awful.spawn.easy_async("brightnessctl set " .. (dec or 3) .. "%-", function()
      brightness()
    end)
  end)
  awesome.emit_signal("ui::control::notification::brightness")
end)

