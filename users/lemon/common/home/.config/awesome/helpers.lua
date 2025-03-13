local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local click_to_hide = require("modules.click_to_hide")

local dpi = b.xresources.apply_dpi

--
-- Helpers
--

local helpers = { }

function helpers.margin(widget_pass, conf_in)
  local conf = conf_in or { }
  local margin = wibox.widget({
    id = "margin",
    widget = wibox.container.margin,
    margins = {
      top = conf.margins and conf.margins.top or dpi(b.margins),
      right = conf.margins and conf.margins.right or dpi(b.margins),
      bottom = conf.margins and conf.margins.bottom or dpi(b.margins),
      left = conf.margins and conf.margins.left or dpi(b.margins),
    },
    widget_pass,
  })
  return margin
end

function helpers.background(widget_pass, conf_in)
  local conf = conf_in or { }
  local background = helpers.margin({
    id = "background",
    widget = wibox.container.background,
    forced_width = conf.x,
    forced_height = conf.y,
    bg = conf.bg or b.bg_secondary,
    fg = conf.fg or b.fg_primary,
    shape = conf.shape,
    visible = conf.visible or true,
    widget_pass,
  }, conf_in)
  return background
end

function helpers.text(conf_in)
  local conf = conf_in or { }
  local text = helpers.background({
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
      resize = conf.resize or true,
      image = conf.image,
      halign = conf.halign or "center",
      valign = conf.valign or "center",
    },
  }, conf_in)
  return text
end

local button_default = {
  toggle = true,
  no_color = false,
  mouse_enter = function() end,
  mouse_leave = function() end,
  button_press = function() end,
}

function helpers.button(conf_in)
  local conf = gears.table.join(button_default, (conf_in or { }))
  local button = helpers.text(conf)
  local button_id = button:get_children_by_id("background")[1]
  button.buttons = {
    awful.button({ }, 1, function()
      conf:button_press()
    end)
  }
  button_id:connect_signal("mouse::enter", function(self)
    if not conf.no_color then
      self.bg = conf.bg_focus or b.bg_minimize
      self.fg = conf.fg_focus or b.fg_focus
    end
    conf:mouse_enter()
  end)
  button_id:connect_signal("mouse::leave", function(self)
    if not conf.no_color then
      self.bg = conf.bg_primary or b.bg_secondary
      self.fg = conf.fg_primary or b.fg_primary
    end
    conf:mouse_leave()
  end)
  return button
end

local timed_default = {
  mouse_enter = function() end,
  mouse_leave = function() end,
}

function helpers.timed_button(conf_in, time)
  local conf = gears.table.join(button_default, (conf_in or { }))
  local button = helpers.text(conf)
  local button_id = button:get_children_by_id("background")[1]
  button.toggle = false
  local timer = gears.timer({
    timeout = time or 3,
    single_shot = true,
    callback = function()
      button.toggle = true
      button_id.fg = b.fg_focus
    end,
  })
  button.buttons = {
    awful.button({ }, 1, function()
      if button.toggle == true then
        conf:button_press()
      end
    end)
  }
  button_id:connect_signal("mouse::enter", function(self)
    if button.toggle == false then
      if not conf.no_color then
        self.bg = conf.bg_focus or b.bg_minimize
        self.fg = conf.fg_primary or b.red
      end
    else
      self.bg = conf.bg_focus or b.bg_minimize
      self.fg = conf.fg_focus or b.fg_focus
    end
    timer:again()
    conf:mouse_enter()
  end)
  button_id:connect_signal("mouse::leave", function(self)
    if not conf.no_color then
      self.bg = conf.bg_primary or b.bg_secondary
      self.fg = conf.fg_primary or b.fg_primary
    end
    timer:stop()
    button.toggle = false
    conf:mouse_leave()
  end)
  return button
end

local slider_default = {
  mouse_enter = function() end,
  mouse_leave = function() end,
}

function helpers.slider(conf_in)
  local conf = gears.table.join(slider_default, (conf_in or { }))
  local slider = helpers.background({
    id = "slider",
    widget = wibox.widget.slider,
    minimum = conf.min or 0,
    maximum = conf.max or 100,
    handle_shape = conf.handle_shape or gears.shape.circle,
    handle_color = conf.handle_color or b.fg_primary,
    handle_width = dpi(0),
    bar_height = conf.bar_height,
    bar_shape = conf.bar_shape,
    bar_color = conf.bar_color or b.bg_minimize,
    bar_active_color = conf.bar_active_color or b.fg_primary,
  }, conf_in)
  local slider_id = slider:get_children_by_id("slider")[1]
  if (conf.output_signal ~= "") and (conf.output_signal ~= nil) then
    slider_id:connect_signal("property::value", function(self, new_state)
      self.value = new_state
      awesome.emit_signal(conf.output_signal, new_state)
    end)
  end
  slider_id:connect_signal("mouse::enter", function(self)
    self.handle_width = conf.handle_width
    self.bar_active_color = conf.bar_active_color or b.fg_primary
    conf:mouse_enter()
  end)
  slider_id:connect_signal("mouse::leave", function(self)
    self.handle_width = dpi(0)
    self.bar_active_color = conf.bar_active_color or b.fg_primary
    conf:mouse_leave()
  end)
  return slider
