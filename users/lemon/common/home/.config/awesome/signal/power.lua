local awful = require("awful")
local gears = require("gears")
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

local function power()
  ac = line.online
  perc = bat.percentage
  time = bat.time_to_empty
  emit()

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

-- luacheck: ignore 211
---@diagnostic disable-next-line: unused-local
local power_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    power()
  end,
})

