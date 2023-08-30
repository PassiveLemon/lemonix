local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("helpers")

local crosshair_bottom_pop = awful.popup {
  border_width = 0,
  border_color = beautiful.border_color_active,
  x = 2875,
  y = 544,
  ontop = true,
  visible = false,
  widget = {
    widget = wibox.container.background,
    forced_width = 10,
    forced_height = 1,
    fg = "#ff0000",
    bg = "#ff0000",
  };
}

local crosshair_right_pop = awful.popup {
  border_width = 0,
  border_color = beautiful.border_color_active,
  x = 2884,
  y = 536,
  ontop = true,
  visible = false,
  widget = {
    widget = wibox.container.background,
    forced_width = 1,
    forced_height = 8,
    fg = "#00ff00",
    bg = "#00ff00",
  };
}

local crosshair_left_pop = awful.popup {
  border_width = 0,
  border_color = beautiful.border_color_active,
  x = 2875,
  y = 536,
  ontop = true,
  visible = false,
  widget = {
    widget = wibox.container.background,
    forced_width = 1,
    forced_height = 8,
    fg = "#0000ff",
    bg = "#0000ff",
  };
}

local function signal()
  crosshair_bottom_pop.visible = not crosshair_bottom_pop.visible
  crosshair_bottom_pop.screen = screen.primary
  crosshair_right_pop.visible = not crosshair_right_pop.visible
  crosshair_right_pop.screen = screen.primary
  crosshair_left_pop.visible = not crosshair_left_pop.visible
  crosshair_left_pop.screen = screen.primary
end

return { signal = signal }

