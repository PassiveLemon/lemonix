local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Taglist
--

local taglist = { }

local sep = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = " ",
})

function taglist.taglist(s)
  s.taglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = {
      awful.button({ }, 1, function(t) t:view_only() end),
      awful.button({ }, 3, awful.tag.viewtoggle),
      awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
      awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end),
    },
    layout = {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(0),
    },
    widget_template = {
      widget = wibox.container.place,
      valign = "center",
      halign = "center",
      forced_height = dpi(24),
      {
        widget = wibox.container.background,
        bg = b.bg_secondary,
        {
          layout = wibox.layout.fixed.horizontal,
          sep,
          {
            id = "text_role",
            widget = wibox.widget.textbox,
          },
          sep,
        },
      },
    },
  })

  local taglist_widget = {
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
          s.taglist,
        },
      },
    },
  }

  return taglist_widget
end

return taglist

