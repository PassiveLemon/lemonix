local awful = require("awful")
local gears = require("gears")

local function emit(use, temp)
  awesome.emit_signal("signal::cpu::data", use, temp)
end

local function cpu()
  awful.spawn.easy_async_with_shell("top -bn1 | grep '%Cpu' | awk '{print int(100-$8)}'", function(use)
    local use = use:gsub("\n", "")
    awful.spawn.easy_async_with_shell([[sh -c "cat /sys/class/hwmon/hwmon3/temp1_input | awk '{printf \"%0.1f\", \$1/1000}'"]], function(temp)
      local temp = temp:gsub("\n", "")
      emit(use, temp)
    end)
  end)
end

cpu()

local cpu_timer = gears.timer({
  timeout = 1,
  autostart = true,
  callback = function()
    cpu()
  end,
})
