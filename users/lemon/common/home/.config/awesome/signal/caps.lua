local awful = require("awful")
local gears = require("gears")

local caps_cache

local function emit(caps)
  awesome.emit_signal("signal::peripheral::caps::state", caps)
end

local function caps_query()
  awful.spawn.easy_async_with_shell("xset q | grep Caps | awk '{print $4}'", function(caps)
    local caps = caps:gsub("\n", "")
    caps_cache = caps
    emit(caps)
  end)
end
caps_query()
local caps_query_timer = gears.timer({
  timeout = 3,
  autostart = true,
  callback = function()
    caps_query()
  end,
})

-- Nifty function to just make the caps signals much more responsive due to delays with detecting caps lock
local function caps()
  if caps_cache == "on" then
    caps_cache = "off"
    emit(caps_cache)
  elseif caps_cache == "off" then
    caps_cache = "on"
    emit(caps_cache)
  end
end

awesome.connect_signal("signal::caps::update", function()
  caps()
  caps_query_timer:again()
end)
