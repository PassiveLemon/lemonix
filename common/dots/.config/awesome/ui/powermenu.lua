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

local lock = helpers.button({
  margins = {
    top = 8,
    right = 4,
    bottom = 8,
    left = 8,
  },
  x = 100,
  y = 100,
  shape = gears.shape.rounded_rect,
  text = "",
  font = beautiful.sysfont(24),
})
local poweroff = helpers.button({
  margins = {
    top = 8,
    right = 4,
    bottom = 8,
    left = 4,
  },
  x = 100,
  y = 100,
  shape = gears.shape.rounded_rect,
  text = "󰐥",
  font = beautiful.sysfont(27),
})
local restart = helpers.button({
  margins = {
    top = 8,
    right = 8,
    bottom = 8,
    left = 4,
  },
  x = 100,
  y = 100,
  shape = gears.shape.rounded_rect,
  text = "󰑓",
  font = beautiful.sysfont(31),
})

local powermenu_widget = wibox.widget {
  layout = wibox.layout.align.vertical,
  {
    layout = wibox.layout.fixed.horizontal,
    lock,
    poweroff,
    restart,
  },
}

local prompt = helpers.text({
  margins = {
    top = 8,
    right = 8,
    bottom = 4,
    left = 8,
  },
  x = 308,
  y = 36,
  text = "Are you sure?",
})
local confirmpow = helpers.button({
  margins = {
    top = 4,
    right = 4,
    bottom = 8,
    left = 8,
  },
  x = 100,
  y = 56,
  shape = gears.shape.rounded_rect,
  text = "Poweroff",
})
local confirmres = helpers.button({
  margins = {
    top = 4,
    right = 4,
    bottom = 8,
    left = 8,
  },
  x = 100,
  y = 56,
  shape = gears.shape.rounded_rect,
  text = "Restart",
})
local cancel = helpers.button({
  margins = {
    top = 4,
    right = 8,
    bottom = 8,
    left = 4,
  },
  x = 208,
  y = 56,
  shape = gears.shape.rounded_rect,
  text = "Cancel",
})

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

local main = awful.popup {
  placement = awful.placement.centered,
  border_width = 3,
  border_color = beautiful.border_color_active,
  ontop = true,
  visible = false,
  widget = powermenu_widget,
}

local function confirmed(command)
  main.visible = false
  awful.spawn(command)
end

cancel:connect_signal("button::press", function()
  main.widget = powermenu_widget
end)

confirmpow:connect_signal("button::press", function()
  confirmed("systemctl poweroff")
end)

confirmres:connect_signal("button::press", function()
  confirmed("systemctl reboot")
end)

lock:connect_signal("button::press", function()
  main.visible = false
  helpers.locker()
end)

poweroff:connect_signal("button::press", function()
  main.widget = poweroff_widget
end)

restart:connect_signal("button::press", function()
  main.widget = restart_widget
end)

local function signal()
  main.widget = powermenu_widget
  main.visible = not main.visible
  main.screen = awful.screen.focused()
  helpers.unfocus()
end

click_to_hide.popup(main, nil, true)

return { signal = signal }
