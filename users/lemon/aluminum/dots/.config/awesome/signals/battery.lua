local awful = require("awful")

--
-- Battery watches
--

awful.widget.watch("echo", 5, function()
  awful.spawn.easy_async_with_shell([[sh -c 'cat /sys/class/power_supply/BAT0/capacity']], function(cap)
    local cap = cap:gsub("\n", "")
    awesome.emit_signal("signal::battery", cap)
  end)
end)
