local awful = require("awful")

-- Display
awful.spawn.easy_async("xrandr --output DP-0 --primary --mode 1920x1080 --rate 143.9 --rotate normal --output DP-2 --mode 1920x1080 --rate 143.9 --rotate normal --left-of DP-0", function()
  awful.spawn.easy_async("xrandr --output DP-0 --gamma 1.0:0.92:0.92 --output DP-2 --gamma 1.0:0.92:0.92")
end)

-- Hardware
awful.spawn.easy_async("headsetcontrol -l 0")
awful.spawn.easy_async("headsetcontrol -s 100")

-- Programs
awful.spawn.with_shell("pgrep easyeffects || easyeffects --gapplication-service")
awful.spawn.with_shell("pgrep picom || picom --experimental-backend -b")
awful.spawn.with_shell("pgrep nm-applet || nm-applet")
awful.spawn.with_shell("pgrep megasync || megasync")

-- Other
awful.spawn.easy_async("mkdir -p /tmp/mediamenu")
