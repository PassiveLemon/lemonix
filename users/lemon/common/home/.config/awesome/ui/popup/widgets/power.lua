local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local user = require("config.user")

local dpi = b.xresources.apply_dpi

--
-- Power
--

local power = { }

power.lock_button = h.button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "",
  font = b.sysfont(dpi(12)),
  button_press = function()
    awesome.emit_signal('ui::lock::toggle')
    awesome.emit_signal("signal::mpris::pause", "%all%")
  end
})

power.suspend_button = h.timed_button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "",
  font = b.sysfont(dpi(14)),
  button_press = function()
    awful.spawn("systemctl suspend")
  end
}, 1)

power.hibernate_button = h.timed_button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "",
  font = b.sysfont(dpi(16)),
  button_press = function()
    awful.spawn("systemctl hibernate")
  end
}, 2)

power.poweroff_button = h.timed_button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "󰐥",
  font = b.sysfont(dpi(15)),
  button_press = function()
    awful.spawn("systemctl poweroff")
  end
}, 3)

power.restart_button = h.timed_button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "󰑓",
  font = b.sysfont(dpi(18)),
  button_press = function()
    awful.spawn("systemctl reboot")
  end
}, 5)

power.button = h.button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "󰐥",
  font = b.sysfont(dpi(15)),
})

local power_menu_order = {
  "lock",
  "suspend",
  "hibernate",
  "poweroff",
  "restart",
}

local power_menu_items = {
  layout = wibox.layout.fixed.vertical,
}

-- Dynamically add power options to the menu based on what the device is capable of (at user discretion)
for _, v in ipairs(power_menu_order) do
  if user.power[v] then
    table.insert(power_menu_items, power[v .. "_button"])
  end
end

power.menu = wibox.widget(power_menu_items)

return power

