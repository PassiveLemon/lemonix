local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Power management menu
--

--local lock_icon = helpers.simpleicn(12, 12, 37, 37, 37, 37, nil, os.getenv("HOME") .. "/.config/awesome/libraries/feather/icons/lock.svg", beautiful.fg)
--local poweroff_icon = helpers.simpleicn(12, 12, 37, 37, 37, 37, nil, os.getenv("HOME") .. "/.config/awesome/libraries/feather/icons/power.svg", beautiful.fg)
--local restart_icon = helpers.simpleicn(12, 12, 37, 37, 37, 37, nil, , os.getenv("HOME") .. "/.config/awesome/libraries/feather/icons/refresh-cw.svg", beautiful.fg)

--local lock = helpers.complexbtn(100, 100, 8, 4, 8, 8, lock_icon)
--local poweroff = helpers.complexbtn(100, 100, 8, 4, 8, 4, poweroff_icon)
--local restart = helpers.complexbtn(100, 100, 8, 8, 8, 4, restart_icon)

local lock = helpers.simplebtn(100, 100, 8, 4, 8, 8, "", beautiful.sysfont(24))
local poweroff = helpers.simplebtn(100, 100, 8, 4, 8, 4, "󰐥", beautiful.sysfont(27))
local restart = helpers.simplebtn(100, 100, 8, 8, 8, 4, "󰑓", beautiful.sysfont(31))

local powermenu_widget = wibox.widget {
  layout = wibox.layout.align.vertical,
  {
    layout = wibox.layout.fixed.horizontal,
    lock,
    poweroff,
    restart,
  },
}

local prompt = helpers.simpletxt(308, 36, 8, 8, 4, 8, nil, "Are you sure?", beautiful.sysfont(10), "center")
local confirmpow = helpers.simplebtn(100, 56, 4, 4, 8, 8, "Poweroff", beautiful.sysfont(10))
local confirmres = helpers.simplebtn(100, 56, 4, 4, 8, 8, "Restart", beautiful.sysfont(10))
local cancel = helpers.simplebtn(208, 56, 4, 8, 8, 4, "Cancel", beautiful.sysfont(10))

local poweroff_widget = wibox.widget {
  layout = wibox.layout.align.vertical,
  {
    layout = wibox.layout.fixed.horizontal,
    prompt,
  },
  {
    layout = wibox.layout.fixed.horizontal,
    confirmpow,
    cancel,
  },
}

local restart_widget = wibox.widget {
  layout = wibox.layout.align.vertical,
  {
    layout = wibox.layout.fixed.horizontal,
    prompt,
  },
  {
    layout = wibox.layout.fixed.horizontal,
    confirmres,
    cancel,
  },
}

local powermenu_pop = awful.popup {
  placement = awful.placement.centered,
  border_width = 3,
  border_color = beautiful.border_color_active,
  ontop = true,
  visible = false,
  widget = powermenu_widget,
}

local function confirmed(command)
  powermenu_pop.visible = false
  awful.spawn(command)
end

cancel:connect_signal("button::press", function()
  powermenu_pop.widget = powermenu_widget
end)

confirmpow:connect_signal("button::press", function()
  confirmed("systemctl poweroff")
end)

confirmres:connect_signal("button::press", function()
  confirmed("systemctl reboot")
end)

lock:connect_signal("button::press", function()
  powermenu_pop.visible = false
  helpers.locker()
end)

poweroff:connect_signal("button::press", function()
  powermenu_pop.widget = poweroff_widget
end)

restart:connect_signal("button::press", function()
  powermenu_pop.widget = restart_widget
end)

local function signal()
  powermenu_pop.widget = powermenu_widget
  powermenu_pop.visible = not powermenu_pop.visible
  powermenu_pop.screen = awful.screen.focused()
  helpers.unfocus()
end

click_to_hide.popup(powermenu_pop, nil, true)

return { signal = signal }
