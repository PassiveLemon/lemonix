local awful = require("awful")

terminal = "tym"
browser = "firefox"
editor = os.getenv("EDITOR") or "nano"
visual_editor = "lite-xl"
editor_cmd = terminal .. " -e " .. editor

awful.spawn.with_shell("autorandr -l Default")
awful.spawn.with_shell("pidof -q picom || picom --realtime -b")
awful.spawn.with_shell("pidof -q easyeffects || easyeffects --gapplication-service")
awful.spawn.with_shell("pidof -q nm-applet || nm-applet")

