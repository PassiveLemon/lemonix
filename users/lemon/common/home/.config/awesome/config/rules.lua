local awful = require("awful")
local b = require("beautiful")
local ruled = require("ruled")

local h = require("helpers")
local lfs = require("lfs")

local dpi = b.xresources.apply_dpi

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
      instance = { "loupe", "xarchiver", "nm-connection-editor", ".blueman-manager-wrapped", "lxappearance", "kruler" },
      class    = { "loupe", "Xarchiver", "Nm-connection-editor", ".blueman-manager-wrapped", "Lxappearance", "kruler" },
      name     = { "Confirm File Replacing", "Copying files", "Steam Settings", "Friends List", "Recordings & Screenshots" },
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
      width = awful.screen.focused().geometry.width,
      height = dpi(75),
      border_width = dpi(0),
    },
  })
end)

--
-- Other
--

-- Cleanup serverauth files
local homedir = h.join_path(os.getenv("HOME"))
for item in lfs.dir(homedir) do
  if item:match("%.serverauth%.%d+") then
    awful.spawn.with_shell("rm " .. h.join_path(homedir, item))
  end
end

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
  c:activate({ context = "mouse_enter", raise = false })
end)

