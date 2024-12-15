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
      bg = conf.bg or b.bg_secondary,
      fg = conf.fg or b.fg_primary,
      shape = conf.shape,
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
          halign = conf.halign or "center",
          valign = conf.valign or "center",
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
      bg = conf.bg or b.bg_secondary,
      fg = conf.fg or b.fg_primary,
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
          halign = conf.halign or "center",
          valign = conf.valign or "center",
        },
      }
    },
  })
  button:get_children_by_id("background")[1]:connect_signal("mouse::enter", function()
    if conf.toggle == false then
      button:get_children_by_id("background")[1].bg = conf.bg_focus or b.bg_focus
      button:get_children_by_id("background")[1].fg = conf.fg_primary or b.red
    else
      button:get_children_by_id("background")[1].bg = conf.bg_focus or b.bg_minimize
      button:get_children_by_id("background")[1].fg = conf.fg_focus or b.fg_focus
    end
  end)
  button:get_children_by_id("background")[1]:connect_signal("mouse::leave", function()
    button:get_children_by_id("background")[1].bg = conf.bg_primary or b.bg_secondary
    button:get_children_by_id("background")[1].fg = conf.fg_primary or b.fg_primary
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
      bg = conf.bg or b.bg_secondary,
      fg = conf.fg or b.fg_primary,
      {
        id = "slider",
        widget = wibox.widget.slider,
        minimum = conf.min or 0,
        maximum = conf.max,
        handle_shape = conf.handle_shape or gears.shape.circle,
        handle_color = conf.handle_color or b.fg_primary,
        handle_width = dpi(0),
        bar_height = conf.bar_height,
        bar_shape = conf.bar_shape,
        bar_color = conf.bar_color or b.bg_minimize,
        bar_active_color = conf.bar_active_color or b.fg_primary,
      },
    },
  })
  slider:get_children_by_id("background")[1]:connect_signal("mouse::enter", function()
    slider:get_children_by_id("slider")[1].handle_width = conf.handle_width
    slider:get_children_by_id("slider")[1].bar_active_color = conf.bar_active_color or b.fg_primary
  end)
  slider:get_children_by_id("background")[1]:connect_signal("mouse::leave", function()
    slider:get_children_by_id("slider")[1].handle_width = dpi(0)
    slider:get_children_by_id("slider")[1].bar_active_color = conf.bar_active_color or b.fg_primary
  end)
  return slider
end

function helpers.round(number, place)
  local decimal = (10 ^ place)
  return (math.floor((number * decimal) + (0.5 / decimal)) / decimal)
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

function helpers.join_path(...)
  if not ... then return nil end
  local norm_paths = { }
  -- Normalize the input paths to ensure consistent results:
  -- Sanitize inputs
  -- Match and separate paths inside strings ("foo/bar" -> "foo", "bar")
  -- Remove training/leading slashes (keep the leading if it's the first element for root)
  for i = 1, select("#", ...) do
    local path = select(i, ...)
    if type(path) == "string" then
      if i == 1 and (path:match("^/+") or path == "/") then
        table.insert(norm_paths, "")
      end
      for part in path:gmatch("[^/]+") do
        part = part:gsub("^/+", ""):gsub("/+$", "")
        table.insert(norm_paths, part)
      end
    end
  end
  local final_path = table.concat(norm_paths, "/")
  return final_path
end

-- Some test cases
-- -- Plain -> "home/user/documents/file.txt"
-- print(helpers.join_path("home", "user", "documents", "file.txt"))
-- -- Root leading slash -> "/home/user/documents/file.txt"
-- print(helpers.join_path("/home", "user", "documents", "file.txt"))
-- -- Trailing/leading slashes -> "home/user/documents/file.txt"
-- print(helpers.join_path("home", "user/", "/documents", "/file.txt/"))
-- -- Excessive slashes -> "/home/user/documents/file.txt"
-- print(helpers.join_path("//home////", "user///", "/documents", "file.txt"))
-- -- Spaces -> "home/user/documents/my file.txt"
-- print(helpers.join_path("home", "user", "documents", "my file.txt"))
-- -- Relatives -> "home/user/pictures/../documents/file.txt"
-- print(helpers.join_path("home", "user", "pictures", "..", "documents", "file.txt"))
-- -- Bad inputs -> "home/user/documents/file.txt"
-- -- If there's no valid strings, returns empty string
-- print(helpers.join_path("", "home", true, "user", nil, "documents", 1, "file.txt"))
-- -- No inputs -> nil
-- print(helpers.join_path())

return helpers

