local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local helpers = { }

function helpers.text(conf)
  conf = conf or { }
  local text = wibox.widget {
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins and conf.margins.top or 0,
      right = conf.margins and conf.margins.right or 0,
      bottom = conf.margins and conf.margins.bottom or 0,
      left = conf.margins and conf.margins.left or 0,
    },
    {
      id = "background",
      widget = wibox.container.background,
      forced_width = conf.x,
      forced_height = conf.y,
      fg = conf.fg or b.fg0,
      bg = conf.bg or b.bg0,
      {
        -- Allow use of either text or image. Kind of pointless to make 2 separate ones.
        layout = wibox.layout.stack,
        {
          id = "textbox",
          widget = wibox.widget.textbox,
          markup = conf.markup,
          text = conf.text,
          font = conf.font or b.sysfont(10),
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
  -- Same as h.text, just with hover signals.
  conf = conf or { }
  local button = wibox.widget {
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins and conf.margins.top or 0,
      right = conf.margins and conf.margins.right or 0,
      bottom = conf.margins and conf.margins.bottom or 0,
      left = conf.margins and conf.margins.left or 0,
    },
    {
      id = "background",
      widget = wibox.container.background,
      forced_width = conf.x,
      forced_height = conf.y,
      fg = conf.fg or b.fg0,
      bg = conf.bg or b.bg1,
      shape = conf.shape,
      {
        layout = wibox.layout.stack,
        {
          id = "textbox",
          widget = wibox.widget.textbox,
          markup = conf.markup,
          text = conf.text,
          font = conf.font or b.sysfont(10),
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
    button:get_children_by_id("background")[1].fg = conf.fg_focus or b.fg_focus
    button:get_children_by_id("background")[1].bg = conf.bg or b.bg_minimize
  end)
  button:get_children_by_id("background")[1]:connect_signal("mouse::leave", function()
    button:get_children_by_id("background")[1].fg = conf.fg or b.fg_normal
    button:get_children_by_id("background")[1].bg = conf.bg or b.bg1
  end)
  return button
end

function helpers.slider(conf)
  conf = conf or { }
  local slider = wibox.widget {
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins and conf.margins.top or 0,
      right = conf.margins and conf.margins.right or 0,
      bottom = conf.margins and conf.margins.bottom or 0,
      left = conf.margins and conf.margins.left or 0,
    },
    {
      id = "background",
      widget = wibox.container.background,
      forced_width = conf.x,
      forced_height = conf.y,
      fg = conf.fg or b.fg0,
      bg = conf.bg or b.bg0l,
      {
        id = "slider",
        widget = wibox.widget.slider,
        minimum = conf.min or 0,
        maximum = conf.max,
        handle_shape = conf.handle_shape or gears.shape.circle,
        handle_color = conf.handle_color or b.fg0,
        handle_width = 0,
        bar_height = conf.bar_height,
        bar_shape = conf.bar_shape,
        bar_color = conf.bar_color or b.bg2,
        bar_active_color = conf.bar_active_color or b.fg0,
      },
    },
  }
  slider:get_children_by_id("background")[1]:connect_signal("mouse::enter", function()
    slider:get_children_by_id("slider")[1].handle_width = conf.handle_width
    slider:get_children_by_id("slider")[1].bar_active_color = conf.bar_active_color or b.fg0
  end)
  slider:get_children_by_id("background")[1]:connect_signal("mouse::leave", function()
    slider:get_children_by_id("slider")[1].handle_width = 0
    slider:get_children_by_id("slider")[1].bar_active_color = conf.bar_active_color or b.fg0
  end)
  return slider
end

function helpers.progressbar(conf)
  conf = conf or { }
  local progressbar = wibox.widget {
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins and conf.margins.top or 0,
      right = conf.margins and conf.margins.right or 0,
      bottom = conf.margins and conf.margins.bottom or 0,
      left = conf.margins and conf.margins.left or 0,
    },
    {
      id = "background",
      widget = wibox.container.background,
      forced_width = conf.x,
      forced_height = conf.y,
      fg = conf.fg or b.fg0,
      bg = conf.bg or b.bg0,
      {
        id = "progressbar",
        widget = wibox.widget.progressbar,
        color = conf.color or b.fg0,
        background_color = conf.background_color or b.bg2,
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
  return (math.floor((number * decimal) + (0.5 / decimal)) / decimal)
end

function helpers.watch(com, time)
  local watch = helpers.text({
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

function helpers.file_test(path, file, callback)
  awful.spawn.easy_async_with_shell("test -f " .. path .. file .. " && echo true || echo false", function(stdout)
    local stdout = stdout:gsub("\n", "")
    callback(stdout)
  end)
end

return helpers
