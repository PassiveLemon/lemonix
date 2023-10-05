local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = { }

function helpers.text(conf)
  conf = conf or { }
  local text = wibox.widget {
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins.top or 0,
      right = conf.margins.right or 0,
      bottom = conf.margins.bottom or 0,
      left = conf.margins.left or 0,
    },
    {
      id = "background",
      widget = wibox.container.background,
      forced_width = conf.x,
      forced_height = conf.y,
      fg = conf.fg or beautiful.fg_normal,
      bg = conf.bg or beautiful.bg_normal,
      {
        -- Allow use of either text or image
        layout = wibox.layout.stack,
        {
          id = "textbox",
          widget = wibox.widget.textbox,
          markup = conf.markup,
          text = conf.text,
          font = conf.font or beautiful.sysfont(10),
          halign = conf.halign or "center",
          valign = conf.valign or "center",
        },
        {
          id = "imagebox",
          widget = wibox.widget.imagebox,
          resize = conf.resize,
          image = conf.image,
        },
      }
    },
  }
  return text
end

function helpers.button(conf)
  conf = conf or { }
  local button = wibox.widget {
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins.top or 0,
      right = conf.margins.right or 0,
      bottom = conf.margins.bottom or 0,
      left = conf.margins.left or 0,
    },
    {
      id = "background",
      widget = wibox.container.background,
      forced_width = conf.x,
      forced_height = conf.y,
      fg = conf.fg or beautiful.fg_normal,
      bg = conf.bg or beautiful.bg_normal,
      shape = conf.shape,
      {
        -- Allow use of either text or image
        layout = wibox.layout.stack,
        {
          id = "textbox",
          widget = wibox.widget.textbox,
          markup = conf.markup,
          text = conf.text,
          font = conf.font or beautiful.sysfont(10),
          halign = conf.halign or "center",
          valign = conf.valign or "center",
        },
        {
          id = "imagebox",
          widget = wibox.widget.imagebox,
          resize = conf.resize,
          image = conf.image,
        },
      }
    },
  }
  button:get_children_by_id("background")[1]:connect_signal("mouse::enter", function()
    button:get_children_by_id("background")[1].fg = conf.fg_focus or beautiful.fg_focus
    button:get_children_by_id("background")[1].bg = conf.bg or beautiful.bg_minimize
  end)
  button:get_children_by_id("background")[1]:connect_signal("mouse::leave", function()
    button:get_children_by_id("background")[1].fg = conf.fg or beautiful.fg_normal
    button:get_children_by_id("background")[1].bg = conf.bg or beautiful.bg_normal
  end)
  return button
end

function helpers.slider(conf)
  conf = conf or { }
  local slider = wibox.widget {
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins.top or 0,
      right = conf.margins.right or 0,
      bottom = conf.margins.bottom or 0,
      left = conf.margins.left or 0,
    },
    {
      id = "background",
      widget = wibox.container.background,
      forced_width = conf.x,
      forced_height = conf.y,
      fg = conf.fg or beautiful.fg_normal,
      bg = conf.bg or beautiful.bg_normal,
      {
        id = "slider",
        widget = wibox.widget.slider,
        minimum = conf.min or 0,
        maximum = conf.max,
        handle_shape = conf.handle_shape or gears.shape.circle,
        handle_color = conf.handle_color or beautiful.fg_normal,
        handle_width = 0,
        bar_height = conf.bar_height,
        bar_shape = conf.bar_shape,
        bar_color = conf.bar_color or beautiful.bg_minimize,
        bar_active_color = conf.bar_active_color or beautiful.fg_normal,
      },
    },
  }
  slider:get_children_by_id("background")[1]:connect_signal("mouse::enter", function()
    slider:get_children_by_id("slider")[1].handle_width = conf.handle_width
    slider:get_children_by_id("slider")[1].bar_active_color = conf.bar_active_color or beautiful.fg_minimize
  end)
  slider:get_children_by_id("background")[1]:connect_signal("mouse::leave", function()
    slider:get_children_by_id("slider")[1].handle_width = 0
    slider:get_children_by_id("slider")[1].bar_active_color = conf.bar_active_color or beautiful.fg_normal
  end)
  return slider
end

function helpers.progressbar(conf)
  conf = conf or { }
  local progressbar = wibox.widget {
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins.top or 0,
      right = conf.margins.right or 0,
      bottom = conf.margins.bottom or 0,
      left = conf.margins.left or 0,
    },
    {
      id = "background",
      widget = wibox.container.background,
      forced_width = conf.x,
      forced_height = conf.y,
      fg = conf.fg or beautiful.fg_normal,
      bg = conf.bg or beautiful.bg_normal,
      {
        id = "progressbar",
        widget = wibox.widget.progressbar,
        color = conf.color or beautiful.fg_normal,
        background_color = conf.background_color or beautiful.bg_minimize,
        shape = conf.shape,
        max_value = conf.max,
        margins = {
          top = conf.progmargins.top or 0,
          right = conf.progmargins.right or 0,
          bottom = conf.progmargins.bottom or 0,
          left = conf.progmargins.left or 0,
        },
        forced_width = conf.forced_width,
        forced_height = conf.forced_height,
      },
    },
  }
  return progressbar
end

function helpers.round(number, place)
  local decimal = (10 ^ place)
  return (math.floor((number * decimal) + (5 / decimal)) / decimal)
end

function helpers.watch(com, time)
  local watch = helpers.text({
    margins = {
      top = 0,
      right = 0,
      bottom = 0,
      left = 0,
    },
    halign = "left"
  })
  awful.widget.watch(com, time, function(widget, stdout)
    watch:get_children_by_id("textbox")[1].markup = stdout:gsub("\n", "")
  end)
  return watch
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
