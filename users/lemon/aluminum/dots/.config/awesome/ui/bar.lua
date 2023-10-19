local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")
local fancy_taglist = require("modules.fancy_taglist")
local cpu_widget = require("libraries.awesome-wm-widgets.cpu-widget.cpu-widget")

--
-- Wibar
--

screen.connect_signal("request::desktop_decoration", function(s)
  awful.tag({ "", "", "", }, s, awful.layout.layouts[1])

  -- Separator bar
  local bar = h.text({
    margins = {
      top = 0,
      right = 0,
      bottom = 0,
      left = 0,
    },
    text = "│",
  })

  -- Space
  local sep = h.text({
    margins = {
      top = 0,
      right = 0,
      bottom = 0,
      left = 0,
    },
    text = " ",
  })

  -- Percent
  local perc = h.text({
    margins = {
      top = 0,
      right = 0,
      bottom = 0,
      left = 0,
    },
    text = "%",
  })

  --cpu = h.simpleicn(14, 14, 0, 5, 0, 4, os.getenv("HOME") .. "/.config/awesome/libraries/feather/icons/cpu.svg", b.fg)
  --gpu = h.simpleicn(14, 14, 0, 5, 0, 4, os.getenv("HOME") .. "/.config/awesome/libraries/feather/icons/database.svg", b.fg)
  --memory = h.simpleicn(14, 14, 0, 5, 0, 4, os.getenv("HOME") .. "/.config/awesome/libraries/feather/icons/credit-card.svg", b.fg)
  --speaker = h.simpleicn(14, 14, 0, 5, 0, 4, os.getenv("HOME") .. "/.config/awesome/libraries/feather/icons/volume-2.svg", b.fg)
  --calendar = h.simpleicn(14, 14, 0, 5, 0, 4, os.getenv("HOME") .. "/.config/awesome/libraries/feather/icons/calendar.svg", b.fg)
  --clock = h.simpleicn(14, 14, 0, 5, 0, 4, os.getenv("HOME") .. "/.config/awesome/libraries/feather/icons/clock.svg", b.fg)

  -- CPU
  local cpu_icon = h.text({
    margins = {
      top = 0,
      right = 1,
      bottom = 2,
      left = 0,
    },
    text = "",
    font = b.sysfont(15),
  })
  local cpu = h.text({
    margins = {
      top = 0,
      right = 0,
      bottom = 0,
      left = 0,
    },
    halign = "left",
  })
  awesome.connect_signal("signal::cpu", function(use, temp)
    cpu:get_children_by_id("textbox")[1].text = use .. "%"
  end)

  -- Memory
  local memory_icon = h.text({
    margins = {
      top = 0,
      right = 2,
      bottom = 2,
      left = 0,
    },
    text = "",
    font = b.sysfont(15),
  })
  local memory = h.text({
    margins = {
      top = 0,
      right = 0,
      bottom = 0,
      left = 0,
    },
    halign = "left",
  })
  awesome.connect_signal("signal::memory", function(use, use_perc, cache, cache_perc)
    memory:get_children_by_id("textbox")[1].text = use_perc .. "%"
  end)

  -- Speaker
  local speaker_icon = h.text({
    margins = {
      top = 0,
      right = 0,
      bottom = 1,
      left = 0,
    },
    text = "󰕾",
    font = b.sysfont(14),
  })

  -- Calendar
  local calendar_icon = h.text({
    margins = {
      top = 0,
      right = 0,
      bottom = 3,
      left = 0,
    },
    text = "󰸗",
    font = b.sysfont(14),
  })

  -- Clock
  local clock_icon = h.text({
    margins = {
      top = 0,
      right = 0,
      bottom = 1,
      left = 0,
    },
    text = "󰥔",
    font = b.sysfont(14),
  })

  local layoutbox = h.text({
    margins = {
      top = 0,
      right = 0,
      bottom = 0,
      left = 0,
    },
    x = 26,
    y = 26, 
    image = b.layout_dwindle,
  })

  -- Systray
  local systray_pop = awful.popup {
    ontop = true,
    border_width = 0,
    border_color = b.border_color_active,
    visible = false,
    type = "desktop",
    widget = {
      id = "background",
      widget = wibox.container.background,
      forced_width = 384,
      forced_height = 26,
      bg = b.bg_normal,
      {
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.systray,
      },
    },
  }

  local systray_autohider = gears.timer {
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
    },
  }

  -- Bar
  local wibar = awful.wibar {
    position = "top",
    screen = s,
    height = 26,
    border_width = 0,
    border_color = b.accent,
    type = "dock",
    widget = {
      layout = wibox.layout.align.horizontal,
      expand = "none",
      { -- Left
        layout = wibox.layout.fixed.horizontal,
        layoutbox,
        bar,
        sep,
        cpu_icon,
        sep,
        cpu,
        sep,
        cpu_widget({
          width = 20,
          color = "#f35252",
        }),
        sep,
        bar,
        sep,
        memory_icon,
        sep,
        memory,
        sep,
        bar,
        sep,
        h.watch([[bash -c "[ $(playerctl -p spotify,tauon,Sonixd status) = "Playing" ] && echo '󰎈'"]], 0.125),
      },
      { -- Center
        layout = wibox.layout.flex.horizontal,
        s.fancy_taglist,
      },
      { -- Right
        layout = wibox.layout.fixed.horizontal,
        h.watch([[bash -c "[ $(xset q | grep Caps | awk '{print $4}') = "on" ] && echo '<span underline=\"single\">A</span>a' || echo 'A<span underline=\"single\">a</span>'"]], 0.125),
        sep,
        bar,
        sep,
        speaker_icon,
        sep,
        h.watch("pamixer --get-volume", 0.25),
        perc,
        sep,
        bar,
        sep,
        calendar_icon,
        sep,
        h.watch("date +'%a %b %-d'", 60),
        sep,
        bar,
        sep,
        clock_icon,
        sep,
        h.watch("date +'%-I:%M %p'", 1),
        sep,
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
