local awful = require("awful")
local gears = require("gears")

local function emit(cur, max)
  awesome.emit_signal("signal::peripheral::brightness", cur, max)
end

local function brightness()
  awful.spawn.easy_async("brightnessctl get", function(cur)
    local cur = tonumber(cur:gsub("\n", ""))
    awful.spawn.easy_async("brightnessctl max", function(max)
      local max = tonumber(max:gsub("\n", ""))
      emit(cur, max)
    end)
  end)
end
brightness()
local brightness_timer = gears.timer({
  timeout = 3,
  autostart = true,
  callback = function()
    brightness()
  end,
})

awesome.connect_signal("signal::peripheral::brightness::update", function()
  brightness_timer:stop()
  brightness()
  brightness_timer:start()
end)

awesome.connect_signal("signal::peripheral::brightness", function(brightness_new)
  brightness_timer:stop()
  awful.spawn("brightnessctl set " .. brightness_new)
  brightness_timer:start()
end)

