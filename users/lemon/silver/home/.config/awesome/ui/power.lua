local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Powermenu
--

local lock_button = h.button({
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

local poweroff_button = h.button({
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

local restart_button = h.button({
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
  widget = wibox.container.margin,
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
      lock_button,
      poweroff_button,
      restart_button,
    },
  },
})

local prompt_text = h.text({
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

local poweroff_confirm_button = h.button({
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
  toggle = false,
})
local poweroff_confirm_hover = gears.timer({
  timeout = 1,
  single_shot = true,
  callback = function()
    poweroff_confirm_button.toggle = true
    poweroff_confirm_button:get_children_by_id("background")[1].fg = b.fg_focus
  end,
})

local restart_confirm_button = h.button({
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
  toggle = false,
})
local restart_confirm_hover = gears.timer({
  timeout = 1,
  single_shot = true,
  callback = function()
    restart_confirm_button.toggle = true
    restart_confirm_button:get_children_by_id("background")[1].fg = b.fg_focus
  end,
})

local cancel_button = h.button({
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
  widget = wibox.container.margin,
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
      prompt_text,
    },
    {
      layout = wibox.layout.fixed.horizontal,
      poweroff_confirm_button,
      cancel_button,
    },
  },
})

local restart_widget = wibox.widget({
  widget = wibox.container.margin,
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
      prompt_text,
    },
    {
      layout = wibox.layout.fixed.horizontal,
      restart_confirm_button,
      cancel_button,
    },
  },
})

local main = awful.popup({
  placement = awful.placement.centered,
  border_width = 3,
  border_color = b.border_color_active,
  ontop = true,
  visible = false,
  type = "dock",
  widget = powermenu_widget,
})

local function confirmed(command)
  main.visible = false
  awful.spawn.with_shell(command)
end

lock_button:connect_signal("button::press", function()
  main.visible = false
  awesome.emit_signal('ui::lock::toggle')
  awesome.emit_signal("signal::playerctl::pause")
end)

poweroff_button:connect_signal("button::press", function()
  main.widget = poweroff_widget
end)

restart_button:connect_signal("button::press", function()
  main.widget = restart_widget
end)

cancel_button:connect_signal("button::press", function()
  main.widget = powermenu_widget
end)

poweroff_confirm_button:connect_signal("button::press", function()
  if poweroff_confirm_button.toggle == true then
    confirmed("systemctl poweroff")
  end
end)

poweroff_confirm_button:connect_signal("mouse::enter", function()
  poweroff_confirm_hover:again()
end)
poweroff_confirm_button:connect_signal("mouse::leave", function()
  poweroff_confirm_hover:stop()
  poweroff_confirm_button.toggle = false
end)

restart_confirm_button:connect_signal("button::press", function()
  if restart_confirm_button.toggle == true then
    confirmed("systemctl reboot")
  end
end)

restart_confirm_button:connect_signal("mouse::enter", function()
  restart_confirm_hover:again()
end)
restart_confirm_button:connect_signal("mouse::leave", function()
  restart_confirm_hover:stop()
  restart_confirm_button.toggle = false
end)

awesome.connect_signal("ui::power::toggle", function()
  main.widget = powermenu_widget
  main.screen = awful.screen.focused()
  main.visible = not main.visible
  h.unfocus()
end)

click_to_hide.popup(main, nil, true)

