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

local lock_button = h.button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "",
  font = b.sysfont(dpi(12)),
  button_press = function()
    awesome.emit_signal('ui::lock::toggle')
    awesome.emit_signal("signal::playerctl::pause", "%all%")
  end
})

local suspend_button = h.timed_button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "",
  font = b.sysfont(dpi(14)),
  button_press = function()
    awful.spawn("systemctl suspend")
  end
}, 1)

local hibernate_button = h.timed_button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "",
  font = b.sysfont(dpi(16)),
  button_press = function()
    awful.spawn("systemctl hibernate")
  end
}, 2)

local poweroff_button = h.timed_button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "󰐥",
  font = b.sysfont(dpi(15)),
  button_press = function()
    awful.spawn("systemctl poweroff")
  end
}, 3)

local restart_button = h.timed_button({
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

local power_menu_items = {
  layout = wibox.layout.fixed.vertical,
}

if user.power.lock then
  table.insert(power_menu_items, lock_button)
end

if user.power.suspend then
  table.insert(power_menu_items, suspend_button)
end

if user.power.hibernate then
  table.insert(power_menu_items, hibernate_button)
end

if user.power.poweroff then
  table.insert(power_menu_items, poweroff_button)
end

if user.power.restart then
  table.insert(power_menu_items, restart_button)
end

power.menu = wibox.widget(power_menu_items)

return power

