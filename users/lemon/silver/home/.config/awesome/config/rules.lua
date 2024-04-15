local awful = require("awful")
local ruled = require("ruled")

local h = require("helpers")

--
-- Rules
--

-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
  ruled.client.append_rule({
    id = "global",
    rule = { },
    properties = {
      focus = awful.client.focus.filter,
      raise = true,
      screen = awful.screen.preferred,
      size_hints_honor = false,
      placement = awful.placement.centered+awful.placement.no_offscreen,
    },
  })

  -- Always floating clients
  ruled.client.append_rule({
    id = "floating",
    rule_any = {
      instance = { "feh", "loupe", "lxappearance", "authy desktop", "xarchiver", "kruler" },
      class    = { "feh", "loupe", "Lxappearance", "Authy Desktop", "Xarchiver", "kruler" },
      name     = { "Customize Look and Feel", "Twilio Authy", "KRuler", "Confirm File Replacing", "Copying files" },
      role     = { "pop-up", "GtkFileChooserDialog" },
    },
    properties = {
      floating = true,
      raise = true,
      placement = awful.placement.centered+awful.placement.no_offscreen,
    },
  })

  --
  -- Specifics
  --

  ruled.client.append_rule({
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
  })
end)

--
-- Other
--

local autostart = os.getenv("HOME") .. "/.config/autostart/"
h.file_test(autostart, "awesome.sh", function(exists)
  if exists then
    awful.spawn.easy_async_with_shell("sh " .. autostart .. "awesome.sh")
  end
end)

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
  c:activate { context = "mouse_enter", raise = false }
end)
