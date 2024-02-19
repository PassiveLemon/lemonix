local awful = require("awful")
local gears = require("gears")

local caps_cache

local function emit(caps)
  awesome.emit_signal("signal::caps::state", caps)
end

local function caps_query()
  awful.spawn.easy_async_with_shell("xset q | grep Caps | awk '{print $4}'", function(caps)
    local caps = caps:gsub("\n", "")
    caps_cache = caps
    emit(caps)
  end)
end

caps_query()

local function caps()
  if caps_cache == "on" then
    caps_cache = "off"
    emit(caps_cache)
  elseif caps_cache == "off" then
    caps_cache = "on"
    emit(caps_cache)
  end
end

local caps_query_timer = gears.timer({
  timeout = 0.5,
  autostart = true,
  callback = function()
    caps_query()
  end,
})

awesome.connect_signal("signal::caps::update", function()
  caps_query()
end)
