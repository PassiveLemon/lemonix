local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = {}

function helpers.simpletxt(x, y, txt, fnt, ali, mt, mr, mb, ml)
  local simpletext = wibox.widget {
    widget = wibox.container.margin,
    margins = {
      top = mt,
      right = mr,
      bottom = mb,
      left = ml,
    },
    {
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
    },
  }
  return simpletext
end

function helpers.simplebtn(x, y, txt, fnt, mt, mr, mb, ml)
  local simplebutton = wibox.widget {
    widget = wibox.container.margin,
    margins = {
      top = mt,
      right = mr,
      bottom = mb,
      left = ml,
    },
    {
      id = "background",
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
    },
  }
  simplebutton:connect_signal("mouse::enter", function()
    simplebutton:get_children_by_id("background")[1].fg = beautiful.fg_focus
    simplebutton:get_children_by_id("background")[1].bg = beautiful.accent
  end)
  simplebutton:connect_signal("mouse::leave", function()
    simplebutton:get_children_by_id("background")[1].fg = beautiful.fg_normal
    simplebutton:get_children_by_id("background")[1].bg = beautiful.bg_normal
  end)
  return simplebutton
end

function helpers.simplesldr(x, y, h, w, mt, mr, mb, ml)
  local simpleslider = wibox.widget {
    widget = wibox.container.margin,
    margins = {
      top = mt,
      right = mr,
      bottom = mb,
      left = ml,
    },
    {
      widget = wibox.container.background,
      forced_width = x,
      forced_height = y,
      fg = beautiful.fg_normal,
      bg = beautiful.bg_normal,
      {
        id = "slider",
        widget = wibox.widget.slider,
        minimum = 0,
        maximum = 100,
        bar_height = h,
        handle_width = w,
      },
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