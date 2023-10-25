local awful = require("awful")
local gears = require("gears")

local function emit(caps)
  awesome.emit_signal('signal::caps', caps)
end

local function caps()
  awful.spawn.easy_async_with_shell("sleep 0.2 && xset q | grep Caps | awk '{print $4}'", function(caps)
    local caps = caps:gsub("\n", "")
    emit(caps)
  end)
end

local caps_timer = gears.timer {
  timeout = 2,
  autostart = true,
  callback = function()
    caps()
  end,
}

caps()

return { caps = caps }
