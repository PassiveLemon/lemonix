local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local ruled = require("ruled")
local naughty = require("naughty")

local menubar = require("menubar")
local dpi = beautiful.xresources.apply_dpi

--
-- Rules
--

-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
  ruled.client.append_rule {
    id         = "global",
    rule       = { },
    properties = {
      focus     = awful.client.focus.filter,
      raise     = true,
      screen    = awful.screen.preferred,
      placement = awful.placement.no_overlap+awful.placement.no_offscreen
    }
  }
end)

-- Floating clients.
ruled.client.append_rule {
  id       = "floating",
  rule_any = {
    instance = { "feh", "lxappearance", "authy desktop", "xarchiver" },
    class    = { "feh", "Lxappearance", "Authy Desktop", "Xarchiver" },
    name = { "Customize Look and Feel", "Twilio Authy" }
  },
  properties = { floating = true }
}

--
-- Apps
--

ruled.client.append_rule {
  rule = {
    instance = "easyeffects",
    class = "easyeffects",
    name = "Easy Effects"
  },
  properties = { 
    screen = "DP-0",
    tag = root.tags()[5],
    minimized = true,
    urgent = false
  }
}

--
-- Other
--

terminal = "kitty"
browser = "firefox"
editor = os.getenv("EDITOR") or "nano"
visual_editor = "codium"
editor_cmd = terminal .. " -e " .. editor
menubar.utils.terminal = terminal

-- Tag layout
tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts({
    awful.layout.suit.spiral.dwindle,
  })
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  c:activate { context = "mouse_enter", raise = false }
end)