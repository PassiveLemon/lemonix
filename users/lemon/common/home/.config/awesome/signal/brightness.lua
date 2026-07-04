local h = require("helpers")
local user = require("config.user")

local ast_brightness = require("lgi").require("AstalBrightness")
local device = ast_brightness.get_default()
local b_screen = device.screen

-- State
local value = h.round(((b_screen.brightness or (user.signal.default_brightness / 100)) * 100), 0)

local function emit()
  awesome.emit_signal("signal::peripheral::brightness::value", value)
end

function device:on_brightness_changed()
  value = h.round((b_screen.brightness * 100), 0)
  emit()
end

local function brightness_timer_wrapper(callback)
  callback()
  emit()
  awesome.emit_signal("ui::control::notification::brightness")
end

awesome.connect_signal("signal::peripheral::brightness", function(brightness_new)
  brightness_timer_wrapper(function()
    value = h.clamp(brightness_new, 0, 100)
    b_screen:set_brightness(value / 100)
  end)
end)

awesome.connect_signal("signal::peripheral::brightness::step", function(step)
  brightness_timer_wrapper(function()
    value = h.clamp((value + step), 0, 100)
    b_screen:set_brightness(value / 100)
  end)
end)

