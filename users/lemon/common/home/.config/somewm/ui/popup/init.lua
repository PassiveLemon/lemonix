local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local user = require("config.user")

local widgets = require("ui.popup.widgets")

local dpi = b.xresources.apply_dpi

awful.screen.connect_for_each_screen(function(s)
  s.power_popup = h.timed_popup({
    -- screen position, main popup width, useless gaps
    x = (dpi(s.geometry.x + 353 - 3) + (b.useless_gap * 2)),
    -- wibar height, useless gaps
    y = (s.wibar.height - 3 + (b.useless_gap * 2)),
    screen = s,
    bg = b.bg_primary,
    fg = b.fg_primary,
    border_width = b.border_width,
    border_color = b.border_color_active,
    ontop = true,
    visible = false,
    type = "popup",
    shape = gears.shape.rounded_rect;
    hide_on_click_anywhere = true,
    widget = h.background({
      layout = wibox.layout.fixed.vertical,
      widgets.power.menu,
    },
    {
      bg = b.bg_primary,
    })
  }, 2)

  s.power_button = h.button({
    x = dpi(32),
    y = dpi(32),
    shape = gears.shape.circle,
    text = "󰐥",
    font = b.sysfont(dpi(15)),
    button_press = function()
      s.power_popup:toggle()
    end,
  })

  s.control_center = h.timed_popup({
    -- screen position, useless gaps
    x = (dpi(s.geometry.x - 3) + (b.useless_gap * 2)),
    -- wibar height, useless gaps
    y = (s.wibar.height - 3 + (b.useless_gap * 2)),
    screen = s,
    bg = b.bg_primary,
    fg = b.fg_primary,
    border_width = b.border_width,
    border_color = b.border_color_active,
    ontop = true,
    visible = false,
    type = "popup",
    shape = gears.shape.rounded_rect;
    widget = widgets.volume.control,
    mouse_enter = function()
      s.power_popup:stop()
    end,
    mouse_leave = function()
      s.power_popup:again()
    end,
  }, 2)
  -- cc_control is a custom value for when the control center is in "control" mode (aka showing all widgets)
  s.control_center.cc_control = false

  --
  -- Control
  --

  s.power_popup:connect_signal("property::visible", function(w)
    if w.visible then
      s.control_center:stop()
      s.power_button:get_children_by_id("textbox")[1].text = ""
    else
      s.power_button:get_children_by_id("textbox")[1].text = "󰐥"
      s.control_center:again()
    end
  end)

  s.control_center:connect_signal("property::visible", function(w)
    if s.control_center.cc_control then
    -- Ensure the bar is visible when control center is
      s.wibar.ontop = w.visible
      -- When the wibar is visible, move the control center below it
      local c = client.focus
      if c and c.fullscreen and (c.screen == s) then
        s.control_center.y = (s.wibar.height + (b.useless_gap * 2)) - dpi(3)
      end
    else
      s.control_center.y = (b.useless_gap * 2) - dpi(3)
    end
  end)

  s.power_popup:connect_signal("mouse::enter", function()
    s.control_center:stop()
  end)
  s.power_popup:connect_signal("mouse::leave", function()
    s.control_center:again()
  end)
end)

local function show_control(s, force)
  s.control_center:stop()
  if s == awful.screen.focused() then
    if force == true then
      s.control_center:toggle(true)
    elseif force == false then
      s.control_center:toggle(false)
    else
      s.control_center:toggle()
    end
  else
    s.control_center:toggle(false)
  end
  s.control_center:again()
end

awesome.connect_signal("ui::control::toggle", function(force)
  h.for_s(function(s)
    s.control_center.widget = h.background({
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.layout.fixed.horizontal,
        widgets.volume.control,
        s.power_button,
      },
      widgets.brightness.control,
      widgets.music.control,
    },
    {
      bg = b.bg_primary,
    })
    -- Bring the popup back to the control mode if the keybind is pressed while in notification mode
    if not s.control_center.cc_control then
      s.control_center.cc_control = true
      show_control(s, true)
    else
      show_control(s, force)
    end
  end)
end)

awesome.connect_signal("ui::control::clear", function()
  h.for_s(function(s)
    s.control_center:toggle(false)
  end)
end)

--
-- Notification
--

local function show_notif(widget)
  -- Dynamically show the specified widget
  h.for_s(function(s)
    if not s.control_center.cc_control then
      if user.control[widget] then
        s.control_center.widget = h.margin({
          layout = wibox.layout.fixed.vertical,
          widgets[widget].notif,
        })
        show_control(s, true)
      end
    end
  end)
end

awesome.connect_signal("ui::control::notification::volume", function(silent)
  if not silent then
    show_notif("volume")
  end
end)

awesome.connect_signal("ui::control::notification::brightness", function()
  show_notif("brightness")
end)

awesome.connect_signal("ui::control::notification::mpris", function()
  show_notif("music")
end)

