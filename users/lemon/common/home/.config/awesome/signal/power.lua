local awful = require("awful")
local naughty = require("naughty")

local upower = require("lgi").require("UPowerGlib")
local devices = upower.Client():get_devices()

local function get_device(target)
  for _, device in ipairs(devices) do
    if device.kind == target then
      return device
    end
  end
end

local line = get_device(upower.DeviceKind.LINE_POWER)
local bat = get_device(upower.DeviceKind.BATTERY)

-- State
local ac = line.online
local perc = bat.percentage
local time = bat.time_to_empty

local function emit()
  awesome.emit_signal("signal::power", ac, perc, time)
end

local system_battery_good = true

local function power_manage()
  -- Reset battery state if charged enough or plugged in
  if ac or ((perc > 10) and not system_battery_good) then
    system_battery_good = true
  end
  -- If not plugged in, battery is less than 10%, and state is still "good" then warn
  if not ac and (perc <= 10) and system_battery_good then
    naughty.notify({ title = "System battery low (10%)" })
    system_battery_good = false
  end
  -- If not plugged in and battery drops below 5%, then suspend
  if not ac and (perc <= 5) then
    awful.spawn("systemctl suspend")
  end
end

line.on_notify["online"] = function(self)
  ac = self.online
  emit()
end

bat.on_notify["percentage"] = function(self)
  perc = self.percentage
  time = self.time_to_empty
  emit()
  if not ac then
    power_manage()
  end
end

