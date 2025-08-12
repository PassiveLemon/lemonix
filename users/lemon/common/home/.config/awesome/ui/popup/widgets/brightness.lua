require("signal.brightness")

local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Brightness
--

local brightness = { }

local total_width = 350

local brightness_icon = h.text({
  margins = {
    top = dpi(3),
    right = dpi(4),
    bottom = dpi(3),
    left = dpi(8),
  },
  x = dpi(18),
  y = dpi(15),
  text = "",
  font = b.sysfont(dpi(14)),
})

local brightness_slider = h.slider({
  margins = {
    top = 0,
    right = dpi(16),
    bottom = 0,
    left = b.margins,
  },
  x = dpi(total_width),
  y = dpi(16),
  handle_width = dpi(16),
  bar_height = dpi(6),
  bar_shape = gears.shape.rounded_rect,
  output_signal = "signal::peripheral::brightness",
})
awesome.connect_signal("signal::peripheral::brightness::value", function(value)
  brightness_slider:get_children_by_id("slider")[1]._private.value = value
  brightness_slider:emit_signal("widget::redraw_needed")
end)

brightness.control = h.background({
  layout = wibox.layout.fixed.horizontal,
  brightness_icon,
  brightness_slider,
},
{
  -- control center width, margins
  x = dpi(total_width - (b.margins * 4)),
  y = dpi(32),
  bg = b.bg_secondary,
  shape = gears.shape.rounded_bar,
})

brightness.notif = brightness.control

return brightness

