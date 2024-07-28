local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local dpi = b.xresources.apply_dpi

--
-- Helpers
--

local helpers = { }

function helpers.text(conf)
  conf = conf or { }
  local text = wibox.widget({
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins and conf.margins.top or dpi(0),
      right = conf.margins and conf.margins.right or dpi(0),
      bottom = conf.margins and conf.margins.bottom or dpi(0),
      left = conf.margins and conf.margins.left or dpi(0),
    },
    {
      id = "background",
      widget = wibox.container.background,
      forced_width = conf.x,
      forced_height = conf.y,
      bg = conf.bg or b.ui_main_bg,
      fg = conf.fg or b.ui_main_fg,
      {
        -- Allow use of either text or image. Kind of pointless to make 2 separate ones.
        layout = wibox.layout.stack,
        {
          id = "textbox",
          widget = wibox.widget.textbox,
          forced_width = conf.x,
          forced_height = conf.y,
          markup = conf.markup,
          text = conf.text,
          font = conf.font or b.sysfont(dpi(10)),
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
  })
  return text
end

function helpers.button(conf)
  -- Same as h.text, just with hover signals.
  conf = conf or { }
  local button = wibox.widget({
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins and conf.margins.top or dpi(0),
      right = conf.margins and conf.margins.right or dpi(0),
      bottom = conf.margins and conf.margins.bottom or dpi(0),
      left = conf.margins and conf.margins.left or dpi(0),
    },
    {
      id = "background",
      widget = wibox.container.background,
      forced_width = conf.x,
      forced_height = conf.y,
      bg = conf.bg or b.ui_button_bg,
      fg = conf.fg or b.ui_button_fg,
      shape = conf.shape,
      {
        layout = wibox.layout.stack,
        {
          id = "textbox",
          widget = wibox.widget.textbox,
          markup = conf.markup,
          text = conf.text,
          font = conf.font or b.sysfont(dpi(10)),
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
  })
  button:get_children_by_id("background")[1]:connect_signal("mouse::enter", function()
    if conf.toggle == false then
      button:get_children_by_id("background")[1].bg = conf.bg_focus or b.bg_minimize
      button:get_children_by_id("background")[1].fg = conf.fg or b.redd
    else
      button:get_children_by_id("background")[1].bg = conf.bg_focus or b.bg_minimize
      button:get_children_by_id("background")[1].fg = conf.fg_focus or b.fg_focus
    end
  end)
  button:get_children_by_id("background")[1]:connect_signal("mouse::leave", function()
    button:get_children_by_id("background")[1].bg = conf.bg or b.ui_button_bg
    button:get_children_by_id("background")[1].fg = conf.fg or b.ui_button_fg
  end)
  return button
end

function helpers.slider(conf)
  conf = conf or { }
  local slider = wibox.widget({
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins and conf.margins.top or dpi(0),
      right = conf.margins and conf.margins.right or dpi(0),
      bottom = conf.margins and conf.margins.bottom or dpi(0),
      left = conf.margins and conf.margins.left or dpi(0),
    },
    {
      id = "background",
      widget = wibox.container.background,
      forced_width = conf.x,
      forced_height = conf.y,
      bg = conf.bg or b.ui_main_bg,
      fg = conf.fg or b.ui_slider_fg,
      {
        id = "slider",
        widget = wibox.widget.slider,
        minimum = conf.min or 0,
        maximum = conf.max,
        handle_shape = conf.handle_shape or gears.shape.circle,
        handle_color = conf.handle_color or b.ui_slider_fg,
        handle_width = dpi(0),
        bar_height = conf.bar_height,
        bar_shape = conf.bar_shape,
        bar_color = conf.bar_color or b.ui_slider_bg,
        bar_active_color = conf.bar_active_color or b.ui_slider_fg,
      },
    },
  })
  slider:get_children_by_id("background")[1]:connect_signal("mouse::enter", function()
    slider:get_children_by_id("slider")[1].handle_width = conf.handle_width
    slider:get_children_by_id("slider")[1].bar_active_color = conf.bar_active_color or b.fg0
  end)
  slider:get_children_by_id("background")[1]:connect_signal("mouse::leave", function()
    slider:get_children_by_id("slider")[1].handle_width = dpi(0)
    slider:get_children_by_id("slider")[1].bar_active_color = conf.bar_active_color or b.fg0
  end)
  return slider
end

function helpers.progressbar(conf)
  conf = conf or { }
  local progressbar = wibox.widget({
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins and conf.margins.top or dpi(0),
      right = conf.margins and conf.margins.right or dpi(0),
      bottom = conf.margins and conf.margins.bottom or dpi(0),
      left = conf.margins and conf.margins.left or dpi(0),
    },
    {
      id = "background",
      widget = wibox.container.background,
      forced_width = conf.x,
      forced_height = conf.y,
      bg = conf.bg or b.ui_main_bg,
      fg = conf.fg or b.ui_progress_fg,
      {
        id = "progressbar",
        widget = wibox.widget.progressbar,
        background_color = conf.background_color or b.ui_progress_bg,
        color = conf.color or b.ui_progress_fg,
        shape = conf.shape,
        max_value = conf.max,
        margins = {
          top = conf.progmargins.top or dpi(0),
          right = conf.progmargins.right or dpi(0),
          bottom = conf.progmargins.bottom or dpi(0),
          left = conf.progmargins.left or dpi(0),
        },
        forced_width = conf.forced_width,
        forced_height = conf.forced_height,
      },
    },
  })
  return progressbar
end

function helpers.round(number, place)
  local decimal = (10 ^ place)
  return (math.floor((number * decimal) + (0.5 / decimal)) / decimal)
end

function helpers.watch(com, time, conf)
  local watch = helpers.text(conf)
  awful.widget.watch(com, time, function(_, stdout)
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

function helpers.is_file(file)
  return gears.filesystem.file_readable(file)
end

function helpers.is_dir(dir)
  return gears.filesystem.is_dir(dir)
end

function helpers.dump_table(table)
  if type(table) == "table" then
    local s = "{ "
    for k, v in pairs(table) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. helpers.dump_table(v) .. ","
    end
    return s .. "} "
  else
    return tostring(table)
  end
end

return helpers
