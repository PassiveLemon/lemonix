local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = {}

function helpers.simpletxt(x, y, txt, fnt, ali)
  local button = wibox.widget {
    widget = wibox.container.background,
    forced_width = x,
    forced_height = y,
    fg = beautiful.fg_normal,
    bg = beautiful.bg_normal,
    shape = gears.shape.rounded_rect,
    {
      id = "textbox",
      widget = wibox.widget.textbox,
      text = txt,
      font = fnt,
      align = ali,
      valign = "center",
    },
  }
return text
end

function helpers.simplebtn(x, y, txt, fnt)
  local button = wibox.widget {
    widget = wibox.container.background,
    forced_width = x,
    forced_height = y,
    fg = beautiful.fg_normal,
    bg = beautiful.bg_normal,
    shape = gears.shape.rounded_rect,
    {
      id = "textbox",
      widget = wibox.widget.textbox,
      text = txt,
      font = fnt,
      align = "center",
      valign = "center",
    },
  }
  button:connect_signal("mouse::enter", function()
    button.fg = beautiful.fg_focus
    button.bg = beautiful.accent
  end)
  button:connect_signal("mouse::leave", function()
    button.fg = beautiful.fg_normal
    button.bg = beautiful.bg_normal
  end)
return button
end

function helpers.simplesldr(x, y, h, w)
  local slider = wibox.widget {
    widget = wibox.container.background,
    forced_width = x,
    forced_height = y,
    fg = beautiful.fg_normal,
    bg = beautiful.bg_normal,
    {
      id = "slider",
      widget = wibox.widget.slider,
      maximum = 100,
      bar_height = 6,
      handle_width = 15,
    },
  }
return slider
end

function helpers.locker()
  awful.spawn([[sh -c " \
  playerctl pause; \
  xrandr --output DP-0 --brightness 0.5; \
  xrandr --output DP-2 --brightness 0.5; \
  i3lock-fancy-rapid 50 10 -n; \
  xrandr --output DP-0 --brightness 1; \
  xrandr --output DP-2 --brightness 1; \
  "]])
end

return helpers