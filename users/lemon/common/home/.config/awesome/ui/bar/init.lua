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

  -- Push wibar behind when focused client is fullscreen
  local function wibar_layer()
    local sf = awful.screen.focused()
    for _, c in ipairs(sf.clients) do
      if c.fullscreen and c.active then
        s.wibar.ontop = false
        return
      end
    end
    s.wibar.ontop = true
  end

  client.connect_signal("request::activate", wibar_layer)
  client.connect_signal("request::geometry", wibar_layer)
end)

