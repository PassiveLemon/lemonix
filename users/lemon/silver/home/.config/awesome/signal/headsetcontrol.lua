awesome.emit_signal("signal::battery::subscribe", true, "Headset", 20, "headsetcontrol -c -b")

awesome.connect_signal("signal::battery::status::Headset", function(percent)
  awesome.emit_signal("signal::peripheral::headset", percent)
end)

