local awful = require("awful")
local gears = require("gears")

-- State
local caps_state = false

local function emit()
  awesome.emit_signal("signal::peripheral::caps::state", caps_state)
end

local function caps_query()
  awful.spawn.easy_async_with_shell("xset q | grep Caps | awk '{print $4}'", function(caps_stdout)
    local caps = caps_stdout:gsub("\n", "")
    if caps == "on" then
      caps_state = true
    else
      caps_state = false
    end
    emit()
  end)
end

caps_query()

local caps_query_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    caps_query()
  end,
})

-- Nifty function to just make the caps signals much more responsive due to delays with detecting caps lock
local function caps()
  caps_state = not caps_state
  emit()
end

awesome.connect_signal("signal::peripheral::caps::update", function()
  caps_query_timer:stop()
  caps()
  caps_query_timer:start()
end)

