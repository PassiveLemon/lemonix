local awful = require("awful")
local gears = require("gears")

local headset_cache = "N/A"

local function emit(headset)
  awesome.emit_signal("signal::peripheral::headset", headset)
end

local function headset()
  awful.spawn.easy_async("headsetcontrol -c -b", function(headset)
    local headset = headset:gsub("\n", "")
    emit(headset)
  end)
end
headset()
local headset_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    headset()
  end,
})
