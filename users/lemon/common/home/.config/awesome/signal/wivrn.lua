local awful = require("awful")
local gears = require("gears")

local lgi = require("lgi")
local gio = lgi.require("Gio")
local glib = lgi.GLib

local bus = gio.bus_get_sync(gio.BusType.SESSION)

-- State
local bus_state = false

local function focus_steam()
  for _, c in ipairs(client.get()) do
    if c.class == "steam" and c.name:match("^Steam$") then
      local s = c.screen
      local t = c.first_tag
      if s and t then
        awful.screen.focus(s)
        t:view_only()
      end
      break
    end
  end
end

local function wivrn()
  local result = bus:call_sync(
    "io.github.wivrn.Server",
    "/io/github/wivrn/Server",
    "org.freedesktop.DBus.Properties",
    "Get",
    glib.Variant("(ss)", {
      "io.github.wivrn.Server",
      "HeadsetConnected"
    }),
    nil,
    gio.DBusCallFlags.NONE,
    -1)

  local connected = result:get_child_value(0):get_boolean()

  if connected then
    if not bus_state then
      bus_state = true
      awful.spawn.with_shell("systemctl --user stop picom")
      awful.spawn.with_shell("systemctl --user stop easyeffects")
      focus_steam()
    end
  else
    if bus_state then
      bus_state = false
      awful.spawn.with_shell("systemctl --user restart picom")
      awful.spawn.with_shell("systemctl --user restart easyeffects")
    end
  end
end

-- luacheck: ignore 211
---@diagnostic disable-next-line: unused-local
local wivrn_timer = gears.timer({
  timeout = 1,
  autostart = true,
  callback = function()
    wivrn()
  end,
})

