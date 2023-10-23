local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Control panel [[WIP]]
--

-- Systray
local systray_pop = awful.popup {
  border_width = 0,
  border_color = b.border_color_active,
  ontop = true,
  visible = false,
  type = "desktop",
  widget = {
    id = "background",
    widget = wibox.container.background,
    forced_width = 384,
    forced_height = 26,
    bg = b.bg_normal,
    {
      layout = wibox.layout.fixed.horizontal,
      wibox.widget.systray,
    },
  },
}

local systray_autohider = gears.timer {
  timeout = 2,
  single_shot = true,
  callback = function()
    systray_pop.visible = false
  end,
}

local function signal()
  systray_pop.visible = not systray_pop.visible
  systray_pop.screen = awful.screen.focused()
end

click_to_hide.popup(systray_pop, nil, true)

return { signal = signal }
