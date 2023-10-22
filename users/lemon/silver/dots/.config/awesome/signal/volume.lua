local awful = require("awful")
local gears = require("gears")

local function emit(value)
  awesome.emit_signal('signal::volume', value)
end

local function volume()
  awful.spawn.easy_async("pamixer --get-volume-human", function(value)
    value = value:gsub("\n", "")
    if value == "muted" then
      value = "Muted"
    end
    emit(value)
  end)
end

volume()

local volume_timer = gears.timer {
  timeout = 1,
  autostart = true,
  callback = function()
    volume()
  end,
}

return { volume = volume }
