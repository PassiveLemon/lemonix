require("signal.caps")
require("signal.playerctl")
require("signal.volume")

local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local user = require("config.user")

local dpi = b.xresources.apply_dpi

--
-- Wibar
--

local sep = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = " ",
})

-- NixOS/Systray
local pill_systray = h.timed_widget(h.margin({
  widget = wibox.container.place,
  valign = "center",
  halign = "center",
  forced_height = dpi(24),
  {
    widget = wibox.container.background,
    bg = b.bg_secondary,
    shape = gears.shape.rounded_bar,
    forced_height = dpi(24),
    {
      layout = wibox.layout.fixed.horizontal,
      sep,
      wibox.widget.systray,
    },
  },
},
{
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(2),
  },
}), 3, true)

local pill_nixos = h.button({
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(4),
  },
  x = dpi(24),
  y = dpi(24),
  shape = gears.shape.circle,
  text = "",
  font = b.sysfont(dpi(16)),
  button_press = function()
    pill_systray.screen = awful.screen.focused()
    pill_systray:toggle()
  end,
})

-- CPU
local cpu_icon = h.text({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = dpi(2),
    left = 0,
  },
  text = "",
  font = b.sysfont(dpi(15)),
})
local cpu_text = h.text({
  margins = {
    left = dpi(3),
  },
  halign = "left",
})
awesome.connect_signal("signal::resource::cpu::data", function(use, _)
  cpu_text:get_children_by_id("textbox")[1].text = use .. "%"
end)

local pill_cpu = h.margin({
  widget = wibox.container.place,
  valign = "center",
  halign = "center",
  forced_height = dpi(24),
  {
    widget = wibox.container.background,
    bg = b.bg_secondary,
    shape = gears.shape.rounded_bar,
    forced_height = dpi(24),
    {
      layout = wibox.layout.fixed.horizontal,
      sep,
      cpu_icon,
      cpu_text,
      sep,
    },
  },
},
{
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(2),
  },
})
if not user.bar.cpu then
  pill_cpu.visible = false
else
  require("signal.cpu")
end

-- Memory
local memory_icon = h.text({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = dpi(2),
    left = 0,
  },
  text = "",
  font = b.sysfont(dpi(15)),
})
local memory_text = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = dpi(3),
  },
  halign = "left",
})
awesome.connect_signal("signal::resource::memory::data", function(free_mem_table)
  memory_text:get_children_by_id("textbox")[1].text = h.round(((free_mem_table[2] / free_mem_table[1]) * 100), 0) .. "%"
end)

local pill_memory = h.margin({
  widget = wibox.container.place,
  valign = "center",
  halign = "center",
  forced_height = dpi(24),
  {
    widget = wibox.container.background,
    bg = b.bg_secondary,
    shape = gears.shape.rounded_bar,
    forced_height = dpi(24),
    {
      layout = wibox.layout.fixed.horizontal,
      sep,
      memory_icon,
      memory_text,
      sep,
    },
  },
},
{
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(2),
  },
})
if not user.bar.memory then
  pill_memory.visible = false
else
  require("signal.memory")
end

-- Brightness
local light_icon = h.button({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = 0,
    left = 0,
  },
  text = "󰌵",
  no_color = true,
  button_press = function()
    awesome.emit_signal("signal::peripheral::brightness::update")
    awful.spawn.easy_async("systemctl is-active --quiet --user clight", function(_, _, _, code)
      if code == 0 then
        awful.spawn("systemctl --user stop clight")
      else
        awful.spawn("systemctl --user restart clight")
      end
    end)
  end,
})
local light_text = h.text({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = 0,
    left = dpi(3),
  },
  halign = "left",
})
awesome.connect_signal("signal::peripheral::brightness::value", function(cur, max)
  light_text:get_children_by_id("textbox")[1].text = h.round(((cur / max) * 100), 0) .. "%"
  awful.spawn.easy_async("systemctl is-active --quiet --user clight", function(_, _, _, code)
    if code == 0 then
      light_icon:get_children_by_id("textbox")[1].text = "󰌵"
    else
      light_icon:get_children_by_id("textbox")[1].text = "󱠂"
    end
  end)
end)

local pill_brightness = h.margin({
  widget = wibox.container.place,
  valign = "center",
  halign = "center",
  forced_height = dpi(24),
  {
    widget = wibox.container.background,
    bg = b.bg_secondary,
    shape = gears.shape.rounded_bar,
    forced_height = dpi(24),
    {
      layout = wibox.layout.fixed.horizontal,
      sep,
      light_icon,
      light_text,
      sep,
    },
  },
},
{
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(2),
  },
})
if not user.bar.brightness then
  pill_brightness.visible = false
