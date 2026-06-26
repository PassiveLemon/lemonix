local gears = require("gears")

local h = require("helpers")
local user = require("config.user")

local ast_brightness = require("lgi").require("AstalBrightness")
local b_screen = ast_brightness.get_default().screen

-- State
local value = user.signal.default_brightness

local function emit()
  awesome.emit_signal("signal::peripheral::brightness::value", value)
end

local function brightness()
  local valuex = b_screen.brightness or value
  value = h.round((valuex * 100), 0)
end

brightness()

local brightness_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    brightness()
    emit()
  end,
})

local function brightness_timer_wrapper(callback)
  brightness_timer:stop()
  callback()
  emit()
  awesome.emit_signal("ui::control::notification::brightness")
  brightness_timer:start()
end

awesome.connect_signal("signal::peripheral::brightness::update", function()
  brightness_timer_wrapper(function()
    brightness()
  end)
end)

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

