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
      placement = awful.placement.centered+awful.placement.no_offscreen,
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

-- Some jank because otherwise Sober will have a transparent bar the height of the wibar at the bottom. I guess re-fullscreening updates it to draw?
client.connect_signal("request::manage", function(c)
  if (c.instance == "sober") or (c.class == "org.vinegarhq.Sober") then
    c.fullscreen = false
    c.fullscreen = true
  end
end)

--
-- Bar and fullscreens
--

-- Actually fullscreen managed clients
client.connect_signal("request::manage", function(c)
  local s = awful.screen.focused()
  if c.fullscreen then
    -- Spawn the client on top of the entire screen, not just under the bar.
    c.x, c.y = s.geometry.x, s.geometry.y
  end
end)

-- Helps stop spazzing when the focus context rapidly changes
local wibar_layer_timeout = false
local wibar_layer_timer = gears.timer({
  timeout = 0.1,
  callback = function()
    wibar_layer_timeout = false
  end,
})

-- Hide the wibar for the screen of the focused client if it is fullscreened
local function wibar_layer(c, force)
  if not wibar_layer_timeout then
    wibar_layer_timeout = true
    if c then
      local s = c.screen
      if not s or not s.wibar then return end
      if c.fullscreen and ((c == client.focus) or force) then
        s.wibar.ontop = false
      else
        s.wibar.ontop = true
      end
      wibar_layer_timer:again()
    end
  end
end

-- Stores a history of each clients previous screen attachment.
-- Current screen is index 1 and the first previous is the second.
local client_screen_history = { }

local function add_client_screen_history(c)
  if client_screen_history[c] then
    for k, v in ipairs(client_screen_history[c]) do
      if v.index == c.screen.index then
        table.remove(client_screen_history[c], k)
        break
      end
    end
    table.insert(client_screen_history[c], 1, c.screen)
  else
    client_screen_history[c] = { c.screen }
  end
end

client.connect_signal("request::geometry", function(c) wibar_layer(c) end)
client.connect_signal("request::activate", function(c) wibar_layer(c) end)

-- Run the wibar_layer check for the last focused client on a screen when the current focused client leaves the tag
client.connect_signal("request::manage", function(c) add_client_screen_history(c) end)
client.connect_signal("request::tag", function(c)
  add_client_screen_history(c)
  -- Select the second screen history because the first will be the current screen the client is on
  local focused_client_last_screen = client_screen_history[c][2] or nil
  if focused_client_last_screen then
    local last_focused_client = awful.client.focus.history.get(focused_client_last_screen, 0)
    wibar_layer(last_focused_client, true)
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

