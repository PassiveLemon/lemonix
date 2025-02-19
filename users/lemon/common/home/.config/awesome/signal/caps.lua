local awful = require("awful")
local gears = require("gears")

local caps_cache

local function emit(caps)
  awesome.emit_signal("signal::peripheral::caps::state", caps)
end

local function caps_query()
  awful.spawn.easy_async_with_shell("xset q | grep Caps | awk '{print $4}'", function(caps_stdout)
    local caps = caps_stdout:gsub("\n", "")
    if caps == "on" then
      caps_cache = true
    else
      caps_cache = false
    end
    emit(caps_cache)
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
  if caps_cache == true then
    caps_cache = false
    emit(caps_cache)
  elseif caps_cache == false then
    caps_cache = true
    emit(caps_cache)
  end
end

awesome.connect_signal("signal::peripheral::caps::update", function()
  caps_query_timer:stop()
  caps()
  caps_query_timer:start()
end)

