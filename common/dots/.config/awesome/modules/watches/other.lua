local awful = require("awful")

--
-- Other watches
--

awful.widget.watch("echo", 15, function()
  awful.spawn.easy_async_with_shell([[sh -c "uptime | awk -F'( |,|:)+' '{if (\$6 >= 1) {print \$6, \"days\", \$8, \"hours\"} else {print \$8, \"hours\"}}'"]], function(uptime)
    local uptime = uptime:gsub("\n", "")
    awful.spawn.easy_async_with_shell([[sh -c "headsetcontrol -c -b && echo -n '%'"]], function(headset)
      local headset = headset:gsub("\n", "")
      awesome.emit_signal("signal::other", uptime, headset)
    end)
  end)
end)
