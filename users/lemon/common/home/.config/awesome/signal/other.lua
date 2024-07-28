local awful = require("awful")
local gears = require("gears")

local h = require("helpers")

local function emit(uptime_days, uptime_hours)
  awesome.emit_signal("signal::miscellaneous::uptime", uptime_days, uptime_hours)
end

local function uptime()
  awful.spawn.easy_async_with_shell("cat /proc/uptime | awk '{print $1}'", function(uptime_raw)
    local uptime_raw = uptime_raw:gsub("\n", "")
    local uptime = h.round((uptime_raw / 3600), 1)
    local uptime_days = math.floor(uptime / 24)
    local uptime_hours = math.fmod(uptime, 24)
    emit(uptime_days, uptime_hours)
  end)
end
uptime()
local uptime_timer = gears.timer({
  timeout = 1,
  autostart = true,
  callback = function()
    uptime()
  end,
})
