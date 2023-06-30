local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("helpers")
local fancy_taglist = require("modules.fancy_taglist")
local click_to_hide = require("modules.click_to_hide")

local cpu_widget = require("modules.awesome-wm-widgets.cpu-widget.cpu-widget")

--
-- Wibar
--

screen.connect_signal("request::desktop_decoration", function(s)
  awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", }, s, awful.layout.layouts[1])

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

  -- Caps Lock
  capsl = helpers.simpletxt(26, 26, "Aa_", beautiful.font, "Center", 4, 4, 4, 4)

  function capsl_updater()
    awful.spawn.easy_async_with_shell("xset q | grep Caps | awk '{print $4}'", function (caps_state)
      caps_state = caps_state.gsub(caps_state, "\n", "")
      if caps_state == "on" then
        capsl:get_children_by_id("textbox")[1].text = "A_a"
      else
        capsl:get_children_by_id("textbox")[1].text = "Aa_"
      end
    end)
  end

  capsl_timer = gears.timer {
    timeout = 0.25,
    autostart = true,
    callback = function()
      capsl_updater()
    end,
  }

  -- CPU
  cpu = wibox.widget {
    widget = wibox.container.margin,
    margins = { right = 1, bottom = 1, },
    {
      widget = wibox.widget.textbox,
      markup = " ",
      align = "center",
      valign = "center",
      font = "Fira Code Nerd Font 10",
    },
  }

  -- GPU
  gpu = wibox.widget {
    widget = wibox.container.margin,
    margins = { bottom = 0, },
    {
      widget = wibox.widget.textbox,
      markup = "󰢮 ",
      align = "center",
      valign = "center",
      font = "Fira Code Nerd Font 13",
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
      font = "Fira Code Nerd Font 10",
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
      font = "Fira Code Nerd Font 12",
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
      font = "Fira Code Nerd Font 11",
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
      font = "Fira Code Nerd Font 11",
    },
  }

  layoutbox = helpers.simpleimg(26, 26, beautiful.layout_dwindle, 0, 0, 0, 0)

  -- Systray
  systray_pop = awful.popup {
    ontop = true,
    border_width = 2,
    border_color = beautiful.border_color_active,
    visible = false,
    widget = {
      id = "background",
      widget = wibox.container.background,
      forced_width = 256,
      forced_height = 25,
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
      layout = wibox.layout.align.horizontal,
      expand = "none",
      { -- Left
        layout = wibox.layout.fixed.horizontal,
        layoutbox,
        bar,
        sep,
        cpu,
        helpers.simplewtch([[sh -c "echo -n '' && top -bn1 | grep '%Cpu' | awk '{print int(100-$8)}' && echo -n '%'"]], 1),
        sep,
        cpu_widget({
          width = 20,
          color = "#f35252",
        }),
        sep,
        bar,
        sep,
        gpu,
        helpers.simplewtch([[sh -c "echo -n '' && nvidia-smi | grep 'Default' | cut -d '|' -f 4 | tr -d 'Default' | tr -d '[:space:]'"]], 1),
        sep,
        bar,
        sep,
        memory,
        helpers.simplewtch([[sh -c "echo -n '' && free -h | awk '/Mem:/{gsub(/Gi/,\"\",\$2); gsub(/Gi/,\"\",\$3); printf \"%.0f%%\", (\$3/\$2)*100}'"]], 2),
      },
      { -- Center
        layout = wibox.layout.flex.horizontal,
        s.fancy_taglist,
      },
      { -- Right
        layout = wibox.layout.fixed.horizontal,
        capsl,
        bar,
        sep,
        speaker,
        helpers.simplewtch([[sh -c "echo -n '' && pamixer --get-volume"]], 0.25),
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
  }

  -- Bottom pseudoborder
  wibar = awful.wibar {
    position = "top",
    screen = s,
    y = 26,
    height = 3,
    border_width = 0,
    bg = beautiful.border_color_active,
    type = "dock",
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
