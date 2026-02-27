local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Tasklist
--

local tasklist = { }

local sep = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = " ",
})

function tasklist.tasklist(s)
  s.tasklist = awful.widget.tasklist({
    screen = s,
    filter  = awful.widget.tasklist.filter.currenttags,
    buttons = {
      awful.button({ }, 1, function (c)
        c:activate({ context = "tasklist", action = "toggle_minimization" })
      end),
      awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
      awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
    },
    layout = {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(0),
    },
    widget_template = {
      widget = wibox.container.place,
      valign = "center",
      halign = "center",
      forced_height = dpi(20),
      forced_width = dpi(20),
      {
        widget = wibox.container.place,
        {
          id = "imagebox",
          widget = wibox.widget.imagebox,
        },
      },
      create_callback = function(self, c)
        self:get_children_by_id("imagebox")[1].image = c.theme_icon
      end,
    },
  })

  local tasklist_widget = {
    widget = wibox.container.margin,
    margins = {
      right = dpi(2),
      left = dpi(2),
    },
    {
      widget = wibox.container.place,
      valign = "center",
      halign = "center",
      forced_height = dpi(24),
      {
        widget = wibox.container.background,
        bg = b.bg_secondary,
        shape = gears.shape.rounded_bar,
        forced_height = dpi(24),
        {
          layout = wibox.layout.fixed.horizontal,
          sep,
          s.tasklist,
          sep,
        },
      },
    },
  }

  return tasklist_widget
end

return tasklist

