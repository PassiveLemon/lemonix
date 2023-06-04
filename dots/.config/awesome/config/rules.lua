local awful = require("awful")
local gears = require("gears")
local ruled = require("ruled")
local menubar = require("menubar")

--
-- Rules
--

-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
  ruled.client.append_rule {
    id = "global",
    rule = { },
    properties = {
      focus = awful.client.focus.filter,
      raise = true,
      screen = awful.screen.preferred,
      placement = awful.placement.no_offscreen,
    },
  }

-- Always floating clients
  ruled.client.append_rule {
    id = "floating",
    rule_any = {
      instance = { "feh", "lxappearance", "authy desktop", "xarchiver", "kruler", },
      class    = { "feh", "Lxappearance", "Authy Desktop", "Xarchiver", "kruler", },
      name     = { "Customize Look and Feel", "Twilio Authy", "KRuler", "Confirm File Replacing", "Copying files", },
      role     = { "pop-up", "GtkFileChooserDialog", },
    },
    properties = {
      floating = true,
      ontop = true,
      placement = awful.placement.centered+awful.placement.no_offscreen,
    },
  }
end)

--
-- Apps
--

ruled.client.connect_signal("request::rules", function()
  ruled.client.append_rule {
    rule = {
      instance = "easyeffects",
      class    = "easyeffects",
      name     = "Easy Effects"
    },
    properties = { 
      screen = "DP-0",
      tag = " 5 ",
      minimized = true,
      urgent = false,
    },
  }

  ruled.client.append_rule {
    rule = {
      instance = "kruler",
      class    = "kruler",
      name     = "KRuler",
    },
    properties = {
      width = 1920,
      height = 75,
      border_width = 0,
    },
  }
end)

--
-- Other
--

terminal = "kitty"
browser = "firefox"
editor = os.getenv("EDITOR") or "nano"
visual_editor = "codium"
editor_cmd = terminal .. " -e " .. editor
menubar.utils.terminal = terminal

-- Layout
tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts({
    awful.layout.suit.spiral.dwindle,
  })
end)

client.connect_signal("manage", function(c)
  if not awesome.startup then awful.client.setslave(c) end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  c:activate { context = "mouse_enter", raise = false, }
end)