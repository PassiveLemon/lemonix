local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

--
-- Lockscreen visual
--

local wallpaper = wibox.widget({
  id = "imagebox",
  widget = wibox.widget.imagebox,
  image = b.wallpaper,
  forced_width = 2256,
  forced_height = 1504,
  horizontal_fit_policy = "fit",
  vertical_fit_policy = "fit",
})
local function make_image()
  local cmd = "convert " .. b.wallpaper .. " -filter Gaussian -blur 0x6 -fill 222222c1 -colorize 50% ~/.cache/awesome/lock.jpg"
  awful.spawn.easy_async_with_shell(cmd, function()
    local blurwall = gears.filesystem.get_cache_dir() .. "lock.jpg"
    wallpaper.image = blurwall
  end)
end
make_image()

local function get_random()
  return math.random(0, 628) / 100
end

awful.screen.connect_for_each_screen(function(s)
  local circle = wibox.widget({
    id = "bg",
    widget = wibox.container.background,
    bg = b.bg,
    shape = gears.shape.circle,
    {
      id = "arcchart",
      widget = wibox.container.arcchart,
      max_value = 100,
      min_value = 0,
      value = 0,
      rounded_edge = false,
      thickness = 8,
      start_angle = 4,
      bg = b.fg,
      colors = { b.fg },
      forced_width = 280,
      forced_height = 280,
    },
  })

  local function reset()
    circle:get_children_by_id("arcchart")[1].bg = b.fg
    circle:get_children_by_id("arcchart")[1].colors = { b.fg }
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
      circle:get_children_by_id("arcchart")[1].colors = { b.greend }
      circle:get_children_by_id("arcchart")[1].value = 20
      circle:get_children_by_id("arcchart")[1].start_angle = get_random()
    elseif key == "BackSpace" then
      circle:get_children_by_id("arcchart")[1].colors = { b.redd }
      circle:get_children_by_id("arcchart")[1].value = 20
      circle:get_children_by_id("arcchart")[1].start_angle = get_random()
      if #input == 0 then
        circle:get_children_by_id("arcchart")[1].colors = { b.magentad }
        circle:get_children_by_id("arcchart")[1].value = 100
      end
    elseif key == "Escape" then
      circle:get_children_by_id("arcchart")[1].colors = { b.magentad }
      circle:get_children_by_id("arcchart")[1].value = 100
    elseif key == "Return" then
      if auth then
        circle:get_children_by_id("arcchart")[1].bg = b.greend
        circle:get_children_by_id("arcchart")[1].colors = { b.greend }
      else
        circle:get_children_by_id("arcchart")[1].bg = b.redd
        circle:get_children_by_id("arcchart")[1].colors = { b.redd }
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
    font = b.sysfont(14),
  })
  awesome.connect_signal("signal::caps::state", function(caps)
    if caps == "on" then
      caps_lock.markup = "Caps lock"
    else
      caps_lock.markup = " "
    end
  end)

  local main = wibox({
    screen = s,
    width = 2256,
    height = 1504,
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
              top = 200,
            },
            {
              layout = wibox.layout.fixed.vertical,
              spacing = 5,
              {
                widget = wibox.widget.textclock,
                font = b.sysfont(120),
                format = "%-I:%M %p",
                halign = "center",
                valign = "center",
              },
              {
                widget = wibox.widget.textclock,
                font = b.sysfont(28),
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
              bottom = 200,
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

  awesome.connect_signal("ui::lock::state", function(state)
    if state then
      -- What should happen when the lockscreen is enabled
      main.visible = true
      awful.spawn.with_shell("xset s on +dpms")
    else
      -- What should happen when the lockscreen is disabled
      main.visible = false
      awful.spawn.with_shell("xset s off -dpms")
    end
  end)
end)
