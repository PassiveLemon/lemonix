local awful = require("awful")
local b = require("beautiful")
local wibox = require("wibox")

local widgets = require("ui.bar.widgets")

local dpi = b.xresources.apply_dpi

--
-- Wibar
--

screen.connect_signal("request::desktop_decoration", function(s)
  awful.tag({ "1", "2", "3", "4" }, s, awful.layout.layouts[1])

  s.wibar = awful.wibar({
    width = s.geometry.width,
    height = dpi(32),
    screen = s,
    bg = b.bg_primary,
    fg = b.fg_primary,
    border_width = dpi(0),
    position = "top",
    type = "dock",
    widget = {
      layout = wibox.layout.align.horizontal,
      expand = "none",
      { -- Left
        layout = wibox.layout.fixed.horizontal,
        widgets.systray.pill_nixos,
        widgets.systray.pill_systray,
        widgets.taglist.taglist(s),
        widgets.cpu.pill,
        widgets.memory.pill,
        widgets.brightness.pill,
        widgets.battery.pill,
      },
      { -- Center
        layout = wibox.layout.flex.horizontal,
        widgets.tasklist.tasklist(s)
      },
      { -- Right
        layout = wibox.layout.fixed.horizontal,
        widgets.music.pill,
        widgets.utility.pill,
        widgets.time.pill_date,
        widgets.time.pill_time,
      },
    },
  })

  s.wibar:connect_signal("mouse::leave", function()
    widgets.systray.pill_systray:again()
  end)

  -- Pull wibar ontop when focused client isn't fullscreened
  local function wibar_focus(c)
    if c.fullscreen then
      s.wibar.ontop = false
    else
      s.wibar.ontop = true
    end
  end

  -- Using "request::activate" causes a fight of focus between the wibar and fullscreen client, resulting in lots of visual spam
  client.connect_signal("button::press", wibar_focus)
  client.connect_signal("request::geometry", wibar_focus)
end)

