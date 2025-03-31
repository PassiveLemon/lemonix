local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- NixOS/Systray
--

local systray = { }

local sep = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = " ",
})

systray.pill_systray = h.timed_widget(h.margin({
  widget = wibox.container.place,
  valign = "center",
  halign = "center",
  forced_height = dpi(24),
  {
    widget = wibox.container.background,
    bg = b.bg_secondary,
    shape = gears.shape.rounded_bar,
    forced_height = dpi(24),
    {
      layout = wibox.layout.fixed.horizontal,
      sep,
      wibox.widget.systray,
    },
  },
},
{
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(2),
  },
}), 3, true)

systray.pill_nixos = h.button({
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(4),
  },
  x = dpi(24),
  y = dpi(24),
  shape = gears.shape.circle,
  text = "",
  font = b.sysfont(dpi(16)),
  button_press = function()
    systray.pill_systray.screen = awful.screen.focused()
    systray.pill_systray:toggle()
  end,
})

return systray

