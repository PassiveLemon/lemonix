local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("config.helpers.helpers")
local click_to_hide = require("config.helpers.click_to_hide")

--
-- Power management menu
--

local lock = helpers.simplebtn(100, 100, "󰐥", beautiful.font_large)

local poweroff = helpers.simplebtn(100, 100, "󰐥", beautiful.font_large)

local restart = helpers.simplebtn(100, 100, "󰑓", beautiful.font_large)

local powermenu_container = wibox.widget {
  layout = wibox.layout.align.vertical,
  {
    widget = wibox.container.margin,
    margins = { top = 8, right = 8, bottom = 8, left = 8, },
    {
      layout = wibox.layout.fixed.horizontal,
      lock,
      poweroff,
      restart,
    },
  },
}

local powermenu_pop = awful.popup {
  widget = powermenu_container,
  placement = awful.placement.centered,
  ontop = true,
  border_width = 2,
  border_color = beautiful.border_color_active,
}

local prompt = helpers.simpletxt(300, 36, "Are you sure?", beautiful.font, "center")

local confirmpow = helpers.simplebtn(100, 56, "Poweroff")

local confirmres = helpers.simplebtn(100, 56, "Restart")

local cancel = helpers.simplebtn(200, 56, "Cancel")

local poweroff_container = wibox.widget {
  layout = wibox.layout.align.vertical,
  {
    widget = wibox.container.margin,
    margins = { top = 8, right = 8, bottom = 4, left = 8, },
    {
      layout = wibox.layout.fixed.horizontal,
      prompt,
    },
  },
  {
    widget = wibox.container.margin,
    margins = { top = 4, right = 8, bottom = 8, left = 8, },
    {
      layout = wibox.layout.fixed.horizontal,
      confirmpow,
      cancel,
    },
  },
}

local restart_container = wibox.widget {
  layout = wibox.layout.align.vertical,
  {
    widget = wibox.container.margin,
    margins = { top = 8, right = 8, bottom = 4, left = 8, },
    {
      layout = wibox.layout.fixed.horizontal,
      prompt,
    },
  },
  {
    widget = wibox.container.margin,
    margins = { top = 4, right = 8, bottom = 8, left = 8, },
    {
      layout = wibox.layout.fixed.horizontal,
      confirmres,
      cancel,
    },
  },
}

local poweroff_pop = awful.popup {
  widget = poweroff_container,
  placement = awful.placement.centered,
  ontop = true,
  border_width = 2,
  border_color = beautiful.border_color_active,
}

local restart_pop = awful.popup {
  widget = restart_container,
  placement = awful.placement.centered,
  ontop = true,
  border_width = 2,
  border_color = beautiful.border_color_active,
}

powermenu_pop.visible = false
poweroff_pop.visible = false
restart_pop.visible = false

local function confirmed(command)
  poweroff_pop.visible = false
  restart_pop.visible = false
  powermenu_pop.visible = false
  awful.spawn(command)
end

cancel:connect_signal("button::press", function()
  poweroff_pop.visible = false
  restart_pop.visible = false
  powermenu_pop.visible = false
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
  poweroff_pop.visible = true
  powermenu_pop.visible = false
  poweroff_pop.screen = awful.screen.focused()
end)

restart:connect_signal("button::press", function()
  restart_pop.visible = true
  powermenu_pop.visible = false
  restart_pop.screen = awful.screen.focused()
end)

local function signal()
  powermenu_pop.visible = not powermenu_pop.visible
  powermenu_pop.screen = awful.screen.focused()
end

click_to_hide.popup(powermenu_pop, nil, true)
click_to_hide.popup(poweroff_pop, nil, true)
click_to_hide.popup(restart_pop, nil, true)

return { signal = signal }