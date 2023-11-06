local awful = require("awful")
local gears = require("gears")

local function emit(cur, max)
  awesome.emit_signal('signal::brightness', cur, max)
end

local function brightness()
  awful.spawn.easy_async("brightnessctl get", function(cur)
    local cur = cur:gsub("\n", "")
    awful.spawn.easy_async("brightnessctl max", function(max)
      local max = max:gsub("\n", "")
      emit(cur, max)
    end)
  end)
end

brightness()

local brightness_timer = gears.timer({
  timeout = 2,
  autostart = true,
  callback = function()
    brightness()
  end,
})

return { brightness = brightness }
