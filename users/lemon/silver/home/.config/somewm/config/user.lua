local awful = require("awful")
local gears = require("gears")

require("signal.wivrn")
require("ui.crosshair")
require("ui.resource")

local user = { }

user.terminal = "tym"
user.browser = "firefox"
user.editor = os.getenv("EDITOR") or "nano"
user.visual_editor = "lite-xl"
user.editor_cmd = user.terminal .. " -- " .. user.editor
user.super = "Mod4" -- Windows key

awful.input.accel_speed = -0.5
awful.input.accel_profile = "flat"

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

-- local output_table = {
--   ["DP-1"] = {
--     mode = {
--       width = 1920,
--       height = 1080,
--       refresh = 143.854996,
--     },
--     position = {
--       x = 0,
--       y = 0,
--     },
--     adaptive_sync = true,
--   },
--   ["DP-2"] = {
--     mode = {
--       width = 1920,
--       height = 1080,
--       refresh = 143.854996,
--     },
--     position = {
--       x = 1920,
--       y = 0,
--     },
--     adaptive_sync = true,
--   },
-- }

-- local function outputter(o)
--   print(o.name)
--   if o.name == "DP-1" then
--     o.mode = {
--       width = 1920,
--       height = 1080,
--       refresh = 143.854996,
--     }
--     o.position = {
--       x = 0,
--       y = 0,
--     }
--     o.adaptive_sync = true

--   elseif o.name == "DP-2" then
--     o.mode = {
--       width = 1920,
--       height = 1080,
--       refresh = 143.854996,
--     }
--     o.position = {
--       x = 1920,
--       y = 0,
--     }
--     o.adaptive_sync = true
--   end
-- end

-- outputter(output.get_by_name("DP-2"))
-- outputter(output.get_by_name("DP-1"))

gears.timer.delayed_call(function()
  awful.spawn("wlr-randr --output DP-2 --mode 1920x1080@143.854996Hz --pos 0,0 --output DP-1 --mode 1920x1080@143.854996Hz --pos 1920,0")
end)

awesome.set_idle_timeout("dpms", 300, function() awesome.dpms_off() end)
awesome.set_idle_timeout("lock", 600, function() awesome.lock() end)

return user

