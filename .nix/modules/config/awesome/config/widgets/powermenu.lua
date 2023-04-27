local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local locker = require("config.helpers.locker")
local click_to_hide = require("config.helpers.click_to_hide")

--
-- Power management menu
--

local lock = wibox.widget {
  widget = wibox.container.background,
  forced_width = 100,
  forced_height = 100,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
  {
    widget = wibox.widget.textbox,
    text = "󰌾",
    font = beautiful.font_large,
    align = "center",
    valign = "center",
  },
}

local poweroff = wibox.widget {
  widget = wibox.container.background,
  forced_width = 100,
  forced_height = 100,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
  {
    widget = wibox.widget.textbox,
    text = "󰐥",
    font = beautiful.font_large,
    align = "center",
    valign = "center",
  },
}

local restart = wibox.widget {
  widget = wibox.container.background,
  forced_width = 100,
  forced_height = 100,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
  {
    widget = wibox.widget.textbox,
    text = "󰑓",
    font = beautiful.font_large,
    align = "center",
    valign = "center",
  },
}

local powermenu_container = wibox.widget {
  layout = wibox.layout.align.horizontal,
  {
    widget = wibox.container.margin,
    margins = { top = 8, right = 4, bottom = 8, left = 8, },
    {
      layout = wibox.layout.fixed.vertical,
      lock,
    },
  },
  {
    widget = wibox.container.margin,
    margins = { top = 8, right = 4, bottom = 8, left = 4, },
    {
      layout = wibox.layout.fixed.vertical,
      poweroff,
    },
  },
  {
    widget = wibox.container.margin,
    margins = { top = 8, right = 8, bottom = 8, left = 4, },
    {
      layout = wibox.layout.fixed.vertical,
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

powermenu_pop.visible = false

lock:buttons(gears.table.join(awful.button({}, 1, function()
  powermenu_pop.visible = false
  locker.locker()
end)))

lock:connect_signal("mouse::enter", function()
  lock.fg = beautiful.fg_focus
  lock.bg = beautiful.accent
end)

lock:connect_signal("mouse::leave", function()
  lock.fg = beautiful.fg_normal
  lock.bg = beautiful.bg_normal
end)

poweroff:buttons(gears.table.join(awful.button({}, 1, function()
  powermenu_pop.visible = false
  awful.spawn.easy_async("systemctl poweroff")
end)))

poweroff:connect_signal("mouse::enter", function()
  poweroff.fg = beautiful.fg_focus
  poweroff.bg = beautiful.accent
end)

poweroff:connect_signal("mouse::leave", function()
  poweroff.fg = beautiful.fg_normal
  poweroff.bg = beautiful.bg_normal
end)

restart:buttons(gears.table.join(awful.button({}, 1, function()
  powermenu_pop.visible = false
  awful.spawn.easy_async("systemctl reboot")
end)))

restart:connect_signal("mouse::enter", function()
  restart.fg = beautiful.fg_focus
  restart.bg = beautiful.accent
end)

restart:connect_signal("mouse::leave", function()
  restart.fg = beautiful.fg_normal
  restart.bg = beautiful.bg_normal
end)

local function signal()
  powermenu_pop.visible = not powermenu_pop.visible
  powermenu_pop.screen = awful.screen.focused()
end

click_to_hide.popup(powermenu_pop, nil, true)

return { signal = signal }