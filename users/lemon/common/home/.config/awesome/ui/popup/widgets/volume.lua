require("signal.volume")

local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Volume
--

local volume = { }

local total_width = 350

local volume_icon = h.button({
  margins = {
    top = dpi(3),
    right = dpi(4),
    bottom = dpi(3),
    left = dpi(8),
  },
  x = dpi(18),
  y = dpi(15),
  text = "󰕾",
  font = b.sysfont(dpi(14)),
  no_color = true,
  button_press = function()
    awesome.emit_signal("signal::peripheral::volume::mute")
  end
})

local volume_slider = h.slider({
  margins = {
    top = 0,
    right = dpi(16),
    bottom = 0,
    left = b.margins,
  },
  x = dpi(total_width),
  y = dpi(16),
  max = 100,
  handle_width = dpi(16),
  bar_height = dpi(6),
  bar_shape = gears.shape.rounded_rect,
  output_signal = "signal::peripheral::volume",
})
awesome.connect_signal("signal::peripheral::volume::value", function(value)
  if value == -1 then
    volume_icon:get_children_by_id("textbox")[1].text = "󰝟"
  else
    volume_icon:get_children_by_id("textbox")[1].text = "󰕾"
  end
  if value >= 0 then
    volume_slider:get_children_by_id("slider")[1]._private.value = value
    volume_slider:emit_signal("widget::redraw_needed")
  end
end)

volume.control = h.background({
  layout = wibox.layout.fixed.horizontal,
  volume_icon,
  volume_slider,
},
{
  -- control center width, power button width, margins
  x = dpi(total_width - 32 - (b.margins * 6)),
  y = dpi(32),
  bg = b.bg_secondary,
  shape = gears.shape.rounded_bar,
})

volume.notif = h.background({
  layout = wibox.layout.fixed.horizontal,
  volume_icon,
  volume_slider,
},
{
  -- control center width, margins
  x = dpi(total_width - (b.margins * 4)),
  y = dpi(32),
  bg = b.bg_secondary,
  shape = gears.shape.rounded_bar,
})

return volume