else
  require("signal.brightness")
end

-- Power
local battery_icon = h.text({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = dpi(2),
    left = 0,
  },
  text = "󰁹",
  font = b.sysfont(dpi(10)),
})
local battery_text = h.text({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = 0,
    left = dpi(3),
  },
  halign = "left",
})
local battery_etr = h.text({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = 0,
    left = dpi(3),
  },
  halign = "left",
})
local battery_icons = {
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
awesome.connect_signal("signal::power", function(ac, perc, time)
  battery_text:get_children_by_id("textbox")[1].text = perc .. "%"
  if not ac then
    battery_icon:get_children_by_id("textbox")[1].text = battery_icons[math.floor(perc / 10)]
    battery_etr.visible = true
    local _etr = h.round((time / 3600), 1)
    if _etr > 1 then
      battery_etr:get_children_by_id("textbox")[1].text = _etr .. " hours"
    else
      battery_etr:get_children_by_id("textbox")[1].text = _etr .. " minutes"
    end
  else
    battery_icon:get_children_by_id("textbox")[1].text = "󰂄"
    battery_etr.visible = false
  end
end)

local pill_battery = h.margin({
  widget = wibox.container.place,
  valign = "center",
  halign = "center",
  forced_height = dpi(24),
  {
    widget = wibox.container.background,
    bg = b.bg_secondary,
    shape = gears.shape.rounded_bar,
    forced_height = dpi(24),
    {
      layout = wibox.layout.fixed.horizontal,
      sep,
      battery_icon,
      battery_text,
      battery_etr,
      sep,
    },
  },
},
{
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(2),
  },
})
if not user.bar.battery then
  pill_battery.visible = false
else
  require("signal.power")
end

local pill_music = h.button({
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(2),
  },
  x = dpi(24),
  y = dpi(24),
  shape = gears.shape.circle,
  text = "󰎈",
  button_press = function()
    awesome.emit_signal("ui::control::toggle")
  end
})
awesome.connect_signal("signal::playerctl::metadata", function(metadata_table)
  if metadata_table.client.status == "Playing" then
    pill_music.visible = true
  else
    pill_music.visible = false
  end
end)

-- Volume
local volume_icon = h.button({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = 0,
    left = 0,
  },
  text = "󰖀",
  no_color = true,
  button_press = function()
    awful.spawn.easy_async("pamixer -t", function()
      awesome.emit_signal("signal::peripheral::volume::update")
    end)
  end
})
local volume_text = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
awesome.connect_signal("signal::peripheral::volume::value", function(value)
  if value == -1 then
    volume_icon:get_children_by_id("textbox")[1].text = "󰝟"
    volume_icon:get_children_by_id("textbox")[1].font = b.sysfont(dpi(17))
    volume_text:get_children_by_id("textbox")[1].text = "Muted"
  elseif value < 33 then
    volume_icon:get_children_by_id("textbox")[1].text = "󰕿"
    volume_icon:get_children_by_id("textbox")[1].font = b.sysfont(dpi(9))
    volume_text:get_children_by_id("textbox")[1].text = tostring(value)
  elseif value < 67 then
    volume_icon:get_children_by_id("textbox")[1].text = "󰖀"
    volume_icon:get_children_by_id("textbox")[1].font = b.sysfont(dpi(13))
    volume_text:get_children_by_id("textbox")[1].text = tostring(value)
  else
    volume_icon:get_children_by_id("textbox")[1].text = "󰕾"
    volume_icon:get_children_by_id("textbox")[1].font = b.sysfont(dpi(15))
    volume_text:get_children_by_id("textbox")[1].text = tostring(value)
  end
end)

-- Caps lock
local caps_icon = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = dpi(3),
  },
  markup = 'A<span underline="single">a</span>',
})
awesome.connect_signal("signal::peripheral::caps::state", function(caps)
  if caps then
    caps_icon:get_children_by_id("textbox")[1].markup = '<span underline="single">A</span>a'
  else
    caps_icon:get_children_by_id("textbox")[1].markup = 'A<span underline="single">a</span>'
  end
end)

local pill_utils = h.margin({
  widget = wibox.container.place,
  valign = "center",
  halign = "center",
  forced_height = dpi(24),
  {
    widget = wibox.container.background,
    bg = b.bg_secondary,
    shape = gears.shape.rounded_bar,
    forced_height = dpi(24),
    {
      layout = wibox.layout.fixed.horizontal,
      sep,
      volume_icon,
      caps_icon,
      sep,
    },
  },
},
{
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(2),
  },
})
if not user.bar.utility then
  pill_utils.visible = false
