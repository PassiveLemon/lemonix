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
  -- All clients.
  ruled.client.append_rule({
    id = "global",
    rule = { },
    properties = {
      focus = awful.client.focus.filter,
      raise = true,
      screen = awful.screen.preferred,
      size_hints_honor = false,
    },
  })

  -- Floating clients
  ruled.client.append_rule({
    id = "floating",
    rule_any = {
      instance = { "xarchiver", "loupe", "papers", "nm-connection-editor", ".blueman-manager-wrapped", "lxappearance", "zenity" },
      class    = { "Xarchiver", "loupe", "papers", "Nm-connection-editor", ".blueman-manager-wrapped", "Lxappearance", "zenity" },
      name     = { "Confirm File Replacing", "Copying files" },
      role     = { "pop-up", "GtkFileChooserDialog" },
    },
    properties = {
      floating = true,
      raise = true,
      placement = awful.placement.centered+awful.placement.no_offscreen,
    },
  })

  -- Fullscreen clients
  ruled.client.append_rule({
    id = "fullscreen",
    rule_any = {
      instance = { "sober" },
      class    = { "org.vinegarhq.Sober" },
    },
    properties = {
      fullscreen = true,
      maximized = true,
      raise = true,
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
      -- The exact match is necessary. Otherwise, the "Steam Settings" window name would be excepted
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

awesome.register_xproperty("STEAM_GAME", "number")
client.connect_signal("request::manage", function(c)
  -- Fullscreen all steam games with an exclusion check
  local cclass_exclude = { "steam", "zenity" }
  local cclass = string.lower(c.class or "")
  local csteam = c:get_xproperty("STEAM_GAME")
  if csteam and not h.table_contains(cclass_exclude, cclass) then
    c.fullscreen = true
    c:raise()
  end

  -- Some jank because otherwise Sober will have a transparent bar the height of the wibar at the bottom. I guess re-fullscreening updates it to draw?
  if (c.instance == "sober") or (c.class == "org.vinegarhq.Sober") then
    c.fullscreen = false
    c.fullscreen = true
  end
end)

--
-- Fullscreening and wibar
--

-- Actually fullscreen newly managed clients
client.connect_signal("request::manage", function(c)
  local s = awful.screen.focused()
  if c.fullscreen then
    -- Spawn the client on top of the entire screen, not just under the bar
    c.x, c.y = s.geometry.x, s.geometry.y
  end
end)

local function hide_wibar(s, force)
  if s.wibar then
    s.wibar.ontop = not force
  end
end

-- Check if a client overlaps screen geometry
local function screen_collision(c, s)
  -- Only implemented for horizontal bars
  local c_l = c.x
  local c_r = c.x + c.width
  local s_l = s.geometry.x
  local s_r = s.geometry.x + s.geometry.width
  return c_l < s_r and c_r > s_l
end

local function wibar_layer(c)
  if c and not c.minimized then
    -- First check all screens for potential collision
    local screens = { [c.screen] = true }
    for s in screen do
      screens[s] = screen_collision(c, s)
    end
    for s, overlap in pairs(screens) do
      local hide = false
      -- If the client overlaps the screen and is not fullscreened, show the wibar
      -- If not, iterate over all clients and see if there is a fullscreened client
      if overlap then
        if c.fullscreen then
          hide = true
        else
          hide = false
        end
      else
        for _, c_visible in ipairs(s:get_clients()) do
          if c_visible.fullscreen then
            hide = true
            break
          end
        end
      end
      hide_wibar(s, hide)
    end
  end
end

client.connect_signal("request::geometry", function(c) wibar_layer(c) end)
client.connect_signal("manage", function(c) wibar_layer(c) end)
client.connect_signal("request::activate", function(c)
  if c.fullscreen then
    wibar_layer(c)
  end
end)

--
-- Layout
--

tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts({
    awful.layout.suit.spiral.dwindle,
  })
end)

client.connect_signal("request::manage", function(c)
  if not awesome.startup then awful.client.setslave(c) end
end)

--
-- Sloppy focus
--

-- Across clients
client.connect_signal("mouse::enter", function(c)
  c:activate({ context = "mouse_enter", raise = false })
end)

local function activate_under_pointer()
  local c = mouse.current_client
  if not (c == nil) then
    c:activate({ context = "mouse_enter", raise = false })
  end
end

-- the mouse::enter signal doesn't emit in the following cases, so we time an activation right after to mostly seamlessly activate context
local focus_timer = gears.timer({
  autostart = true,
  timeout = 0.2,
  single_shot = true,
  callback = function()
    activate_under_pointer()
  end
})

-- Across workspace changes
tag.connect_signal("property::selected", function(t)
  if t.selected then
    focus_timer:start()
  end
end)

-- After closing clients
client.connect_signal("request::unmanage", function()
  focus_timer:start()
end)

-- After moving clients across workspaces
client.connect_signal("property::tags", function(c)
  -- Floating clients can get stuck behind tiled clients if the check happens while the cursor is not over the new floating client
  if not c.floating then
    focus_timer:start()
  end
end)

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

