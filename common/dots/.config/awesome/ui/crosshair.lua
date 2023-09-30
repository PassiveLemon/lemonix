local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("helpers")

--
-- Crosshairs
--

local crosshair1_right_pop = awful.popup {
  border_width = 0,
  border_color = beautiful.border_color_active,
  x = 2883,
  y = 537,
  ontop = true,
  visible = false,
  type = "desktop",
  widget = {
    widget = wibox.container.background,
    forced_width = 2,
    forced_height = 7,
    fg = "#00ff00",
    bg = "#00ff00",
  };
}

local crosshair1_bottom_pop = awful.popup {
  border_width = 0,
  border_color = beautiful.border_color_active,
  x = 2875,
  y = 543,
  ontop = true,
  visible = false,
  type = "desktop",
  widget = {
    widget = wibox.container.background,
    forced_width = 10,
    forced_height = 2,
    fg = "#00ff00",
    bg = "#00ff00",
  };
}

local crosshair1_left_pop = awful.popup {
  border_width = 0,
  border_color = beautiful.border_color_active,
  x = 2875,
  y = 537,
  ontop = true,
  visible = false,
  type = "desktop",
  widget = {
    widget = wibox.container.background,
    forced_width = 2,
    forced_height = 7,
    fg = "#00ff00",
    bg = "#00ff00",
  };
}

local function crosshair1()
  crosshair1_right_pop.visible = not crosshair1_right_pop.visible
  crosshair1_right_pop.screen = screen.primary
  crosshair1_bottom_pop.visible = not crosshair1_bottom_pop.visible
  crosshair1_bottom_pop.screen = screen.primary
  crosshair1_left_pop.visible = not crosshair1_left_pop.visible
  crosshair1_left_pop.screen = screen.primary
end

local crosshair2_top_pop = awful.popup {
  border_width = 0,
  border_color = beautiful.border_color_active,
  x = 2873,
  y = 539,
  ontop = true,
  visible = false,
  type = "desktop",
  widget = {
    widget = wibox.container.background,
    forced_width = 14,
    forced_height = 2,
    fg = "#00ff00",
    bg = "#00ff00",
  };
}

local crosshair2_bottom_pop = awful.popup {
  border_width = 0,
  border_color = beautiful.border_color_active,
  x = 2879,
  y = 540,
  ontop = true,
  visible = false,
  type = "desktop",
  widget = {
    widget = wibox.container.background,
    forced_width = 2,
    forced_height = 7,
    fg = "#00ff00",
    bg = "#00ff00",
  };
}

local function crosshair2()
  crosshair2_top_pop.visible = not crosshair2_top_pop.visible
  crosshair2_top_pop.screen = screen.primary
  crosshair2_bottom_pop.visible = not crosshair2_bottom_pop.visible
  crosshair2_bottom_pop.screen = screen.primary
end

local crosshair3_top_pop = awful.popup {
  border_width = 0,
  border_color = beautiful.border_color_active,
  x = 2879,
  y = 537,
  ontop = true,
  visible = false,
  type = "desktop",
  widget = {
    widget = wibox.container.background,
    forced_width = 2,
    forced_height = 2,
    fg = "#00ff00",
    bg = "#00ff00",
  };
}

local crosshair3_right_pop = awful.popup {
  border_width = 0,
  border_color = beautiful.border_color_active,
  x = 2881,
  y = 539,
  ontop = true,
  visible = false,
  type = "desktop",
  widget = {
    widget = wibox.container.background,
    forced_width = 2,
    forced_height = 2,
    fg = "#00ff00",
    bg = "#00ff00",
  };
}

local crosshair3_bottom_pop = awful.popup {
  border_width = 0,
  border_color = beautiful.border_color_active,
  x = 2879,
  y = 541,
  ontop = true,
  visible = false,
  type = "desktop",
  widget = {
    widget = wibox.container.background,
    forced_width = 2,
    forced_height = 2,
    fg = "#00ff00",
    bg = "#00ff00",
  };
}

local crosshair3_left_pop = awful.popup {
  border_width = 0,
  border_color = beautiful.border_color_active,
  x = 2877,
  y = 539,
  ontop = true,
  visible = false,
  type = "desktop",
  widget = {
    widget = wibox.container.background,
    forced_width = 2,
    forced_height = 2,
    fg = "#00ff00",
    bg = "#00ff00",
  };
}

local function crosshair3()
  crosshair3_top_pop.visible = not crosshair3_top_pop.visible
  crosshair3_top_pop.screen = screen.primary
  crosshair3_right_pop.visible = not crosshair3_right_pop.visible
  crosshair3_right_pop.screen = screen.primary
  crosshair3_bottom_pop.visible = not crosshair3_bottom_pop.visible
  crosshair3_bottom_pop.screen = screen.primary
  crosshair3_left_pop.visible = not crosshair3_left_pop.visible
  crosshair3_left_pop.screen = screen.primary
end

local function signal(number)
  if number == 1 then
    crosshair1()
  end
  if number == 2 then
    crosshair2()
  end
  if number == 3 then
    crosshair3()
  end
end

return { signal = signal }

