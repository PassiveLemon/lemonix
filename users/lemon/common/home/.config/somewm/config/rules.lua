local awful = require("awful")
local gears = require("gears")
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
      focus = awful.client.focus.filter,
      placement = awful.placement.centered+awful.placement.no_offscreen,
      raise = true,
      size_hints_honor = false,
      honor_workarea = true,
    },
    -- Go to the end of the stack instead
    callback = function(c)
      c:to_secondary_section()
    end,
  })

  -- Floating clients
  ruled.client.append_rule({
    id = "floating",
    rule_any = {
      instance = { "xarchiver", "loupe", "papers", "nm-connection-editor", ".blueman-manager-wrapped", "lxappearance", "zenity" }, -- somewm:ignore Lxappearance
      class    = { "Xarchiver", "loupe", "papers", "Nm-connection-editor", ".blueman-manager-wrapped", "Lxappearance", "zenity" }, -- somewm:ignore Lxappearance
      name     = { "Confirm File Replacing", "Copying files" },
      role     = { "pop-up", "GtkFileChooserDialog" },
    },
    properties = {
      floating = true,
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
      instance = "steamwebhelper",
      class    = "steam",
    },
    except = {
      -- The exact match is necessary, otherwise the "Steam Settings" window name would be accepted
      name = "^Steam$",
    },
    properties = {
      floating = true,
      shadow = {
        opacity = 0.65,
      }
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
  -- Some floating clients dont spawn centered for whatever reason
  if c.floating then
    c.minimized = true
    c.hidden = true
    gears.timer.start_new(0.15, function()
      awful.placement.under_mouse(c)
      c.hidden = false
      awful.placement.centered(c)
      c:activate()
      c.minimized = false
    end)
  end
end)

--
-- Fullscreening and wibar
--

-- Actually fullscreen new clients
client.connect_signal("request::manage", function(c)
  local s = awful.screen.focused()
  if c.fullscreen then
    -- Spawn the client on top of the entire screen, not just under the bar
    c.x, c.y = s.geometry.x, s.geometry.y
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

-- Rescue untagged clients after restart
client.connect_signal("request::manage", function(c)
  if #c:tags() == 0 then
    c:move_to_tag("1")
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
  if c ~= nil then
    c:activate({ context = "mouse_enter", raise = false })
    c:emit_signal("mouse::enter")
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

