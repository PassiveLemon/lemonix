local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
--local volume_widget = require('awesome-wm-widgets.pactl-widget.volume')

local wibar = {}
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

screen.connect_signal("request::desktop_decoration", function(s)
  -- Each screen has its own tag table.
  awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 " }, s, awful.layout.layouts[1])

  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox {
    screen  = s,
    buttons = {
      awful.button({ }, 1, function () awful.layout.inc( 1) end),
      awful.button({ }, 3, function () awful.layout.inc( -1) end),
      awful.button({ }, 4, function () awful.layout.inc( -1) end),
      awful.button({ }, 5, function () awful.layout.inc( 1) end),
    }
  }

  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    buttons = {
      awful.button({ }, 1, function(t) t:view_only() end),
      awful.button({ modkey }, 1, function(t)
        if client.focus then
          client.focus:move_to_tag(t)
        end
      end),
      awful.button({ }, 3, awful.tag.viewtoggle),
      awful.button({ modkey }, 3, function(t)
        if client.focus then
          client.focus:toggle_tag(t)
        end
      end),
      awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
      awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
    }
  }

  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist {
    screen  = s,
    filter  = awful.widget.tasklist.filter.currenttags,
    buttons = {
      awful.button({ }, 1, function (c)
        c:activate { context = "tasklist", action = "toggle_minimization" }
      end),
      awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
      awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
      awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
    }
  }

  -- Create the wibox
  s.mywibox = awful.wibar({
    position = "top",
    screen   = s,
    height   = 25
  })
  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left
      layout = wibox.layout.fixed.horizontal,
      s.mytaglist,
      cpu_widget(),
      ram_widget(),
      --volume_widget(),
    },
    s.mytasklist, -- Middle
    { -- Right
      layout = wibox.layout.fixed.horizontal,
      wibox.widget.systray(),
      mytextclock,
      s.mylayoutbox,
    },
  }
end)

return wibar