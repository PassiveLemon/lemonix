local awful = require("awful")

awful.spawn.easy_async("xrandr --output DP-0 --primary --mode 1920x1080 --rate 143.9 --rotate normal --output DP-2 --mode 1920x1080 --rate 143.9 --rotate normal --left-of DP-0")

awful.spawn.easy_async([[sh -c "pgrep easyeffects || easyeffects --gapplication-service"]])
awful.spawn.easy_async([[sh -c "pgrep picom || picom --experimental-backend -b"]])
awful.spawn.easy_async([[sh -c "pgrep nm-applet || nm-applet"]])
awful.spawn.easy_async([[sh -c "pgrep megasync || megasync"]])