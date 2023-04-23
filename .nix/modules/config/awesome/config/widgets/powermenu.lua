local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local click_to_hide = require("config.helpers.click_to_hide")


--
-- Power management menu
--

local powermenu_pop_vis = false

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

lock:buttons(gears.table.join(awful.button({}, 1, function()
  awesome.emit_signal("signal::powermenu")
  awful.spawn.easy_async_with_shell("dm-tool switch-to-greeter")
end)))

lock:connect_signal("mouse::enter", function()
  lock.fg = beautiful.fg_focus
  lock.bg = beautiful.accent
end)

lock:connect_signal("mouse::leave", function()
  lock.fg = beautiful.fg_normal
  lock.bg = beautiful.bg_normal
end)

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

poweroff:buttons(gears.table.join(awful.button({}, 1, function()
  awesome.emit_signal("signal::powermenu")
end)))

poweroff:connect_signal("mouse::enter", function()
  poweroff.fg = beautiful.fg_focus
  poweroff.bg = beautiful.accent
end)

poweroff:connect_signal("mouse::leave", function()
  poweroff.fg = beautiful.fg_normal
  poweroff.bg = beautiful.bg_normal
end)

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

restart:buttons(gears.table.join(awful.button({}, 1, function()
  awesome.emit_signal("signal::powermenu")
end)))

restart:connect_signal("mouse::enter", function()
  restart.fg = beautiful.fg_focus
  restart.bg = beautiful.accent
end)

restart:connect_signal("mouse::leave", function()
  restart.fg = beautiful.fg_normal
  restart.bg = beautiful.bg_normal
end)

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
  visible = powermenu_pop_vis,
  border_width = 2,
  border_color = beautiful.border_color_active,
}

awesome.connect_signal("signal::powermenu", function()
  powermenu_pop_vis = not powermenu_pop_vis
  powermenu_pop.visible = powermenu_pop_vis
  powermenu_pop.screen = awful.screen.focused()
end)

click_to_hide.popup(powermenu_pop, nil, true)