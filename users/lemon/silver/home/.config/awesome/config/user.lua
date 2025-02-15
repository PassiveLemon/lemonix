local awful = require("awful")

local user = { }

user.terminal = "tym"
user.browser = "firefox"
user.editor = os.getenv("EDITOR") or "nano"
user.visual_editor = "lite-xl"
user.editor_cmd = user.terminal .. " -- " .. user.editor
user.super = "Mod4" -- Windows key
user.has_brightness = false
user.has_battery = false
user.suspend = false
user.hibernate = false

user.bar = {
  cpu = true,
  memory = true,
  brightness = false,
  battery = false,
  utility = true,
}

awful.spawn.with_shell("autorandr -l Default")
awful.spawn.with_shell("pidof -q xss-lock || xss-lock awesome-client 'awesome.emit_signal(\"ui::lock::toggle\")' &")
awful.spawn.with_shell("pidof -q picom || picom --realtime -b")
awful.spawn.with_shell("pidof -q easyeffects || easyeffects --gapplication-service")
awful.spawn.with_shell("pidof -q nm-applet || nm-applet &")
awful.spawn.with_shell("pidof -q tailscale-systray || tailscale-systray &")
awful.spawn.with_shell("pidof -q flameshot || flameshot &")


return user

