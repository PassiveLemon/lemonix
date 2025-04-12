local awful = require("awful")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")

local widgets = require("ui.popup.widgets")

local dpi = b.xresources.apply_dpi

awful.screen.connect_for_each_screen(function(s)
  local power_popup = h.timed_popup({
    --      screen width, margin, main popup width
    x = (dpi(s.geometry.x + 353) + (b.useless_gap * 2)),
    --      bar height, margin
    y = (dpi(32) + (b.useless_gap * 2)),
    screen = s,
    bg = b.bg_primary,
    fg = b.fg_primary,
    border_width = b.border_width,
    border_color = b.border_color_active,
    ontop = true,
    visible = false,
    type = "popup_menu",
    hide_on_click_anywhere = true,
    widget = h.background({
      layout = wibox.layout.fixed.vertical,
      widgets.power.menu,
    },
    {
      bg = b.bg_primary,
    })
  }, 5)

  widgets.power.button:connect_signal("button::press", function()
    if power_popup.screen.index == awful.screen.focused().index then
      power_popup:toggle()
    else
      power_popup:toggle(false)
    end
  end)

  local main = h.timed_popup({
    --      screen width, gap
    x = (dpi(s.geometry.x) + (b.useless_gap * 2)),
    --      bar height, gap
    y = (dpi(32) + (b.useless_gap * 2)),
    screen = s,
    bg = b.bg_primary,
    fg = b.fg_primary,
    border_width = b.border_width,
    border_color = b.border_color_active,
    ontop = true,
    visible = false,
    type = "popup_menu",
    hide_on_click_anywhere = true,
    widget = h.background({
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.layout.fixed.horizontal,
        widgets.volume.control,
        widgets.power.button,
      },
      widgets.brightness.control,
      widgets.music.control,
    },
    {
      bg = b.bg_primary,
    }),
    mouse_enter = function()
      power_popup:stop()
    end,
    mouse_leave = function()
      power_popup:again()
    end
  }, 3)

  power_popup:connect_signal("mouse::enter", function()
    main:stop()
  end)
  power_popup:connect_signal("mouse::leave", function()
    main:again()
  end)

  awesome.connect_signal("ui::control::toggle", function(force)
    awesome.emit_signal("signal::mpris::update")
    if force == true then
      main:toggle(true)
    elseif force == false then
      main:toggle(false)
      power_popup:toggle(false)
    elseif main.screen.index == awful.screen.focused().index then
      main:toggle()
      power_popup:toggle(false)
    else
      main:toggle(false)
      power_popup:toggle(false)
    end
  end)
end)

