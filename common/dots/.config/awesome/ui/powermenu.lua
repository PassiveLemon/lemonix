local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("modules.helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Power management menu
--

local lock = helpers.simplebtn(100, 100, "", beautiful.font_large, 8, 4, 8, 8)

local poweroff = helpers.simplebtn(100, 100, "󰐥", beautiful.font_large, 8, 4, 8, 4)

local restart = helpers.simplebtn(100, 100, "󰑓", beautiful.font_large, 8, 8, 8, 4)

local powermenu_widget = wibox.widget {
  layout = wibox.layout.align.vertical,
  {
    layout = wibox.layout.fixed.horizontal,
    lock,
    poweroff,
    restart,
  },
}

local prompt = helpers.simpletxt(308, 36, "Are you sure?", beautiful.font, "center", 8, 8, 4, 8)

local confirmpow = helpers.simplebtn(100, 56, "Poweroff", beautiful.font, 4, 4, 8, 8)

local confirmres = helpers.simplebtn(100, 56, "Restart", beautiful.font, 4, 4, 8, 8)

local cancel = helpers.simplebtn(208, 56, "Cancel", beautiful.font, 4, 8, 8, 4)

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
