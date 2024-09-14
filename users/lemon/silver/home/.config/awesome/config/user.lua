terminal = "tym"
browser = "firefox"
editor = os.getenv("EDITOR") or "nano"
visual_editor = "lite-xl"
editor_cmd = terminal .. " -e " .. editor

local awful = require("awful")

awful.spawn.with_shell("autorandr -l Default")
awful.spawn.with_shell("pgrep -x picom > /dev/null || picom --realtime -b")
awful.spawn.with_shell("pgrep -x easyeffects > /dev/null || easyeffects --gapplication-service")
awful.spawn.with_shell("pgrep -x nm-applet > /dev/null || nm-applet")

