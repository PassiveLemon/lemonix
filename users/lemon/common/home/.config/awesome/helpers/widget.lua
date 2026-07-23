local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local click_to_hide = require("modules.click_to_hide")

local dpi = b.xresources.apply_dpi

--
-- Helpers
--

-- Margin
  -- Background
-- Widget
  -- Popup
  -- Text
    -- Button
  -- Slider

local widget_default = {
  toggle = true, -- Button clickability state
  no_color = false, -- Don't recolor button text on hover
  start_on_visible = false, -- Start the widget wait timer when immediately visible
  wait_time = 0, -- Time to wait before a button is clickable
  life_time = 3, -- Time that the widget will be visible for
  output_signal = nil, -- The signal to emit slider changes to
  mouse_enter = function() end,
  mouse_leave = function() end,
  toggle_on = function() end,
  toggle_off = function() end,
  button_press = function() end,
  timer_callback = function() end,
}

local h = { }

-- Widget with a lock timer, life timer, hide-on-click
function h.widget(conf_in)
  local conf = gears.table.join(widget_default, (conf_in or { }))
  local widget = wibox.widget(conf)
  -- https://bitbucket.org/grumph/home_config/src/4d650b5bc3c366eff245f528c7830c22bfef1ba4/.config/awesome/helpers/widget_popup.lua#lines-42:57
  if conf.hide_on_click_anywhere then
    click_to_hide.popup(widget, nil, true)
  end
  -- Lock timer stops problems caused by hide_on_click toggling too rapidly
  local can_toggle = true
  local lock_timer = gears.timer({
    timeout = 0.1,
    single_shot = true,
    callback  = function()
      can_toggle = true
    end
  })
  local life_timer = gears.timer({
    timeout = conf.life_time or 3,
    single_shot = true,
    callback = function()
      conf.timer_callback(widget)
      widget.visible = false
    end,
  })
  function widget:start()
    life_timer:start()
  end
  function widget:stop()
    life_timer:stop()
  end
  function widget:again()
    life_timer:again()
  end
  function widget:toggle(force)
    if can_toggle then
      if force == false or (force == nil and self.visible) then
        self.visible = false
        conf.toggle_off(widget)
      else
        self.visible = true
        conf.toggle_on(widget)
      end
    end
  end
  widget:connect_signal("mouse::enter", function()
    life_timer:stop()
    conf.mouse_enter(widget)
  end)
  widget:connect_signal("mouse::leave", function()
    life_timer:again()
    conf.mouse_leave(widget)
  end)
  widget:connect_signal("property::visible", function()
    if conf.start_on_visible then
      can_toggle = false
      lock_timer:again()
    end
  end)
  return widget
end

function h.popup(conf_in)
  local conf = gears.table.join(widget_default, (conf_in or { }))
  local widget = h.widget(conf)
  local popup = awful.popup(widget)
  return popup
end

function h.margin(conf_in, widget_pass)
  local conf = conf_in or { }
  local margin = h.widget({
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins and conf.margins.top or dpi(b.margins),
      right = conf.margins and conf.margins.right or dpi(b.margins),
      bottom = conf.margins and conf.margins.bottom or dpi(b.margins),
      left = conf.margins and conf.margins.left or dpi(b.margins),
    },
    widget_pass,
  })
  return margin
end

function h.background(conf_in, widget_pass)
  local conf = conf_in or { }
  local background = h.margin(conf, {
    id = "background",
    widget = wibox.container.background,
    forced_width = conf.x,
    forced_height = conf.y,
    bg = conf.bg or b.bg_secondary,
    fg = conf.fg or b.fg_primary,
    shape = conf.shape,
    visible = conf.visible,
    widget_pass,
  })
  return background
end

function h.text(conf_in)
  local conf = conf_in or { }
  local text = h.background(conf, {
    -- Allow use of either text or image
    layout = wibox.layout.stack,
    {
      id = "textbox",
      widget = wibox.widget.textbox,
      forced_width = conf.x,
      forced_height = conf.y,
      markup = conf.markup,
      text = conf.text,
      font = conf.font or b.sysfont(dpi(10)),
      halign = conf.halign or "center",
      valign = conf.valign or "center",
    },
    {
      id = "imagebox",
      widget = wibox.widget.imagebox,
      resize = conf.resize,
      image = conf.image,
      halign = conf.halign or "center",
      valign = conf.valign or "center",
    },
  })
  return text
end

-- A button with a wait timer and coloring
function h.button(conf_in)
  local conf = gears.table.join(widget_default, (conf_in or { }))
  local button = h.text(conf)
  local button_id = button:get_children_by_id("background")[1]
  button.toggle = conf.toggle
  local wait_timer = gears.timer({
    timeout = conf.wait_time,
    single_shot = true,
    callback = function()
      button.toggle = true
      button_id.fg = b.fg_focus
      conf.timer_callback(button_id)
    end,
  })
  button:buttons({
    awful.button({ }, 1, function()
      if button.toggle then
        conf.button_press(button_id)
      end
    end)
  })
  button_id:connect_signal("mouse::enter", function(self)
    if not button.toggle then
      if not conf.no_color then
        self.bg = conf.bg_focus or b.bg_minimize
        self.fg = conf.fg_primary or b.red
      end
    else
      if not conf.no_color then
        self.bg = conf.bg_focus or b.bg_minimize
        self.fg = conf.fg_focus or b.fg_focus
      end
    end
    wait_timer:again()
    conf.mouse_enter(button_id)
  end)
  button_id:connect_signal("mouse::leave", function(self)
    if not conf.no_color then
      self.bg = conf.bg_primary or b.bg_secondary
      self.fg = conf.fg_primary or b.fg_primary
    end
    wait_timer:stop()
    button.toggle = false
    conf.mouse_leave(button_id)
  end)
  return button
end

function h.slider(conf_in)
  local conf = gears.table.join(widget_default, (conf_in or { }))
  local slider = h.background(conf, {
    id = "slider",
    widget = wibox.widget.slider,
    minimum = conf.min or 0,
    maximum = conf.max or 100,
    handle_shape = conf.handle_shape or gears.shape.circle,
    handle_color = conf.handle_color or b.fg_primary,
    handle_width = dpi(0),
    bar_height = conf.bar_height,
    bar_shape = conf.bar_shape,
    bar_color = conf.bar_color or b.bg_minimize,
    bar_active_color = conf.bar_active_color or b.fg_primary,
  })
  local slider_id = slider:get_children_by_id("slider")[1]
  if conf.output_signal and (conf.output_signal ~= "") then
    slider_id:connect_signal("property::value", function(self, new_state)
      self.value = new_state
      awesome.emit_signal(conf.output_signal, new_state)
    end)
  end
  slider_id:connect_signal("mouse::enter", function(self)
    self.handle_width = conf.handle_width
    self.bar_active_color = conf.bar_active_color or b.fg_primary
    conf.mouse_enter(slider_id)
  end)
  slider_id:connect_signal("mouse::leave", function(self)
    self.handle_width = dpi(0)
    self.bar_active_color = conf.bar_active_color or b.fg_primary
    conf.mouse_leave(slider_id)
  end)
  return slider
end

return h

