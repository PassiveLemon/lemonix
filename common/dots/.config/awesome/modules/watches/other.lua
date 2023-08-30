local awful = require("awful")
local wibox = require("wibox")

local helpers = require("helpers")

--
-- Other watches
--

other = { }

other.uptime = helpers.simplewtch([[sh -c "uptime | awk -F'( |,|:)+' '{if (\$6 >= 1) {print \$6, \"days\", \$8, \"hours\"} else {print \$8, \"hours\"}}'"]], 60)

other.headset_bat = helpers.simplewtch([[sh -c "echo -n 'HS BAT: ' && headsetcontrol -c -b && echo -n '%'"]], 15)

return other
