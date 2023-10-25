local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")
local fancy_taglist = require("modules.fancy_taglist")

local volume = require("signal.volume")
local panel = require("ui.panel")

--
-- Wibar
--

screen.connect_signal("request::desktop_decoration", function(s)
  awful.tag({ "", "", "", }, s, awful.layout.layouts[1])

  -- Separator bar
  local bar = h.text({
    text = "│",
  })

  -- Space
  local sep = h.text({
    text = " ",
  })

  -- Percent
  local perc = h.text({
    text = "%",
  })

  -- CPU
  local cpu_icon = h.text({
    margins = {
      right = 1,
      bottom = 2,
    },
    text = "",
    font = b.sysfont(15),
  })
  local cpu_text = h.text({
    halign = "left",
  })
  awesome.connect_signal("signal::cpu", function(use, temp)
    cpu_text:get_children_by_id("textbox")[1].text = use .. "%"
  end)

  -- Memory
  local memory_icon = h.text({
    margins = {
      right = 2,
      bottom = 2,
    },
    text = "",
    font = b.sysfont(15),
  })
  local memory_text = h.text({
    halign = "left",
  })
  awesome.connect_signal("signal::memory", function(use, use_perc, cache, cache_perc)
    memory_text:get_children_by_id("textbox")[1].text = use_perc .. "%"
  end)

  -- Battery
  local battery_icon = h.text({
    margins = {
      right = 2,
      bottom = 2,
    },
    text = "",
    font = b.sysfont(15),
  })
  local battery_text = h.text({
    halign = "left",
  })
  local battery_etr = h.text({
    halign = "left",
  })
  awesome.connect_signal("signal::battery", function(use, now, full)
    battery_text:get_children_by_id("textbox")[1].text = h.round(((now / full) * 100), 0) .. "%"
    battery_etr:get_children_by_id("textbox")[1].text = h.round(((full - now) / (use)), 1) .. " hours"
  end)

  -- Music
  local music_icon = h.text({
    text = "󰎈",
  })
  awesome.connect_signal("signal::playerctl", function(_, _, _, _, _, status)
    if status == "Playing" then
      music_icon:get_children_by_id("textbox")[1].text = "󰎈"
    else
      music_icon:get_children_by_id("textbox")[1].text = ""
    end
  end)

  -- Volume
  local volume_icon = h.text({
    margins = {
      bottom = 1,
    },
    text = "󰕾",
    font = b.sysfont(14),
  })
  local volume_text = h.text({
    halign = "left",
  })
  awesome.connect_signal("signal::volume", function(value)
    volume_text:get_children_by_id("textbox")[1].text = value .. ""
  end)

  -- Calendar
  local calendar_icon = h.text({
    margins = {
      bottom = 3,
    },
    text = "󰸗",
    font = b.sysfont(14),
  })

  -- Clock
  local clock_icon = h.text({
    margins = {
      bottom = 1,
    },
    text = "󰥔",
    font = b.sysfont(14),
  })

  local layoutbox = h.text({
    x = 26,
    y = 26, 
    image = b.layout_dwindle,
  })

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
        cpu_text,
        sep,
        bar,
        sep,
        memory_icon,
        sep,
        memory_text,
        sep,
        bar,
        sep,
        battery_icon,
        sep,
        battery_text,
        sep,
        battery_etr,
        sep,
        bar,
        sep,
        music_icon,
      },
      { -- Center
        layout = wibox.layout.flex.horizontal,
        s.fancy_taglist,
      },
      { -- Right
        layout = wibox.layout.fixed.horizontal,
        sep,
        bar,
        sep,
        volume_icon,
        sep,
        volume_text,
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
        h.watch("date +'%-I:%M %p'", 3),
        sep,
      },
    },
  }

  volume_text:connect_signal("button::press", function()
    awful.spawn.easy_async("pamixer -t", function()
      volume.volume()
    end)
  end)

  layoutbox:connect_signal("button::press", function()
    panel.signal()
  end)
end)
