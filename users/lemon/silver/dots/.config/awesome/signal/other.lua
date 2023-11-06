local awful = require("awful")
local gears = require("gears")

local uptime_cache = "N/A"
local headset_cache = "N/A"

local function emit(uptime, headset)
  if uptime == nil then
    uptime = uptime_cache
  end
  if headset == nil then
    headset = headset_cache
  end
  awesome.emit_signal('signal::other', uptime, headset)
end

local function uptime()
  awful.spawn.easy_async_with_shell([[sh -c "uptime | awk -F'( |,|:)+' '{if (\$6 >= 1) {print \$6, \"days\", \$8, \"hours\"} else {print \$8, \"hours\"}}'"]], function(uptime)
    local uptime = uptime:gsub("\n", "")
    uptime_cache = uptime
    emit(uptime, nil)
  end)
end

local function headset()
  awful.spawn.easy_async("headsetcontrol -c -b", function(headset)
    local headset = headset:gsub("\n", "")
    headset_cache = headset
    emit(nil, headset)
  end)
end

uptime()
headset()

local uptime_timer = gears.timer({
  timeout = 15,
  autostart = true,
  callback = function()
    uptime()
  end,
})

local headset_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    headset()
  end,
})

return { main = main, }
