local gears = require("gears")
local naughty = require("naughty")

local h = require("helpers")
local upower = require("lgi").require("UPowerGlib")

local function emit(ac, perc, time)
  awesome.emit_signal("signal::power", ac, perc, time)
end

local devices = upower.Client():get_devices()

local function update_devices()
  devices = upower.Client():get_devices()
end

local function get_device(target)
  for _, device in ipairs(devices) do
    local device_path = h.join_path("/org/freedesktop/UPower/devices/", target)
    if device:get_object_path() == (device_path) then
      return device
    end
  end
  -- Fall back to the display device if the target device is not found. May result in problems like if you want an AC device but a battery device is returned.
  return upower.Client():get_display_device()
end

local system_battery_good = true

local function power()
  update_devices()
  local ac = get_device("line_power_ACAD").online
  local perc = tonumber(get_device("battery_BAT1").percentage)
  local time = tonumber(get_device("battery_BAT1").time_to_empty)
  emit(ac, perc, time)

  -- Manage device battery
  if (perc > 10) and not system_battery_good then
    system_battery_good = true
  end
  if not ac and (perc <= 10) and system_battery_good then
    naughty.notify({ title = "System battery low (10%)" })
    system_battery_good = false
  end
  if not ac and (perc <= 5) then
    awful.spawn("systemctl suspend")
  end
end

power()

-- luacheck: ignore 211
---@diagnostic disable-next-line: unused-local
local power_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    power()
  end,
})

