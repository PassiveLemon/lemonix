local awful = require("awful")
local gears = require("gears")

local uptime_cache = "N/A"

local function emit(uptime, headset)
  if uptime == nil then
    uptime = uptime_cache
  end
  awesome.emit_signal("signal::other::data", uptime)
end

local function uptime()
  awful.spawn.easy_async_with_shell([[sh -c "uptime | awk -F'( |,|:)+' '{if (\$6 >= 1) {print \$6, \"days\", \$8, \"hours\"} else {print \$8, \"hours\"}}'"]], function(uptime)
    local uptime = uptime:gsub("\n", "")
    uptime_cache = uptime
    emit(uptime, nil)
  end)
end
uptime()
local uptime_timer = gears.timer({
  timeout = 15,
  autostart = true,
  callback = function()
    uptime()
  end,
})
