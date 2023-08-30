local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local naughty = require("naughty")

local helpers = require("helpers")

--
-- CPU watches
--

cpu = { }

function cpu.use()
  awful.spawn.easy_async_with_shell("top -bn1 | grep '%Cpu' | awk '{print int(100-$8)}'", function(out)
    out = out:gsub( "\n", "" )
    --naughty.notify{title = out}
    return out
  end)
end

function cpu.temp()
  awful.spawn.easy_async_with_shell("cat /sys/class/thermal/thermal_zone*/temp | sed 's/(.*)000$/\1/'", function(out)
    out = out:gsub( "\n", "" )
    return out
  end)
end

return cpu
