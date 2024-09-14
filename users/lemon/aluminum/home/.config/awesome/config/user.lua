terminal = "tym"
browser = "firefox"
editor = os.getenv("EDITOR") or "nano"
visual_editor = "code"
editor_cmd = terminal .. " -e " .. editor

local awful = require("awful")

awful.spawn.with_shell("autorandr -l Default")
awful.spawn.with_shell("pgrep -x fusuma > /dev/null || fusuma -d")
awful.spawn.with_shell("pgrep -x picom > /dev/null || picom --realtime -b")
awful.spawn.with_shell("pgrep -x nm-applet > /dev/null || nm-applet")
awful.spawn.with_shell("pgrep -x blueman-applet > /dev/null || blueman-applet")

