local awful = require("awful")
local gears = require("gears")

local function emit(cur, max)
  awesome.emit_signal("signal::peripheral::brightness::value", cur, max)
end

local function brightness()
  awful.spawn.easy_async("brightnessctl get", function(cur_stdout)
    local cur = cur_stdout:gsub("\n", "")
    awful.spawn.easy_async("brightnessctl max", function(max_stdout)
      local max = max_stdout:gsub("\n", "")
      emit(tonumber(cur), tonumber(max))
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
    awful.spawn("brightnessctl set " .. brightness_new)
    emit(brightness_new)
  end)
end)

awesome.connect_signal("signal::peripheral::volume::increase", function(inc)
  brightness_timer_wrapper(function()
    awful.spawn.easy_async("brightnessctl set " .. (inc or 3) .. "%+", function()
      brightness()
    end)
  end)
  awesome.emit_signal("ui::control::notification::brightness")
end)

awesome.connect_signal("signal::peripheral::volume::decrease", function(dec)
  brightness_timer_wrapper(function()
    awful.spawn.easyasync("brightnessctl set " .. (dec or 3) .. "%-", function()
      brightness()
    end)
  end)
  awesome.emit_signal("ui::control::notification::brightness")
end)

