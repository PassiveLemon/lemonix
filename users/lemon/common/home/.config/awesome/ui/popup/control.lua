local awful = require("awful")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local user = require("config.user")

local widgets = require("ui.popup.widgets")

local dpi = b.xresources.apply_dpi

awful.screen.connect_for_each_screen(function(s)
  local power_popup = h.timed_popup({
    -- screen position, main popup width, useless gaps
    x = (dpi(s.geometry.x + 353) + (b.useless_gap * 2)),
    -- wibar height, useless gaps
    y = (s.wibar.height + (b.useless_gap * 2)),
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
  }, 2)

  local main = h.timed_popup({
    -- screen position, useless gaps
    x = (dpi(s.geometry.x) + (b.useless_gap * 2)),
    -- wibar height, useless gaps
    y = (s.wibar.height + (b.useless_gap * 2)),
    screen = s,
    bg = b.bg_primary,
    fg = b.fg_primary,
    border_width = b.border_width,
    border_color = b.border_color_active,
    ontop = true,
    visible = false,
    type = "popup_menu",
    -- widget property is dynamically set, this is just a simple default
    widget = widgets.power.button,
    mouse_enter = function()
      power_popup:stop()
    end,
    mouse_leave = function()
      power_popup:again()
    end,
    toggle_off = function(self)
      self.cc_control = false
    end,
  }, 2)
  -- cc_control is a custom value for when the control center is in "control" mode (aka showing all widgets)
  main.cc_control = false

  --
  -- Control
  --

  widgets.power.button:connect_signal("button::press", function()
    if power_popup.screen.index == awful.screen.focused().index then
      power_popup:toggle()
    else
      power_popup:toggle(false)
    end
  end)

  power_popup:connect_signal("property::visible", function(w)
    if w.visible then
      main:stop()
      widgets.power.button:get_children_by_id("textbox")[1].text = ""
    else
      widgets.power.button:get_children_by_id("textbox")[1].text = "󰐥"
      main:again()
    end
  end)

  power_popup:connect_signal("mouse::enter", function()
    main:stop()
  end)
  power_popup:connect_signal("mouse::leave", function()
    main:again()
  end)

  -- When the wibar is visible, move the control center below it
  local function popup_positioner()
    if (not s.wibar.ontop) and client.focus and client.focus.fullscreen and (client.focus.screen == awful.screen.focused()) then
      main.y = (b.useless_gap * 2)
    else
      main.y = (s.wibar.height + (b.useless_gap * 2))
    end
  end

  s.wibar:connect_signal("property::ontop", function()
    popup_positioner()
  end)

  client.connect_signal("request::geometry", function()
    popup_positioner()
  end)

  local function show_control(force)
    popup_positioner()
    if main.screen.index == awful.screen.focused().index then
      if force == true then
        main:toggle(true)
      elseif force == false then
        main:toggle(false)
      else
        main:toggle()
      end
    else
      main:toggle(false)
    end
    main:again()
  end

  awesome.connect_signal("ui::control::toggle", function(force)
    awesome.emit_signal("signal::mpris::update")
    main.widget = h.background({
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
    })
    -- Bring the popup back to the control mode if the keybind is pressed while in notification mode
    if not main.cc_control then
      main.cc_control = true
      show_control(true)
    else
      show_control(force)
    end
  end)

  main:connect_signal("property::visible", function(w)
    s = awful.screen.focused()
    s.wibar.ontop = (w.visible and main.cc_control)
  end)

  --
  -- Notification
  --

  local function show_notif(widget)
    -- Dynamically show the specified widget
    if not main.cc_control then
      if user.control[widget] then
        main.widget = h.margin({
          layout = wibox.layout.fixed.vertical,
          widgets[widget].notif,
        })
        show_control(true)
      end
    end
  end

  awesome.connect_signal("ui::control::notification::volume", function()
    show_notif("volume")
  end)

  awesome.connect_signal("ui::control::notification::brightness", function()
    show_notif("brightness")
  end)

  awesome.connect_signal("ui::control::notification::mpris", function()
    show_notif("music")
  end)
end)

