require("signal.caps")

local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local user = require("config.user")

local dpi = b.xresources.apply_dpi

--
-- Lockscreen visual
--

-- This is purely a visual additive to the lock process, it does not handle any security measures

local function get_random()
  return math.random(0, 628) / 100
end

awful.screen.connect_for_each_screen(function(s)
  local wallpaper = wibox.widget({
    id = "imagebox",
    widget = wibox.widget.imagebox,
    image = b.lockscreen,
    forced_width = s.geometry.width,
    forced_height = s.geometry.height,
    horizontal_fit_policy = "fit",
    vertical_fit_policy = "fit",
  })

  local circle = wibox.widget({
    id = "bg",
    widget = wibox.container.background,
    bg = b.bg_primary,
    shape = gears.shape.circle,
    {
      id = "arcchart",
      widget = wibox.container.arcchart,
      max_value = 100,
      min_value = 0,
      value = 0,
      rounded_edge = false,
      thickness = dpi(8),
      start_angle = 0,
      bg = b.fg_primary,
      colors = { b.fg_primary },
      forced_width = dpi(180),
      forced_height = dpi(180),
    },
  })

  local function reset()
    circle:get_children_by_id("arcchart")[1].bg = b.fg_primary
    circle:get_children_by_id("arcchart")[1].colors = { b.fg_primary }
    circle:get_children_by_id("arcchart")[1].value = 0
  end
  local reset_timer = gears.timer({
    timeout = 1,
    single_shot = true,
    callback = function()
      reset()
    end,
  })

  awesome.connect_signal("ui::lock::keypress", function(key, input, auth)
    if #key == 1 then
      circle:get_children_by_id("arcchart")[1].colors = { b.green }
      circle:get_children_by_id("arcchart")[1].value = 20
      circle:get_children_by_id("arcchart")[1].start_angle = get_random()
    elseif key == "BackSpace" then
      circle:get_children_by_id("arcchart")[1].colors = { b.red }
      circle:get_children_by_id("arcchart")[1].value = 20
      circle:get_children_by_id("arcchart")[1].start_angle = get_random()
      if input == 0 then
        circle:get_children_by_id("arcchart")[1].colors = { b.magenta }
        circle:get_children_by_id("arcchart")[1].value = 100
      end
    elseif key == "Escape" then
      circle:get_children_by_id("arcchart")[1].colors = { b.magenta }
      circle:get_children_by_id("arcchart")[1].value = 100
    elseif key == "Return" then
      if auth == nil then
        circle:get_children_by_id("arcchart")[1].colors = { b.magenta }
        circle:get_children_by_id("arcchart")[1].value = 100
      elseif auth then
        circle:get_children_by_id("arcchart")[1].colors = { b.green }
        circle:get_children_by_id("arcchart")[1].value = 100
      elseif not auth then
        circle:get_children_by_id("arcchart")[1].colors = { b.red }
        circle:get_children_by_id("arcchart")[1].value = 100
      end
    end
    reset_timer:again()
  end)

  local caps_lock = wibox.widget({
    id = "textbox",
    widget = wibox.widget.textbox,
    markup = " ",
    valign = "center",
    halign = "center",
    font = b.sysfont(dpi(14)),
  })
  awesome.connect_signal("signal::peripheral::caps::state", function(caps)
    if caps then
      caps_lock.markup = "Caps lock"
    else
      caps_lock.markup = " "
    end
  end)

  local battery_icon = wibox.widget({
    id = "textbox",
    widget = wibox.widget.textbox,
    valign = "center",
    halign = "center",
    markup = "󰁹",
    font = b.sysfont(dpi(18)),
  })

  if not user.bar.battery then
    battery_icon.visible = false
  end

  local battery_icons_lookup = {
    [9] = "󰁹",
    [8] = "󰂂",
    [7] = "󰂁",
    [6] = "󰂀",
    [5] = "󰁿",
    [4] = "󰁾",
    [3] = "󰁽",
    [2] = "󰁼",
    [1] = "󰁻",
    [0] = "󰁺",
  }
  awesome.connect_signal("signal::power", function(ac, perc)
    if not ac then
      battery_icon:get_children_by_id("textbox")[1].text = battery_icons_lookup[math.floor(perc / 10)]
    else
      battery_icon:get_children_by_id("textbox")[1].text = "󰂄"
    end
  end)

  local main = wibox({
    width = s.geometry.width,
    height = s.geometry.height,
    screen = s,
    ontop = true,
    visible = false,
    type = "desktop",
    widget = {
      layout = wibox.layout.stack,
      wallpaper,
      {
        layout = wibox.layout.align.vertical,
        {
          widget = wibox.container.place,
          valign = "center",
          {
            widget = wibox.container.margin,
            margins = {
              top = dpi(200),
            },
            {
              layout = wibox.layout.fixed.vertical,
              spacing = dpi(5),
              {
                widget = wibox.widget.textclock,
                font = b.sysfont(dpi(120)),
                format = "%-I:%M %p",
                halign = "center",
                valign = "center",
              },
              {
                widget = wibox.widget.textclock,
                font = b.sysfont(dpi(28)),
                format = "%a %b %-d",
                halign = "center",
                valign = "center",
              },
            },
          },
        },
        {
          widget = wibox.container.place,
          halign = "center",
          {
            widget = wibox.container.margin,
            margins = {
              bottom = dpi(180),
            },
            {
              layout = wibox.layout.stack,
              circle,
              caps_lock,
            },
          },
        },
        {
          widget = wibox.container.place,
          halign = "right",
          {
            widget = wibox.container.margin,
            margins = {
              right = dpi(24),
              bottom = dpi(20),
            },
            {
              layout = wibox.layout.stack,
              battery_icon,
            },
          },
        },
      },
    },
  })
  awful.placement.centered(main)

  awesome.connect_signal("ui::lock::state", function(force)
    main.visible = force or false
  end)
end)

