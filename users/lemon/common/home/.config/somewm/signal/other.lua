local awful = require("awful")
local gears = require("gears")

local h = require("helpers")

local function emit(uptime_days, uptime_hours)
  awesome.emit_signal("signal::miscellaneous::uptime", uptime_days, uptime_hours)
end

local function uptime()
  awful.spawn.easy_async_with_shell("cat /proc/uptime | awk '{print $1}'", function(uptime_stdout)
    local uptime_raw = uptime_stdout:gsub("\n", "")
    local uptime_secs = h.round((uptime_raw / 3600), 1)
    local uptime_days = math.floor(uptime_secs / 24)
    local uptime_hours = math.fmod(uptime_secs, 24)
    emit(uptime_days, uptime_hours)
  end)
end

uptime()

-- luacheck: ignore 211
---@diagnostic disable-next-line: unused-local
local uptime_timer = gears.timer({
  timeout = 15,
  autostart = true,
  callback = function()
    uptime()
  end,
})

