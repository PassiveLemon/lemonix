local awful = require("awful")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local user = require("config.user")

local widgets = require("ui.popup.widgets")

local dpi = b.xresources.apply_dpi

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
        widgets.volume.bar,
        widgets.brightness.bar,
      },
    }),
  }, 3, true)

  local function show_control(force, volume_state, brightness_state)
    if user.control.brightness then
      widgets.brightness.bar.visible = brightness_state
    end
    if user.control.volume then
      widgets.volume.bar.visible = volume_state
    end
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

