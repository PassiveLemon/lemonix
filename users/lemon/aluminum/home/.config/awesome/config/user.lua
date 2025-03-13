local awful = require("awful")

local user = { }

user.terminal = "tym"
user.browser = "firefox"
user.editor = os.getenv("EDITOR") or "nano"
user.visual_editor = "lite-xl"
user.editor_cmd = user.terminal .. " -- " .. user.editor
user.super = "Mod4" -- Windows key
user.has_brightness = true
user.has_battery = true
user.suspend = true
user.hibernate = true

user.bar = {
  cpu = false,
  memory = false,
  brightness = true,
  battery = true,
  utility = true,
}

awful.spawn.with_shell("autorandr -l Default")
awful.spawn.with_shell("pidof -q xss-lock || xss-lock awesome-client 'awesome.emit_signal(\"ui::lock::toggle\")' &")
awful.spawn.with_shell("pidof -q fusuma || fusuma -d")
awful.spawn.with_shell("pidof -q picom || picom --realtime -b")
awful.spawn.with_shell("pidof -q nm-applet || nm-applet &")
awful.spawn.with_shell("pidof -q tailscale-systray || tailscale-systray &")
awful.spawn.with_shell("pidof -q snixembed || snixembed --fork")
awful.spawn.with_shell("pidof -q flameshot || flameshot &")

return user

