local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = {}

function helpers.text(txt, fnt, ali)
  local text = wibox.widget {
    widget = wibox.widget.textbox,
    text = txt,
    font = fnt,
    align = ali,
    valign = "center",
  }
return text
end

function helpers.simpletxt(x, y, txt, fnt, ali)
  local simpletext = wibox.widget {
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
return simpletext
end

function helpers.simplebtn(x, y, txt, fnt)
  local simplebutton = wibox.widget {
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
  simplebutton:connect_signal("mouse::enter", function()
    simplebutton.fg = beautiful.fg_focus
    simplebutton.bg = beautiful.accent
  end)
  simplebutton:connect_signal("mouse::leave", function()
    simplebutton.fg = beautiful.fg_normal
    simplebutton.bg = beautiful.bg_normal
  end)
return simplebutton
end

function helpers.simplesldr(x, y, h, w)
  local simpleslider = wibox.widget {
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
return simpleslider
end

function helpers.simplewtch(com, time)
  local simplewatch = wibox.widget {
    widget = wibox.widget.textbox,
    align = "left",
    valign = "center",
  }
  awful.widget.watch(com, time, function(_, stdout)
    simplewatch.text = stdout:gsub( "\n", "" )
  end)
return simplewatch
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