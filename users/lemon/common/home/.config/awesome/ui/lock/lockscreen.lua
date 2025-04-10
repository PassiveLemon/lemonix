require("signal.caps")

local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local dpi = b.xresources.apply_dpi

--
-- Lockscreen visual
--

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
              bottom = dpi(200),
            },
            {
              layout = wibox.layout.stack,
              circle,
              caps_lock,
            },
          },
        },
      },
    },
  })
  awful.placement.centered(main)

  awesome.connect_signal("ui::lock::state", function(force)
    if force then
      -- What should happen when the lockscreen is enabled
      main.visible = true
      awesome.emit_signal("signal::mpris::pause", "%all%")
      awful.spawn.with_shell("pamixer -m")
      awful.spawn.with_shell("xset s on +dpms")
    else
      -- What should happen when the lockscreen is disabled
      main.visible = false
      awful.spawn.with_shell("pamixer -u")
      awful.spawn.with_shell("xset s off -dpms")
    end
  end)
end)

