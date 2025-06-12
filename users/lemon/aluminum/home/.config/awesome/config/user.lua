local awful = require("awful")

local user = { }

user.terminal = "tym"
user.browser = "firefox"
user.editor = os.getenv("EDITOR") or "nano"
user.visual_editor = "lite-xl"
user.editor_cmd = user.terminal .. " -- " .. user.editor
user.super = "Mod4" -- Windows key

user.bar = {
  battery = true,
  brightness = true,
  cpu = false,
  memory = false,
  music = true,
  systray = true,
  taglist = true,
  tasklist = true,
  time = true,
  utility = true,
}

user.control = {
  brightness = true,
  music = true,
  power = true,
  volume = true,
}

user.power = {
  lock = true,
  suspend = true,
  hibernate = true,
  poweroff = true,
  restart = true,
}

awful.spawn.with_shell("autorandr -l Default")
awful.spawn.with_shell("pidof -q xss-lock || xss-lock awesome-client 'awesome.emit_signal(\"ui::lock::toggle\")' &")
awful.spawn.with_shell("pidof -q fusuma || fusuma -d")
awful.spawn.with_shell("pidof -q picom || picom --realtime -b")
awful.spawn.with_shell("pidof -q snixembed || snixembed --fork")
awful.spawn.with_shell("pidof -q nm-applet || nm-applet &")
awful.spawn.with_shell("pidof -q trayscale || trayscale --gapplication-service &")
awful.spawn.with_shell("pidof -q flameshot || flameshot &")

return user

