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
      instance = { "xarchiver", "loupe", "papers", "nm-connection-editor", ".blueman-manager-wrapped", "lxappearance" },
      class    = { "Xarchiver", "loupe", "papers", "Nm-connection-editor", ".blueman-manager-wrapped", "Lxappearance" },
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

-- Actually fullscreen managed clients
client.connect_signal("request::manage", function(c)
  local s = awful.screen.focused()
  if c.fullscreen then
    c.x, c.y = s.geometry.x, s.geometry.y
  end
end)

-- Layout
tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts({
    awful.layout.suit.spiral.dwindle,
  })
end)

client.connect_signal("request::manage", function(c)
  if not awesome.startup then awful.client.setslave(c) end
end)

-- Sloppy focus across clients
client.connect_signal("mouse::enter", function(c)
  c:activate({ context = "mouse_enter", raise = false })
end)

local function activate_under_pointer()
  local c = awful.mouse.client_under_pointer()
  if not (c == nil) then
    c:activate({ context = "mouse_enter", raise = false })
  end
end

local focus_timer = gears.timer({
  autostart = true,
  timeout = 0.2,
  single_shot = true,
  callback = function()
    activate_under_pointer()
  end
})

-- Sloppy focus across workspace changes
tag.connect_signal("property::selected", function(t)
  if t.selected then
    focus_timer:start()
  end
end)

-- Sloppy focus after closing clients
client.connect_signal("request::unmanage", function()
  focus_timer:start()
end)

-- Sloppy focus after moving clients across workspaces
client.connect_signal("property::tags", function()
  focus_timer:start()
end)

--
-- Bar
--

-- Same flickering problem as the original
-- local function wibar_layer(c)
--   if c.fullscreen and c.active then
--     c.screen.wibar.ontop = false
--   else
--     c.screen.wibar.ontop = true
--   end
-- end

-- client.connect_signal("property::fullscreen", wibar_layer)
-- client.connect_signal("focus", wibar_layer)
-- client.connect_signal("unfocus", wibar_layer)

-- Appears to work but untested multiscreen setup
-- local function wibar_layer(c)
--   local cs = c.screen
--   if not cs or not cs.wibar then return end

--   for _, sc in ipairs(cs.clients) do
--     if sc.fullscreen and sc.active then
--       s.wibar.ontop = false
--       return
--     end
--   end
--   s.wibar.ontop = true
-- end

-- client.connect_signal("request::activate", function(c) wibar_layer(c) end)
-- client.connect_signal("request::geometry", function(c) wibar_layer(c) end)

-- Basically the previous but without looping
local function wibar_layer(c)
  local screen = c.screen
  if not screen or not screen.wibar then return end

  -- Only hide the wibar if this client is both fullscreen and focused
  if c.fullscreen and c == client.focus then
    screen.wibar.ontop = false
  else
    screen.wibar.ontop = true
  end
end

client.connect_signal("request::activate", function(c) wibar_layer(c) end)
client.connect_signal("request::geometry", function(c) wibar_layer(c) end)

--
-- Other
--

-- Cleanup serverauth files
-- These persist if X crashes and can pile up if not removed
local homedir = h.join_path(os.getenv("HOME"))
for item in lfs.dir(homedir) do
  if item:match("%.serverauth%.%d+") then
    awful.spawn.with_shell("rm " .. h.join_path(homedir, item))
  end
end

