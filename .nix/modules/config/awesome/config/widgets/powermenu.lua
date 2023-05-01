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

local prompt = wibox.widget {
  widget = wibox.container.background,
  forced_width = 300,
  forced_height = 36,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
  {
    widget = wibox.widget.textbox,
    text = "Are you sure?",
    align = "center",
    valign = "center",
  },
}

local confirmpow = wibox.widget {
  widget = wibox.container.background,
  forced_width = 100,
  forced_height = 56,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
  {
    widget = wibox.widget.textbox,
    text = "Poweroff",
    align = "center",
    valign = "center",
  },
}

local confirmres = wibox.widget {
  widget = wibox.container.background,
  forced_width = 100,
  forced_height = 56,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
  {
    widget = wibox.widget.textbox,
    text = "Restart",
    align = "center",
    valign = "center",
  },
}

local cancel = wibox.widget {
  widget = wibox.container.background,
  forced_width = 200,
  forced_height = 56,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
  {
    widget = wibox.widget.textbox,
    text = "Cancel",
    align = "center",
    valign = "center",
  },
}

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

cancel:buttons(gears.table.join(awful.button({}, 1, function()
  poweroff_pop.visible = false
  restart_pop.visible = false
  powermenu_pop.visible = false
end)))

cancel:connect_signal("mouse::enter", function()
  cancel.fg = beautiful.fg_focus
  cancel.bg = beautiful.accent
end)

cancel:connect_signal("mouse::leave", function()
  cancel.fg = beautiful.fg_normal
  cancel.bg = beautiful.bg_normal
end)

confirmpow:buttons(gears.table.join(awful.button({}, 1, function()
  confirmed("systemctl poweroff")
end)))

confirmres:buttons(gears.table.join(awful.button({}, 1, function()
  confirmed("systemctl reboot")
end)))

confirmpow:connect_signal("mouse::enter", function()
  confirmpow.fg = beautiful.fg_focus
  confirmpow.bg = beautiful.accent
end)

confirmpow:connect_signal("mouse::leave", function()
  confirmpow.fg = beautiful.fg_normal
  confirmpow.bg = beautiful.bg_normal
end)

confirmres:connect_signal("mouse::enter", function()
  confirmres.fg = beautiful.fg_focus
  confirmres.bg = beautiful.accent
end)

confirmres:connect_signal("mouse::leave", function()
  confirmres.fg = beautiful.fg_normal
  confirmres.bg = beautiful.bg_normal
end)

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
  poweroff_pop.visible = true
  powermenu_pop.visible = false
  poweroff_pop.screen = awful.screen.focused()
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
  restart_pop.visible = true
  powermenu_pop.visible = false
  restart_pop.screen = awful.screen.focused()
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
click_to_hide.popup(poweroff_pop, nil, true)
click_to_hide.popup(restart_pop, nil, true)

return { signal = signal }