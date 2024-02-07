local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Powermenu
--

local lock_icon = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 100,
  y = 100,
  shape = gears.shape.rounded_rect,
  text = "",
  font = b.sysfont(24),
})
local poweroff_icon = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 100,
  y = 100,
  shape = gears.shape.rounded_rect,
  text = "󰐥",
  font = b.sysfont(27),
})
local restart_icon = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 100,
  y = 100,
  shape = gears.shape.rounded_rect,
  text = "󰑓",
  font = b.sysfont(31),
})

local powermenu_widget = wibox.widget({
layout = wibox.layout.margin,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  {
    layout = wibox.layout.align.vertical,
    {
      layout = wibox.layout.fixed.horizontal,
      lock_icon,
      poweroff_icon,
      restart_icon,
    },
  },
})

local prompt = h.text({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 308,
  y = 36,
  text = "Are you sure?",
})

local poweroff = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 100,
  y = 56,
  shape = gears.shape.rounded_rect,
  text = "Poweroff",
  toggle = false
})
local poweroff_hover = gears.timer({
  timeout = 1,
  single_shot = true,
  callback = function()
    poweroff.toggle = true
    poweroff:get_children_by_id("background")[1].fg = b.fg_focus
  end,
})

local restart = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 100,
  y = 56,
  shape = gears.shape.rounded_rect,
  text = "Restart",
  toggle = false
})
local restart_hover = gears.timer({
  timeout = 1,
  single_shot = true,
  callback = function()
    restart.toggle = true
    restart:get_children_by_id("background")[1].fg = b.fg_focus
  end,
})

local cancel = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 208,
  y = 56,
  shape = gears.shape.rounded_rect,
  text = "Cancel",
})

local poweroff_widget = wibox.widget({
  layout = wibox.layout.margin,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  {
    layout = wibox.layout.align.vertical,
    {
      layout = wibox.layout.fixed.horizontal,
      prompt,
    },
    {
      layout = wibox.layout.fixed.horizontal,
      poweroff,
      cancel,
    },
  },
})

local restart_widget = wibox.widget({
  layout = wibox.layout.margin,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  {
    layout = wibox.layout.align.vertical,
    {
      layout = wibox.layout.fixed.horizontal,
      prompt,
    },
    {
      layout = wibox.layout.fixed.horizontal,
      restart,
      cancel,
    },
  },
})

local main = awful.popup({
  placement = awful.placement.centered,
  border_width = 3,
  border_color = b.border_color_active,
  ontop = true,
  visible = false,
  widget = powermenu_widget,
})

local function confirmed(command)
  main.visible = false
  awful.spawn.with_shell(command)
end

lock_icon:connect_signal("button::press", function()
  confirmed("\
  playerctl pause; \
  i3lock-fancy-rapid 50 10 -n; \
  ")
end)

poweroff_icon:connect_signal("button::press", function()
  main.widget = poweroff_widget
end)

restart_icon:connect_signal("button::press", function()
  main.widget = restart_widget
end)

cancel:connect_signal("button::press", function()
  main.widget = powermenu_widget
end)

poweroff:connect_signal("button::press", function()
  if poweroff.toggle == true then
    confirmed("systemctl poweroff")
  end
end)

poweroff:connect_signal("mouse::enter", function()
  poweroff_hover:again()
end)
poweroff:connect_signal("mouse::leave", function()
  poweroff_hover:stop()
  poweroff.toggle = false
end)

restart:connect_signal("button::press", function()
  if restart.toggle == true then
    confirmed("systemctl reboot")
  end
end)

restart:connect_signal("mouse::enter", function()
  restart_hover:again()
end)
restart:connect_signal("mouse::leave", function()
  restart_hover:stop()
  restart.toggle = false
end)

local function signal()
  main.widget = powermenu_widget
  main.visible = not main.visible
  main.screen = awful.screen.focused()
  h.unfocus()
end

click_to_hide.popup(main, nil, true)

return { signal = signal }

