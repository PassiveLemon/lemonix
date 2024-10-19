local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

local total_width = 350

local volume_icon = h.text({
  margins = {
    top = dpi(3),
    right = dpi(4),
    bottom = dpi(3),
    left = dpi(8),
  },
  x = dpi(18),
  y = dpi(15),
  bg = b.bg1,
  text = "󰕾",
  font = b.sysfont(dpi(14)),
})

local volume_slider = h.slider({
  margins = {
    right = dpi(16),
    left = b.margins,
  },
  x = dpi(total_width),
  y = dpi(16),
  bg = b.bg1,
  max = 100,
  handle_width = dpi(16),
  bar_height = dpi(6),
  bar_shape = gears.shape.rounded_rect,
})

volume_slider:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, volume_state)
  slider.value = volume_state
  awesome.emit_signal("signal::peripheral::volume", volume_state)
end)
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

local volume_bar = wibox.widget({
  widget = wibox.container.margin,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  {
    id = "background",
    widget = wibox.container.background,
    forced_width = (dpi(total_width) - (b.margins * 4)),
    forced_height = dpi(32),
    bg = b.bg1,
    fg = b.ui_main_fg,
    shape = gears.shape.rounded_bar,
    {
      layout = wibox.layout.fixed.horizontal,
      volume_icon,
      volume_slider,
    },
  },
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
  bg = b.bg1,
  text = "",
  font = b.sysfont(dpi(14)),
})

local brightness_slider = h.slider({
  margins = {
    right = dpi(16),
    left = b.margins,
  },
  x = dpi(total_width),
  y = dpi(16),
  bg = b.bg1,
  max = 100,
  handle_width = dpi(16),
  bar_height = dpi(6),
  bar_shape = gears.shape.rounded_rect,
})
brightness_slider:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, brightness_state)
  slider.value = brightness_state
  awesome.emit_signal("signal::peripheral::brightness", brightness_state)
end)
awesome.connect_signal("signal::peripheral::brightness::value", function(value)
  if value >= 0 then
    brightness_slider:get_children_by_id("slider")[1]._private.value = value
    brightness_slider:emit_signal("widget::redraw_needed")
  end
end)

local brightness_bar = wibox.widget({
  widget = wibox.container.margin,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  {
    id = "background",
    widget = wibox.container.background,
    forced_width = (dpi(total_width) - (b.margins * 4)),
    forced_height = dpi(32),
    bg = b.bg1,
    fg = b.ui_main_fg,
    shape = gears.shape.rounded_bar,
    {
      layout = wibox.layout.fixed.horizontal,
      brightness_icon,
      brightness_slider,
    },
  },
})

awful.screen.connect_for_each_screen(function(s)
  local main = awful.popup({
    x = dpi(s.geometry.x + 12),
    y = dpi(32 + 12),
    border_width = dpi(3),
    border_color = b.border_color_active,
    ontop = true,
    visible = false,
    screen = s,
    type = "popup_menu",
    widget = {
      widget = wibox.container.margin,
      margins = {
        top = b.margins,
        right = b.margins,
        bottom = b.margins,
        left = b.margins,
      },
      {
        id = "background",
        widget = wibox.container.background,
        bg = b.ui_main_bg,
        {
          layout = wibox.layout.fixed.vertical,
          volume_bar,
          brightness_bar,
        },
      },
    },
  })
  local main_timer = gears.timer({
    timeout = 3,
    single_shot = true,
    callback = function()
      main.visible = false
    end,
  })
  main:connect_signal("mouse::enter", function()
    main_timer:stop()
  end)
  main:connect_signal("mouse::leave", function()
    main_timer:again()
  end)

  local function show_control(state, volume_state, brightness_state)
    volume_bar.visible = volume_state
    brightness_bar.visible = brightness_state
    if state == true then
      main.visible = true
    elseif state == false then
      main.visible = false
    elseif main.screen.index == awful.screen.focused().index then
      main.visible = true
    else
      main.visible = false
    end
    main_timer:again()
  end

  awesome.connect_signal("ui::control::notification::volume", function(state)
    show_control(state, true, false)
  end)

  awesome.connect_signal("ui::control::notification::brightness", function(state)
    show_control(state, false, true)
  end)
end)

