local awful = require("awful")
local naughty = require("naughty")

battery_check = true

awesome.connect_signal("signal::peripheral::headset", function(headset)
  if headset ~= "-2" and headset ~= "" and headset ~= nil then
    awful.spawn("headsetcontrol -l 0 -s 110")
    if headset ~= "-1" and headset <= "20" and battery_check then
      battery_check = false
      naughty.notification({
        title = "Headset battery low (20%)",
        urgency = "critical",
      })
    elseif headset ~= "-1" and headset > "20" then
      battery_check = true
    end
  end
end)

