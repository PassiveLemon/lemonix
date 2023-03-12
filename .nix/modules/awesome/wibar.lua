local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
--local volume_widget = require('awesome-wm-widgets.pactl-widget.volume')

mytextclock = wibox.widget.textclock(" %a %b %d, %I:%M ")

screen.connect_signal("request::desktop_decoration", function(s)
  awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 " }, s, awful.layout.layouts[1])

  -- Create a layoutbox widget
  s.mylayoutbox = awful.widget.layoutbox {
    screen  = s,
  }

  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
  }

  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist {
    screen  = s,
    filter  = awful.widget.tasklist.filter.currenttags,
  }

  -- Create the wibox
  s.mywibox = awful.wibar({
    position = "top",
    screen   = s,
    height   = 22
  })

  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left
      layout = wibox.layout.fixed.horizontal,
      s.mytaglist,
      cpu_widget({
        width = 20,
      }),
      ram_widget({
        color_used = "#f35252",
        color_buf = "#f3d052",
      }),
      --volume_widget(),
    },
    s.mytasklist, -- Middle
    { -- Right
      layout = wibox.layout.fixed.horizontal,
      wibox.widget.systray,
      mytextclock,
      s.mylayoutbox,
    },
  }
end)