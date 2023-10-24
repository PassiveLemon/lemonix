local awful = require("awful")
local gears = require("gears")

local function emit(use, full, now)
  awesome.emit_signal('signal::battery', use, full, now)
end

local function charge()
  awful.spawn.easy_async("cat /sys/class/power_supply/BAT0/power_now", function(use)
    local use = use:gsub("\n", "")
    awful.spawn.easy_async("cat /sys/class/power_supply/BAT0/energy_now", function(now)
      local now = now:gsub("\n", "")
      awful.spawn.easy_async("cat /sys/class/power_supply/BAT0/energy_full", function(full)
        local full = full:gsub("\n", "")
        emit(use, now, full)
      end)
    end)
  end)
end

charge()

local charge_timer = gears.timer {
  timeout = 5,
  autostart = true,
  callback = function()
    charge()
  end,
}

return { charge = charge }
