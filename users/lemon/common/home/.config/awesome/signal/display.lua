local awful = require("awful")

awesome.connect_signal("signal::peripheral::display::powersave::enable", function()
  awful.spawn.with_shell("xset s on +dpms")
end)

awesome.connect_signal("signal::peripheral::display::powersave::disable", function()
  awful.spawn.with_shell("xset s on -dpms")
end)

