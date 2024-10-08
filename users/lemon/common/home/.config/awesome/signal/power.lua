local gears = require("gears")

local lgi = require("lgi")
local upower = lgi.require("UPowerGlib")

local function emit(ac, perc, time)
  awesome.emit_signal("signal::power", ac, perc, time)
end

local devices = upower.Client():get_devices()

local function update_devices()
  devices = upower.Client():get_devices()
end

local function get_device(target)
  for _, device in ipairs(devices) do
    if device:get_object_path() == ("/org/freedesktop/UPower/devices/" .. target) then
      return device
    end
  end
  -- Fall back to the display device if the target device is not found. May result in problems if you want an AC device but a battery device is returned
  return upower.Client():get_display_device()
end

local function power()
  update_devices()
  ac = get_device("line_power_ACAD").online
  perc = get_device("battery_BAT1").percentage
  time = get_device("battery_BAT1").time_to_empty
  emit(ac, perc, time)
end
power()
local power_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    power()
  end,
})

