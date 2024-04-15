local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

awful.screen.connect_for_each_screen(function(s)
  local wallpaper = wibox.widget {
    id = "bg",
    widget = wibox.widget.imagebox,
    image = b.wallpaper,
    forced_width = 1920,
    forced_height = 1080,
    horizontal_fit_policy = "fit",
    vertical_fit_policy = "fit",
  }
  local function make_image()
    local cmd = "convert " .. b.wallpaper .. " -filter Gaussian -blur 0x6 ~/.cache/awesome/lock.jpg"
    awful.spawn.easy_async_with_shell(cmd, function()
      local blurwall = gears.filesystem.get_cache_dir() .. "lock.jpg"
      wallpaper.image = blurwall
    end)
  end
  make_image()

  local overlay = wibox.widget {
    widget = wibox.container.background,
    forced_height = 1080,
    forced_width = 1920,
    bg = b.bg .. "c1"
  }

  local background = wibox({
    width = 1920,
    height = 1080,
    visible = false,
    ontop = true,
    type = "desktop",
    screen = s,
    widget = {
      layout = wibox.layout.stack,
      wallpaper,
      overlay,
    },
  })
  awful.placement.centered(background)

  local circle = wibox.widget({
    widget = wibox.container.place,
    halign = "center",
    {
      widget = wibox.container.background,
      bg = b.bg,
      shape = gears.shape.circle,
      {
        id = "arc",
        widget = wibox.container.arcchart,
        max_value = 100,
        min_value = 0,
        value = 0,
        rounded_edge = false,
        thickness = 8,
        start_angle = 4,
        bg = b.fg,
        colors = { b.fg },
        forced_width = 180,
        forced_height = 180,
      },
    },
  })
  local function reset(f)
    circle:get_children_by_id("arc")[1].bg = b.fg
    circle:get_children_by_id("arc")[1].colors = { not f and b.redd or b.fg }
    circle:get_children_by_id("arc")[1].value = not f and 100 or 0
  end
  local function get_random()
    return math.random(0, 628) / 100
  end
  local reset_timer = gears.timer({
    timeout = 1,
    single_shot = true,
    callback = function()
      reset(true)
    end,
  })
  awesome.connect_signal("ui::lock::keypress", function(key, input, auth)
    if #key == 1 then
      circle:get_children_by_id("arc")[1].colors = { b.greend }
      circle:get_children_by_id("arc")[1].value = 20
      circle:get_children_by_id("arc")[1].start_angle = get_random()
    elseif key == "BackSpace" then
      circle:get_children_by_id("arc")[1].colors = { b.redd }
      circle:get_children_by_id("arc")[1].value = 20
      circle:get_children_by_id("arc")[1].start_angle = get_random()
      if #input == 0 then
        circle:get_children_by_id("arc")[1].colors = { b.magentad }
        circle:get_children_by_id("arc")[1].value = 100
      end
    elseif key == "Return" then
      if auth == true then
        circle:get_children_by_id("arc")[1].bg = b.greend
        circle:get_children_by_id("arc")[1].colors = { b.greend }
      else
        circle:get_children_by_id("arc")[1].bg = b.redd
        circle:get_children_by_id("arc")[1].colors = { b.redd }
      end
    end
    reset_timer:again()
  end)

  local caps_lock = wibox.widget({
    markup = " ",
    valign = "center",
    halign = "center",
    id = "name",
    font = b.sysfont(14),
    widget = wibox.widget.textbox,
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
    width = 900,
    height = 800,
    bg = b.bg .. "00",
    ontop = true,
    visible = false,
    type = "desktop",
    widget = {
      widget = wibox.container.background,
      shape = gears.shape.rounded_rect,
      {
        widget = wibox.container.margin,
        margins = 30,
        {
          layout = wibox.layout.align.vertical,
          {
            widget = wibox.container.place,
            valign = "center",
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
          {
            layout = wibox.layout.stack,
            circle,
            caps_lock,
          },
        },
      },
    },
  })
  awful.placement.centered(main)

  local function visible(v)
    background.visible = v
    main.visible = v
  end

  awesome.connect_signal("ui::lock::screen", function(lockscreen)
    if lockscreen == true then
      visible(true)
    else
      visible(false)
    end
  end)
end)
