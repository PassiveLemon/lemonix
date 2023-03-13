local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local ruled = require("ruled")
local naughty = require("naughty")

local dpi = beautiful.xresources.apply_dpi

--
-- Wibar
--

local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")

screen.connect_signal("request::desktop_decoration", function(s)
  awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 " }, s, awful.layout.layouts[1])

  -- Layoutbox
  lemonlayoutbox = awful.widget.layoutbox {
    screen  = s,
  }

  -- Clock
  lemonclock = wibox.widget.textclock(" %a %b %d, %I:%M %p ")

  -- Taglist
  lemontaglist = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    style = {
      shape = gears.shape.circle,
    },
    buttons = {
      awful.button({ }, 1, function(t) t:view_only() end),
      awful.button({ }, 3, awful.tag.viewtoggle),
      awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
      awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end),
    }
  }

  -- Separator bar
  lemonbar = wibox.widget{
    markup = '|',
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
  }

  -- Separator space
  lemonsep = wibox.widget{
    markup = ' ',
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

  -- Tasklist
  lemontasklist = awful.widget.tasklist {
    screen  = s,
    filter  = awful.widget.tasklist.filter.currenttags,
    buttons = {
      awful.button({ }, 1, function (c)
        c:activate { context = "tasklist", action = "toggle_minimization" }
      end),
      awful.button({ }, 4, function() awful.client.focus.byidx( 1) end),
      awful.button({ }, 5, function() awful.client.focus.byidx(-1) end),
    }
  }

  -- Bar
  lemonwibar = awful.wibar({
    position = "top",
    screen   = s,
    height   = 23,
    border_width = 2,
    border_color = "#535d6c",
    type = "dock"
  })

  lemonwibar:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left
      layout = wibox.layout.fixed.horizontal,
      lemontaglist,
      lemonbar,
      lemonsep,
      cpu_widget({
        width = 20,
        color = "#ffff00",
      }),
      lemonsep,
      lemonbar,
      ram_widget({
        color_used = "#f35252",
        color_buf = "#f3d052",
      }),
      lemonbar,
      lemonsep,
    },
    lemontasklist, -- Center
    { -- Right
      layout = wibox.layout.fixed.horizontal,
      lemonsep,
      wibox.widget.systray,
      lemonbar,
      lemonclock,
      lemonbar,
      lemonlayoutbox,
    },
  }
end)