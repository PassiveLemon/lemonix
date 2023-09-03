local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = { }

function helpers.simplebase(x, y, mt, mr, mb, ml, shape, widgetpass)
  local simplebase = wibox.widget {
    id = "margin",
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
      shape = shape,
      {
        widget = widgetpass,
      },
    },
  }
  return simplebase
end

-- @@ It appears that I cannot dynamically edit the text for one of these text widgets. Need to look into.

function helpers.simpletxt(x, y, mt, mr, mb, ml, shape, txt, fnt, ali)
  local simpletext = wibox.widget {
    id = "textbox",
    widget = wibox.widget.textbox,
    text = txt,
    font = fnt,
    align = ali,
    valign = "center",
  }
  return helpers.simplebase(x, y, mt, mr, mb, ml, nil, simpletext)
end

function helpers.simpleimg(x, y, img, mt, mr, mb, ml)
  local simpleimage = wibox.widget {
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = mt,
      right = mr,
      bottom = mb,
      left = ml,
    },
    {
      id = "constraint",
      widget = wibox.container.constraint,
      forced_width = x,
      forced_height = y,
      shape = gears.shape.rounded_rect,
      {
        id = "imagebox",
        widget = wibox.widget.imagebox,
        resize = true,
        image = img,
      },
    },
  }
  return simpleimage
end

function helpers.simpleicn(x, y, mt, mr, mb, ml, shape, img, color)
  local simpleicon = wibox.widget {
    id = "imagebox",
    widget = wibox.widget.imagebox,
    resize = true,
    image = gears.color.recolor_image(img, color),
    forced_width = x,
    forced_height = y,
    valign = "center",
    halign = "center",
  }
  --return helpers.simplebase(x, y, mt, mr, mb, ml, nil, simpleicon)
end

function helpers.complexbtn(x, y, mt, mr, mb, ml, widgetpass)
  local complexbutton = wibox.widget {
    id = "margin",
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
        widget = widgetpass,
      },
    },
  }
  complexbutton:get_children_by_id("background")[1]:connect_signal("mouse::enter", function()
    complexbutton:get_children_by_id("background")[1].fg = beautiful.fg_focus
    complexbutton:get_children_by_id("background")[1].bg = beautiful.bg_minimize
  end)
  complexbutton:get_children_by_id("background")[1]:connect_signal("mouse::leave", function()
    complexbutton:get_children_by_id("background")[1].fg = beautiful.fg_normal
    complexbutton:get_children_by_id("background")[1].bg = beautiful.bg_normal
  end)
  return complexbutton
end

function helpers.simplebtn(x, y, txt, fnt, mt, mr, mb, ml)
  local simplebutton = wibox.widget {
    id = "margin",
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
  simplebutton:get_children_by_id("background")[1]:connect_signal("mouse::enter", function()
    simplebutton:get_children_by_id("background")[1].fg = beautiful.fg_focus
    simplebutton:get_children_by_id("background")[1].bg = beautiful.bg_minimize
  end)
  simplebutton:get_children_by_id("background")[1]:connect_signal("mouse::leave", function()
    simplebutton:get_children_by_id("background")[1].fg = beautiful.fg_normal
    simplebutton:get_children_by_id("background")[1].bg = beautiful.bg_normal
  end)
  return simplebutton
end

function helpers.simplesldr(x, y, w, h, max, mt, mr, mb, ml)
  local simpleslider = wibox.widget {
    id = "margin",
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
      {
        id = "slider",
        widget = wibox.widget.slider,
        minimum = 0,
        maximum = max,
        handle_shape = gears.shape.circle,
        handle_color = beautiful.fg_normal,
        handle_width = 0,
        bar_height = h,
        bar_shape = gears.shape.rounded_rect,
        bar_color = beautiful.bg_minimize,
        bar_active_color = beautiful.fg_normal,
      },
    },
  }
  simpleslider:get_children_by_id("background")[1]:connect_signal("mouse::enter", function()
    simpleslider:get_children_by_id("slider")[1].handle_width = w
    simpleslider:get_children_by_id("slider")[1].bar_active_color = beautiful.fg_minimize
  end)
  simpleslider:get_children_by_id("background")[1]:connect_signal("mouse::leave", function()
    simpleslider:get_children_by_id("slider")[1].handle_width = 0
    simpleslider:get_children_by_id("slider")[1].bar_active_color = beautiful.fg_normal
  end)
  return simpleslider
end

function helpers.simplesldrhdn(x, y, w, h, max, mt, mr, mb, ml)
  local simplesliderhidden = wibox.widget {
    id = "margin",
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
      bg = "#00000000",
      {
        id = "slider",
        widget = wibox.widget.slider,
        minimum = 0,
        maximum = max,
        handle_shape = gears.shape.circle,
        handle_color = beautiful.fg_normal,
        handle_width = 0,
        bar_height = h,
        bar_shape = gears.shape.rounded_rect,
        bar_color = "#00000000",
        bar_active_color = "#00000000",
      },
    },
  }
  simplesliderhidden:get_children_by_id("background")[1]:connect_signal("mouse::enter", function()
    simplesliderhidden:get_children_by_id("slider")[1].handle_width = w
  end)
  simplesliderhidden:get_children_by_id("background")[1]:connect_signal("mouse::leave", function()
    simplesliderhidden:get_children_by_id("slider")[1].handle_width = 0
  end)
  return simplesliderhidden
end

function helpers.simpleprog(x, y, w, max, mt, mr, mb, ml)
  local simpleprogressbar = wibox.widget {
    id = "margin",
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
      {
        id = "progressbar",
        widget = wibox.widget.progressbar,
        color = beautiful.fg_normal,
        background_color = beautiful.bg_minimize,
        shape = gears.shape.rounded_rect,
        max_value = max,
        margins = { top = 6, bottom = 6,},
        forced_height = y,
        forced_width = w,
      },
    },
  }
  return simpleprogressbar
end

function helpers.simplernd(number, place)
  local decimal = 10 ^ place
  local rounded = math.floor(number * decimal + 0.5) / decimal
  return rounded
end

function helpers.simplewtch(com, time)
  local simplewatch = wibox.widget {
    widget = wibox.widget.textbox,
    align = "left",
    valign = "center",
  }
  awful.widget.watch(com, time, function(_, stdout)
    simplewatch.markup = stdout:gsub( "\n", "" )
  end)
  return simplewatch
end

function helpers.unfocus()
  client.focus = nil
  client.focus = awful.client.next(0)
  if client.focus then
      client.focus:raise()
  end
end

function helpers.locker()
  awful.spawn.with_shell("\
  playerctl pause; \
  i3lock-fancy-rapid 50 10 -n; \
  ")
end

return helpers
