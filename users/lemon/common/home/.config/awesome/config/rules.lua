local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local ruled = require("ruled")

local h = require("helpers")
local lfs = require("lfs")

local dpi = b.xresources.apply_dpi

--
-- Rules
--

ruled.client.connect_signal("request::rules", function()
  -- Rules to apply to new all clients.
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

  -- Default floating clients
  ruled.client.append_rule({
    id = "floating",
    rule_any = {
      instance = { "xarchiver", "loupe", "nm-connection-editor", ".blueman-manager-wrapped", "lxappearance" },
      class    = { "Xarchiver", "loupe", "Nm-connection-editor", ".blueman-manager-wrapped", "Lxappearance" },
      name     = { "Confirm File Replacing", "Copying files" },
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

  -- Float all Steam child clients: Chat, settings, game properties, etc
  ruled.client.append_rule({
    id = "steam",
    rule = {
      instance = "steamwebhelper",
      class    = "steam",
    },
    except = {
      -- The exact match is necessary. Otherwise, the "Steam Settings" window name would be excepted.
      name = "^Steam$",
    },
    properties = {
      floating = true,
      raise = true,
      placement = awful.placement.centered+awful.placement.no_offscreen,
    },
  })

  -- Float, remove border, and widen kruler to screen width
  ruled.client.append_rule({
    id = "kruler",
    rule = {
      instance = "kruler",
      class    = "kruler",
      name     = "KRuler",
    },
    properties = {
      floating = true,
      raise = true,
      placement = awful.placement.left+awful.placement.no_offscreen,
      width = awful.screen.focused().geometry.width,
      height = dpi(75),
      shape = gears.shape.rectangle,
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

