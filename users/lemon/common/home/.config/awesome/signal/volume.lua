local h = require("helpers")
local user = require("config.user")

local ast_Wp = require("lgi").require("AstalWp")
local speaker = ast_Wp.get_default().audio.default_speaker

-- State
local value = h.round(((speaker.volume or (user.signal.default_volume / 100)) * 100), 0)
local mute = speaker.mute or false

local function emit()
  awesome.emit_signal("signal::peripheral::volume::value", value, mute)
end

speaker.on_notify["volume"] = function(self)
  value = h.round((self.volume * 100), 0)
  emit()
end

speaker.on_notify["mute"] = function(self)
  mute = self.mute
  emit()
end

local function volume_timer_wrapper(callback, silent)
  callback()
  emit()
  awesome.emit_signal("ui::control::notification::volume", silent)
end

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

awesome.connect_signal("signal::peripheral::volume::mute::toggle", function(silent)
  volume_timer_wrapper(function()
    speaker:set_mute(not mute)
  end, silent)
end)

awesome.connect_signal("signal::peripheral::volume::mute", function(silent)
  volume_timer_wrapper(function()
    speaker:set_mute(true)
  end, silent)
end)

awesome.connect_signal("signal::peripheral::volume::unmute", function(silent)
  volume_timer_wrapper(function()
    speaker:set_mute(false)
  end, silent)
end)

