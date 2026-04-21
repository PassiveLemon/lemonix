local awful = require("awful")

require("signal.wivrn")

local user = { }

user.terminal = "tym"
user.browser = "firefox"
user.editor = os.getenv("EDITOR") or "nano"
user.visual_editor = "lite-xl"
user.editor_cmd = user.terminal .. " -- " .. user.editor
user.super = "Mod4" -- Windows key

user.bar = {
  battery = false,
  brightness = false,
  cpu = true,
  memory = true,
  music = true,
  systray = true,
  taglist = true,
  tasklist = true,
  time = true,
  utility = true,
}

user.control = {
  brightness = false,
  music = true,
  power = true,
  volume = true,
}

user.power = {
  lock = true,
  suspend = false,
  hibernate = false,
  poweroff = true,
  restart = true,
}

user.signal = {
  default_volume = 50,
}

awful.spawn.with_shell("autorandr -l Default")
awful.spawn.with_shell("pidof -q xss-lock || xss-lock awesome-client 'awesome.emit_signal(\"ui::lock::toggle\")' &")
awful.spawn.with_shell("pidof -q nimpad || nimpad -p=/dev/serial/by-id/usb-Arduino_LLC_Arduino_Micro_HIDLD-if00 &")

return user

