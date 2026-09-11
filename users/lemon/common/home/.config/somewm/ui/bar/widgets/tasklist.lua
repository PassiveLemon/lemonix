local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")
local menubar = require("menubar")

local gtk = require("lgi").require("Gtk")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Tasklist
--

local custom = gtk.IconTheme.new()
custom:set_custom_theme(b.icons)

local hicolor = gtk.IconTheme.new()
hicolor:set_custom_theme("hicolor")

local function get_icon(c)
  if not c.class then return nil end
  local class = c.class:lower()
  -- Reverse-DNS classes are common: try "com.mitchellh.ghostty", then "ghostty"
  for _, name in ipairs({ class, class:match("([^.]+)$") }) do
    for _, theme in ipairs({ custom, hicolor }) do
      local info = theme:lookup_icon(name, 64, 0)
      if info and info:get_filename() then
        return info:get_filename()
      end
    end
  end
  return menubar.utils.lookup_icon_uncached(class)
end

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
        if c.icon then
          self:get_children_by_id("imagebox")[1].image = gears.surface.load_uncached(c.icon)
          return
        end
        local icon = get_icon(c)
        if icon then
          self:get_children_by_id("imagebox")[1].image = gears.surface.load_uncached(icon)
          -- Sloppy focus on hover
          self:get_children_by_id("imagebox")[1]:connect_signal("mouse::enter", function()
            c:activate({ context = "mouse_enter", raise = false })
          end)
        end
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

