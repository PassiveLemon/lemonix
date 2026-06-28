local gears = require("gears")

local h = require("helpers")
local user = require("config.user")

local ast_Wp = require("lgi").require("AstalWp")
local speaker = ast_Wp.get_default().audio.default_speaker

-- State
local value = user.signal.default_volume
local mute = false
local silent = false -- Allows for managing mute without showing the notification. Only really used for the lockscreen

local function emit()
  awesome.emit_signal("signal::peripheral::volume::value", value, mute)
end

local function volume()
  local valuex = speaker.volume or value
  value = h.round((valuex * 100), 0)
  mute = speaker.mute
end

volume()

local volume_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    volume()
    emit()
  end,
})

local function volume_timer_wrapper(callback)
  volume_timer:stop()
  callback()
  emit()
  awesome.emit_signal("ui::control::notification::volume", silent)
  volume_timer:start()
end

awesome.connect_signal("signal::peripheral::volume::update", function()
  volume_timer_wrapper(function()
    volume()
  end)
end)

awesome.connect_signal("signal::peripheral::volume", function(volume_new)
  volume_timer_wrapper(function()
    value = h.clamp(volume_new, 0, 100)
    speaker:set_volume(value / 100)
  end)
end)

awesome.connect_signal("signal::peripheral::volume::step", function(step)
  volume_timer_wrapper(function()
    value = h.clamp((value + step), 0, 100)
    speaker:set_volume(value / 100)
  end)
end)

awesome.connect_signal("signal::peripheral::volume::mute::toggle", function(sil)
  volume_timer_wrapper(function()
    mute = not mute
    silent = sil
    speaker:set_mute(mute)
  end)
  silent = false
end)

awesome.connect_signal("signal::peripheral::volume::mute", function(sil)
  volume_timer_wrapper(function()
    mute = true
    silent = sil
    speaker:set_mute(true)
  end)
  silent = false
end)

awesome.connect_signal("signal::peripheral::volume::unmute", function(sil)
  volume_timer_wrapper(function()
    mute = false
    silent = sil
    speaker:set_mute(false)
  end)
  silent = false
end)

