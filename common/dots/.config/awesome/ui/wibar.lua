local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("helpers")
local fancy_taglist = require("modules.fancy_taglist")
local click_to_hide = require("modules.click_to_hide")

local cpu_widget = require("libraries.awesome-wm-widgets.cpu-widget.cpu-widget")

--
-- Wibar
--

local function icon(x, y, img, mt, mr, mb, ml)
  local icon = wibox.widget {
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
      bg = beautiful.fg,
      {
        id = "imagebox",
        widget = wibox.widget.imagebox,
        resize = true,
        image = img,
      },
    },
  }
  return icon
end

screen.connect_signal("request::desktop_decoration", function(s)
  awful.tag({ " 1 ", " 2 ", " 3 ", }, s, awful.layout.layouts[1])

  -- Separator bar
  bar = wibox.widget {
    widget = wibox.widget.textbox,
    markup = "│",
    align = "center",
    valign = "center",
  }

  -- Space
  sep = wibox.widget {
    widget = wibox.widget.textbox,
    markup = " ",
    align = "center",
    valign = "center",
  }

  -- Percent
  perc = wibox.widget {
    widget = wibox.widget.textbox,
    markup = "%",
    align = "center",
    valign = "center",
  }

  -- CPU
  cpu = icon(16, 16, os.getenv("HOME") .. "/.config/awesome/libraries/feather/icons/cpu.svg")

  -- GPU
  gpu = wibox.widget {
    widget = wibox.container.margin,
    margins = { bottom = 0, },
    {
      widget = wibox.widget.textbox,
      markup = "󰢮 ",
      align = "center",
      valign = "center",
      font = beautiful.sysfont(18),
    },
  }

  -- Memory
  memory = wibox.widget {
    widget = wibox.container.margin,
    margins = { right = 2, bottom = 1, },
    {
      widget = wibox.widget.textbox,
      markup = " ",
      align = "center",
      valign = "center",
      font = beautiful.sysfont(14),
    },
  }

  -- Speaker
  speaker = wibox.widget {
    widget = wibox.container.margin,
    margins = { bottom = 1, },
    {
      widget = wibox.widget.textbox,
      markup = "󰕾 ",
      align = "center",
      valign = "center",
      font = beautiful.sysfont(14),
    },
  }

  -- Calendar
  calendar = wibox.widget {
    widget = wibox.container.margin,
    margins = { bottom = 0, },
    {
      widget = wibox.widget.textbox,
      markup = "󰸗 ",
      align = "center",
      valign = "center",
      font = beautiful.sysfont(14),
    },
  }

  -- Clock
  clock = wibox.widget {
    widget = wibox.container.margin,
    margins = { bottom = 0, },
    {
      widget = wibox.widget.textbox,
      markup = "󰥔 ",
      align = "center",
      valign = "center",
      font = beautiful.sysfont(14),
    },
  }

  layoutbox = helpers.simpleimg(26, 26, beautiful.layout_dwindle, 0, 0, 0, 0)

  -- Systray
  systray_pop = awful.popup {
    ontop = true,
    border_width = 0,
    border_color = beautiful.border_color_active,
    visible = false,
    widget = {
      id = "background",
      widget = wibox.container.background,
      forced_width = 256,
      forced_height = 26,
      bg = beautiful.bg_normal,
      {
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.systray,
      },
    },
  }

  systray_autohider = gears.timer {
    timeout = 2,
    single_shot = true,
    callback = function()
      systray_pop.visible = false
    end,
  }

  s.fancy_taglist = fancy_taglist.new {
    screen = s,
    taglist_buttons = {
      awful.button({ }, 1, function(t) t:view_only() end),
      awful.button({ }, 3, awful.tag.viewtoggle),
      awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
      awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end),
    },
    tasklist_buttons = {
      awful.button({ }, 1, function (c)
        c:activate { context = "tasklist", action = "toggle_minimization", }
      end),
      awful.button({ }, 4, function() awful.client.focus.byidx(1) end),
      awful.button({ }, 5, function() awful.client.focus.byidx(-1) end),
    }
  }

  -- Bar
  wibar = awful.wibar {
    position = "top",
    screen = s,
    height = 26,
    border_width = 0,
    border_color = beautiful.accent,
    type = "dock",
    widget = {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        { -- Left
          layout = wibox.layout.fixed.horizontal,
          layoutbox,
          bar,
          sep,
          cpu,
          helpers.simplewtch([[sh -c "top -bn1 | grep '%Cpu' | awk '{print int(100-$8)}' && echo -n '%'"]], 1),
          sep,
          cpu_widget({
            width = 20,
            color = "#f35252",
          }),
          sep,
          bar,
          sep,
          gpu,
          helpers.simplewtch([[sh -c "nvidia-smi | grep 'Default' | awk '{print $12}'"]], 1),
          sep,
          bar,
          sep,
          memory,
          helpers.simplewtch([[sh -c "free -h | awk '/Mem:/{gsub(/Gi/,\"\",\$2); gsub(/Gi/,\"\",\$3); printf \"%.0f%%\", (\$3/\$2)*100}'"]], 2),
        },
        { -- Center
          layout = wibox.layout.flex.horizontal,
          s.fancy_taglist,
        },
        { -- Right
          layout = wibox.layout.fixed.horizontal,
          helpers.simplewtch([[bash -c "[ $(xset q | grep Caps | awk '{print $4}') = "on" ] && echo '<span underline=\"single\">A</span>a' || echo 'A<span underline=\"single\">a</span>'"]], 0.25),
          sep,
          bar,
          sep,
          speaker,
          helpers.simplewtch("pamixer --get-volume", 0.25),
          perc,
          sep,
          bar,
          sep,
          calendar,
          helpers.simplewtch("date +'%a %b %-d'", 60),
          sep,
          bar,
          sep,
          clock,
          helpers.simplewtch("date +'%-I:%M %p'", 1),
          sep,
        },
      },
      {
        widget = wibox.container.background,
        forced_height = 3,
        bg = beautiful.border_color_active,
      },
    },
  }

  layoutbox:connect_signal("button::press", function()
    systray_pop.visible = not systray_pop.visible
    systray_pop.screen = awful.screen.focused()
  end)

  systray_pop:connect_signal("mouse::leave", function()
    systray_autohider:start()
  end)
  systray_pop:connect_signal("mouse::enter", function()
    systray_autohider:stop()
  end)
  systray_pop:connect_signal("button::press", function()
    systray_autohider:stop()
  end)

  click_to_hide.popup(systray_pop, nil, true)

end)
