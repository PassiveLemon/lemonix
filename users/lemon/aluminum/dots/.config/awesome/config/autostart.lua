local awful = require("awful")

-- Display
awful.spawn.easy_async("xrandr --output xxxxxx --primary --mode 1920x1080 --rate xxxxxx --rotate normal")
awful.spawn.easy_async("xrandr --output xxxxxx --gamma 1.0:0.92:0.92")

-- Programs
awful.spawn.easy_async_with_shell("pgrep easyeffects || easyeffects --gapplication-service")
awful.spawn.easy_async_with_shell("pgrep nm-applet || nm-applet")

-- Other
awful.spawn.easy_async("mkdir -p /tmp/mediamenu")