end

-- Widget with a toggle lock
function helpers.widget(conf_in)
  local conf = conf_in or { }
  local widget = conf_in
  -- https://bitbucket.org/grumph/home_config/src/4d650b5bc3c366eff245f528c7830c22bfef1ba4/.config/awesome/helpers/widget_popup.lua#lines-42:57
  if conf.hide_on_click_anywhere then
    click_to_hide.popup(widget, nil, true)
  end
  -- Mechanism to disallow popup to toggle too often.
  -- This avoids multiple toggles problem caused by hide_on_click
  local can_toggle = true
  local toggle_lock_timer = gears.timer({
    timeout = 0.1,
    single_shot = true,
    callback  = function()
      can_toggle = true
    end
  })
  widget:connect_signal("property::visible", function()
    can_toggle = false
    toggle_lock_timer:again()
  end)
  function widget:toggle(force)
    if can_toggle then
      if force == false or (force == nil and self.visible) then
        self.visible = false
      else
        self.visible = true
      end
    end
  end
  -- For use by other helper functions
  function widget:toggle_priv(force)
    if can_toggle then
      if force == false or (force == nil and self.visible) then
        self.visible = false
      else
        self.visible = true
      end
    end
  end
  return widget
end

-- Widget with a life-time
function helpers.timed_widget(conf_in, time, start_on_visible)
  local conf = gears.table.join(timed_default, (conf_in or { }))
  local widget = helpers.widget(conf_in)
  widget.visible = false
  local timer = gears.timer({
    timeout = time or 3,
    single_shot = true,
    callback = function()
      widget.visible = false
    end,
  })
  function widget:start()
    timer:start()
  end
  function widget:stop()
    timer:stop()
  end
  function widget:again()
    timer:again()
  end
  function widget:toggle(force)
    if force == false or (force == nil and self.visible) then
      self:toggle_priv(false)
    else
      self:toggle_priv(true)
    end
    if start_on_visible then
      timer:again()
    end
  end
  widget:connect_signal("mouse::enter", function()
    timer:stop()
    conf:mouse_enter()
  end)
  widget:connect_signal("mouse::leave", function()
    timer:again()
    conf:mouse_leave()
  end)
  return widget
end

-- Popup with a toggle lock
function helpers.popup(conf_in)
  local conf = conf_in or { }
  local popup = awful.popup(conf)
  -- https://bitbucket.org/grumph/home_config/src/4d650b5bc3c366eff245f528c7830c22bfef1ba4/.config/awesome/helpers/widget_popup.lua#lines-42:57
  if conf.hide_on_click_anywhere then
    click_to_hide.popup(popup, nil, true)
  end
  -- Mechanism to disallow popup to toggle too often.
  -- This avoids multiple toggles problem caused by hide_on_click
  local can_toggle = true
  local toggle_lock_timer = gears.timer({
    timeout = 0.1,
    single_shot = true,
    callback  = function()
      can_toggle = true
    end
  })
  popup:connect_signal("property::visible", function()
    can_toggle = false
    toggle_lock_timer:again()
  end)
  function popup:toggle(force)
    if can_toggle then
      if force == false or (force == nil and self.visible) then
        self.visible = false
      else
        self.visible = true
      end
    end
  end
  -- For use by other helper functions
  function popup:toggle_priv(force)
    if can_toggle then
      if force == false or (force == nil and self.visible) then
        self.visible = false
      else
        self.visible = true
      end
    end
  end
  return popup
end

-- Popup with a life-time
function helpers.timed_popup(conf_in, time, start_on_visible)
  local conf = gears.table.join(timed_default, (conf_in or { }))
  local popup = helpers.popup(conf)
  popup.visible = false
  local timer = gears.timer({
    timeout = time or 3,
    single_shot = true,
    callback = function()
      popup:toggle(false)
    end,
  })
  function popup:start()
    timer:start()
  end
  function popup:stop()
    timer:stop()
  end
  function popup:again()
    timer:again()
  end
  function popup:toggle(force)
    if force == false or (force == nil and self.visible) then
      self:toggle_priv(false)
    else
      self:toggle_priv(true)
    end
    if start_on_visible then
      timer:again()
    end
  end
  popup:connect_signal("mouse::enter", function()
    timer:stop()
    conf:mouse_enter()
  end)
  popup:connect_signal("mouse::leave", function()
    timer:again()
    conf:mouse_leave()
  end)
  return popup
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

