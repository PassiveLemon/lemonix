local awful = require("awful")
local gears = require("gears")

local user = { }

user.terminal = "tym"
user.browser = "firefox"
user.editor = os.getenv("EDITOR") or "nano"
user.visual_editor = "lite-xl"
user.editor_cmd = user.terminal .. " -- " .. user.editor
user.super = "Mod4" -- Windows key

awful.input.tap_to_click = 1
awful.input.natural_scrolling = 1
awful.input.accel_speed = 0.3

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

user.signal = {
  default_volume = 0,
  default_brightness = 50,
}

-- awful.spawn.with_shell("autorandr -l Default")
-- awful.spawn.with_shell("pidof -q xss-lock || xss-lock awesome-client 'awesome.emit_signal(\"ui::lock::toggle\")' &")

awful.screen.connect_for_each_screen(function(s)
  s.scale = 1.5
end)

client.connect_signal("mouse::enter", function(c)
  if (c.instance == "steamwebhelper") or (c.class == "steam") then
    c.maximize = true
    c.maximize = false
  end
end)

return user