else
  require("signal.volume")
  require("signal.caps")
end

local pill_date = h.margin({
  widget = wibox.container.place,
  valign = "center",
  halign = "center",
  forced_height = dpi(24),
  {
    widget = wibox.container.background,
    bg = b.bg_secondary,
    shape = gears.shape.rounded_bar,
    forced_height = dpi(24),
    {
      layout = wibox.layout.fixed.horizontal,
      sep,
      {
        widget = wibox.widget.textclock,
        format = "%a %b %-d",
        halign = "left",
      },
      sep,
    },
  },
},
{
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(2),
  },
})

local pill_time = h.margin({
  widget = wibox.container.place,
  valign = "center",
  halign = "center",
  forced_height = dpi(24),
  {
    widget = wibox.container.background,
    bg = b.bg_secondary,
    shape = gears.shape.rounded_bar,
    forced_height = dpi(24),
    {
      layout = wibox.layout.fixed.horizontal,
      sep,
      {
        widget = wibox.widget.textclock,
        format = "%-I:%M %p",
        halign = "left",
      },
      sep,
    },
  },
},
{
  margins = {
    top = 0,
    right = dpi(4),
    bottom = 0,
    left = dpi(2),
  },
})

screen.connect_signal("request::desktop_decoration", function(s)
  awful.tag({ "1", "2", "3", "4" }, s, awful.layout.layouts[1])

  s.taglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = {
      awful.button({ }, 1, function(t) t:view_only() end),
      awful.button({ }, 3, awful.tag.viewtoggle),
      awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
      awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end),
    },
    layout = {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(0),
    },
    widget_template = {
      widget = wibox.container.place,
      valign = "center",
      halign = "center",
      forced_height = dpi(24),
      {
        widget = wibox.container.background,
        bg = b.bg_secondary,
        {
          layout = wibox.layout.fixed.horizontal,
          sep,
          {
            id = "text_role",
            widget = wibox.widget.textbox,
          },
          sep,
        },
      },
    },
  })

  s.tasklist = awful.widget.tasklist({
    screen  = s,
    filter  = awful.widget.tasklist.filter.currenttags,
    buttons = {
      awful.button({ }, 1, function (c)
        c:activate({ context = "tasklist", action = "toggle_minimization" })
      end),
      awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
      awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
    },
    layout = {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(0),
    },
    widget_template = {
      widget = wibox.container.place,
      valign = "center",
      halign = "center",
      forced_height = dpi(20),
      forced_width = dpi(20),
      {
        widget = wibox.container.place,
        {
          id = "imagebox",
          widget = wibox.widget.imagebox,
        },
      },
      create_callback = function(self, c)
        self:get_children_by_id("imagebox")[1].image = c.theme_icon
      end,
    },
  })

  -- Bar
  s.wibar = awful.wibar({
    width = s.geometry.width,
    height = dpi(32),
    screen = s,
    bg = b.bg_primary,
    fg = b.fg_primary,
    border_width = dpi(0),
    position = "top",
    type = "dock",
    widget = {
      layout = wibox.layout.align.horizontal,
      expand = "none",
      { -- Left
        layout = wibox.layout.fixed.horizontal,
        pill_nixos,
        pill_systray,
        {
          widget = wibox.container.margin,
          margins = {
            right = dpi(2),
            left = dpi(2),
          },
          {
            widget = wibox.container.place,
            valign = "center",
            halign = "center",
            forced_height = dpi(24),
            {
              widget = wibox.container.background,
              bg = b.bg_secondary,
              shape = gears.shape.rounded_bar,
              forced_height = dpi(24),
              {
                layout = wibox.layout.fixed.horizontal,
                s.taglist,
              },
            },
          },
        },
        pill_cpu,
        pill_memory,
        pill_brightness,
        pill_battery,
      },
      { -- Center
        layout = wibox.layout.flex.horizontal,
        {
          widget = wibox.container.margin,
          margins = {
            right = dpi(2),
            left = dpi(2),
          },
          {
            widget = wibox.container.place,
            valign = "center",
            halign = "center",
            forced_height = dpi(24),
            {
              widget = wibox.container.background,
              bg = b.bg_secondary,
              shape = gears.shape.rounded_bar,
              forced_height = dpi(24),
              {
                layout = wibox.layout.fixed.horizontal,
                sep,
                s.tasklist,
                sep,
              },
            },
          },
        },
      },
      { -- Right
        layout = wibox.layout.fixed.horizontal,
        pill_music,
        pill_utils,
        pill_date,
        pill_time,
      },
    },
  })

  s.wibar:connect_signal("mouse::leave", function()
    pill_systray:again()
  end)
end)

