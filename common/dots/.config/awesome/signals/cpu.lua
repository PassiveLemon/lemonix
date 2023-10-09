local awful = require("awful")

--
-- CPU watches
--

awful.widget.watch("echo", 1, function()
  awful.spawn.easy_async_with_shell("top -bn1 | grep '%Cpu' | awk '{print int(100-$8)}'", function(use)
    local use = use:gsub("\n", "")
    awful.spawn.easy_async_with_shell([[sh -c "cat /sys/class/thermal/thermal_zone*/temp | sed 's/\(.*\)000$/\1/'"]], function(temp)
      local temp = temp:gsub("\n", "")
      awesome.emit_signal("signal::cpu", use, temp)
    end)
  end)
end)
