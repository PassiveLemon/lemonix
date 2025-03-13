require("signal.brightness")
require("signal.volume")

local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

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
    awful.spawn.easy_async("pamixer -t", function()
      awesome.emit_signal("signal::peripheral::volume::update")
    end)
  end
})

local volume_slider = h.slider({
  margins = {
    top = 0,
    right = dpi(16),
    bottom = 0,
    left = dpi(b.margins),
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

local volume_bar = h.background({
  layout = wibox.layout.fixed.horizontal,
  volume_icon,
  volume_slider,
},
{
  x = dpi(total_width - (b.margins * 4)),
  y = dpi(32),
  bg = b.bg_secondary,
  shape = gears.shape.rounded_bar,
})

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
    left = dpi(b.margins),
  },
  x = dpi(total_width),
  y = dpi(16),
  max = 255,
  handle_width = dpi(16),
  bar_height = dpi(6),
  bar_shape = gears.shape.rounded_rect,
  output_signal = "signal::peripheral::brightness",
})
awesome.connect_signal("signal::peripheral::brightness::value", function(value)
  if value >= 0 then
    brightness_slider:get_children_by_id("slider")[1]._private.value = value
    brightness_slider:emit_signal("widget::redraw_needed")
  end
end)

local brightness_bar = h.background({
  layout = wibox.layout.fixed.horizontal,
  brightness_icon,
  brightness_slider,
},
{
  x = dpi(total_width - (b.margins * 4)),
  y = dpi(32),
  bg = b.bg_secondary,
  shape = gears.shape.rounded_bar,
})

awful.screen.connect_for_each_screen(function(s)
  local main = h.timed_popup({
    --      screen width, margin
    x = dpi(s.geometry.x + (b.margins * 3)),
    --      bar height, margin
    y = dpi(32 + (b.margins * 3)),
    screen = s,
    bg = b.bg_primary,
    fg = b.fg_primary,
    border_width = b.border_width,
    border_color = b.border_color_active,
    ontop = true,
    visible = false,
    type = "popup_menu",
    widget = h.margin({
      id = "background",
      widget = wibox.container.background,
      bg = b.ui_main_bg,
      {
        layout = wibox.layout.fixed.vertical,
        volume_bar,
        brightness_bar,
      },
    }),
  }, 3, true)

  local function show_control(force, volume_state, brightness_state)
    volume_bar.visible = volume_state
    brightness_bar.visible = brightness_state
    if force == true then
      main:toggle(true)
    elseif force == false then
      main:toggle(false)
    elseif main.screen.index == awful.screen.focused().index then
      main:toggle(true)
    else
      main:toggle(false)
    end
  end

  awesome.connect_signal("ui::control::notification::volume", function(force)
    show_control(force, true, false)
  end)

  awesome.connect_signal("ui::control::notification::brightness", function(force)
    show_control(force, false, true)
  end)
end)

