local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Powermenu
--

local lock = h.button({
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
  font = b.sysfont(24),
})
local poweroff = h.button({
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
  font = b.sysfont(27),
})
local restart = h.button({
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
  font = b.sysfont(31),
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

local prompt = h.text({
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
local confirm_pow = h.button({
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
local confirm_res = h.button({
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
local cancel = h.button({
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

local poweroff_widget = wibox.widget({
  layout = wibox.layout.align.vertical,
  {
    layout = wibox.layout.fixed.horizontal,
    prompt,
  },
  {
    layout = wibox.layout.fixed.horizontal,
    confirm_pow,
    cancel,
  },
})

local restart_widget = wibox.widget({
  layout = wibox.layout.align.vertical,
  {
    layout = wibox.layout.fixed.horizontal,
    prompt,
  },
  {
    layout = wibox.layout.fixed.horizontal,
    confirm_res,
    cancel,
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
  awful.spawn(command)
end

cancel:connect_signal("button::press", function()
  main.widget = powermenu_widget
end)

confirm_pow:connect_signal("button::press", function()
  confirmed("systemctl poweroff")
end)

confirm_res:connect_signal("button::press", function()
  confirmed("systemctl reboot")
end)

lock:connect_signal("button::press", function()
  main.visible = false
  awful.spawn.with_shell("\
  playerctl pause; \
  i3lock-fancy-rapid 50 10 -n; \
  ")
end)

poweroff:connect_signal("button::press", function()
  main.widget = poweroff_widget
end)

restart:connect_signal("button::press", function()
  main.widget = restart_widget
end)

awesome.connect_signal("ui::power::toggle", function()
  main.widget = powermenu_widget
  main.visible = not main.visible
  main.screen = awful.screen.focused()
  h.unfocus()
end)

click_to_hide.popup(main, nil, true)

return { signal = signal }
