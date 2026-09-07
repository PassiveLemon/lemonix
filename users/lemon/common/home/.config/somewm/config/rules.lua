local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local ruled = require("ruled")

--
-- Rules
--

ruled.client.connect_signal("request::rules", function()
  -- All clients
  ruled.client.append_rule({
    id = "global",
    rule = { },
    properties = {
      screen = awful.screen.preferred,
      placement = awful.placement.centered+awful.placement.no_offscreen,
      raise = true,
      size_hints_honor = false,
      honor_workarea = true,
    },
  })

  -- Floating clients
  ruled.client.append_rule({
    id = "floating",
    rule_any = {
      class    = { "xarchiver", "org.gnome.Loupe", "org.gnome.Papers", "nm-connection-editor", ".blueman-manager-wrapped", "zenity" },
      name     = { "Confirm File Replacing", "Copying files" },
      role     = { "pop-up", "GtkFileChooserDialog" },
    },
    properties = {
      floating = true,
      ontop = true,
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
      shadow = false,
    },
  })

  --
  -- Specifics
  --

  -- Float all Steam child clients: Chat, settings, game properties, etc
  ruled.client.append_rule({
    id = "steam",
    rule = {
      class = "steam",
    },
    except = {
      -- The exact match is necessary, otherwise the "Steam Settings" window name would be accepted
      name = "^Steam$",
    },
    properties = {
      floating = true,
      ontop = true,
    },
  })
end)

-- awesome.register_xproperty("STEAM_GAME", "number")
client.connect_signal("request::manage", function(c)
  -- -- Fullscreen all steam games with an exclusion check
  -- local cclass_exclude = { "steam", "zenity" }
  -- local cclass = string.lower(c.class or "")
  -- local csteam = c:get_xproperty("STEAM_GAME")
  -- if csteam and not h.table_contains(cclass_exclude, cclass) then
  --   c.fullscreen = true
  --   c:activate()
  -- end
  -- The jank section
  -- Sober will have a transparent bar the height of the wibar at the bottom. I guess this triggers it to draw?
  if (c.instance == "sober") or (c.class == "org.vinegarhq.Sober") then
    c.fullscreen = false
    c.fullscreen = true
  end
end)

--
-- Fullscreening and wibar
--

-- Spawn the client on top of the entire screen, not just under the bar
client.connect_signal("request::manage", function(c)
  local s = awful.screen.focused()
  if c.fullscreen then
    c.x, c.y = s.geometry.x, s.geometry.y
  end
end)

--
-- Layout
--

awful.screen.connect_for_each_screen(function(s)
  awful.tag({ "1", "2", "3", "4" }, s, b.layout)
end)

tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts({ b.layout })
end)

-- Go to end of the stack
client.connect_signal("request::manage", function(c, context)
  if context == "new" then
    c:to_secondary_section()
  end
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
  if c then
    c:activate({ context = "mouse_enter", raise = false })
    c:emit_signal("mouse::enter")
  end
end

-- The mouse::enter signal doesn't emit in the following cases, so we time an activation right after to mostly seamlessly activate context
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
    focus_timer:again()
  end
end)

-- After closing clients
client.connect_signal("request::unmanage", function()
  focus_timer:again()
end)

-- After moving clients across workspaces
client.connect_signal("property::tags", function(c)
  -- Floating clients can get stuck behind tiled clients if the check happens while the cursor is not over the new floating client
  if not c.floating then
    focus_timer:again()
  end
end)

