local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Wibar
--

screen.connect_signal("request::desktop_decoration", function(s)
  awful.tag({ "1", "2", "3", "4" }, s, awful.layout.layouts[1])

  -- Space
  local sep = h.text({
    bg = b.bg2,
    text = " ",
  })

  -- CPU
  local cpu_icon = h.text({
    margins = {
      right = dpi(3),
      bottom = dpi(2),
    },
    bg = b.bg2,
    text = "",
    font = b.sysfont(dpi(15)),
  })
  local cpu_text = h.text({
    margins = {
      left = dpi(3),
    },
    bg = b.bg2,
    halign = "left",
  })
  awesome.connect_signal("signal::resource::cpu::data", function(use, _)
    cpu_text:get_children_by_id("textbox")[1].text = use .. "%"
  end)

  -- Memory
  local memory_icon = h.text({
    margins = {
      right = dpi(3),
      bottom = dpi(2),
    },
    bg = b.bg2,
    text = "",
    font = b.sysfont(dpi(15)),
  })
  local memory_text = h.text({
    margins = {
      left = dpi(3),
    },
    bg = b.bg2,
    halign = "left",
  })
  awesome.connect_signal("signal::resource::memory::data", function(free_mem_table)
    memory_text:get_children_by_id("textbox")[1].text = h.round(((free_mem_table[2] / free_mem_table[1]) * 100), 0) .. "%"
  end)

  -- Caps lock
  local caps_icon = h.text({
    margins = {
      left = dpi(3),
    },
    bg = b.bg2,
    markup = 'A<span underline="single">a</span>',
  })
  awesome.connect_signal("signal::peripheral::caps::state", function(caps)
    if caps == "on" then
      caps_icon:get_children_by_id("textbox")[1].markup = '<span underline="single">A</span>a'
    else
      caps_icon:get_children_by_id("textbox")[1].markup = 'A<span underline="single">a</span>'
    end
  end)

  -- Volume
  local volume_icon = h.text({
    margins = {
      right = dpi(3),
    },
    bg = b.bg2,
    text = "󰖀",
  })
  local volume_text = h.text({
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

  -- Internet
  local wifi_icon = h.text({
    margins = {
      right = dpi(3),
      left = dpi(3),
    },
    bg = b.bg2,
    text = "󰤨",
    font = b.sysfont(dpi(14)),
  })

  -- Pills
  local pill_nixos = h.button({
    margins = {
      right = dpi(2),
      left = dpi(4),
    },
    x = dpi(24),
    y = dpi(24),
    bg = b.bg2,
    shape = gears.shape.circle,
    text = "",
    font = b.sysfont(dpi(16)),
    bg_focus = b.bg4,
  })

  local pill_systray = wibox.widget({
    visible = false,
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
        bg = b.bg2,
        shape = gears.shape.rounded_bar,
        forced_height = dpi(24),
        {
          layout = wibox.layout.fixed.horizontal,
          sep,
          wibox.widget.systray,
        },
      },
    },
  })

  local pill_systray_hider = gears.timer({
    timeout = 2,
    single_shot = true,
    callback = function()
      pill_systray.visible = false
    end,
  })

  local pill_cpu = wibox.widget({
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
        bg = b.bg2,
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
  })

  local pill_memory = wibox.widget({
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
        bg = b.bg2,
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
  })

  local pill_music = h.button({
    margins = {
      right = dpi(2),
      left = dpi(2),
    },
    x = dpi(24),
    y = dpi(24),
    bg = b.bg2,
    shape = gears.shape.circle,
    text = "󰎈",
    bg_focus = b.bg4,
  })
  awesome.connect_signal("signal::playerctl::metadata", function(metadata_table)
    if metadata_table.status == "Playing" then
      pill_music.visible = true
    else
      pill_music.visible = false
    end
  end)

  local pill_utils = wibox.widget({
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
        bg = b.bg2,
        shape = gears.shape.rounded_bar,
        forced_height = dpi(24),
        {
          layout = wibox.layout.fixed.horizontal,
          sep,
          volume_icon,
          wifi_icon,
          caps_icon,
          sep,
        },
      },
    },
  })

  local pill_date = wibox.widget({
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
        bg = b.bg2,
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
  })

  local pill_time = wibox.widget({
    widget = wibox.container.margin,
    margins = {
      right = dpi(4),
      left = dpi(2),
    },
    {
      widget = wibox.container.place,
      valign = "center",
      halign = "center",
      forced_height = dpi(24),
      {
        widget = wibox.container.background,
        bg = b.bg2,
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
  })

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
        bg = b.bg2,
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
    position = "top",
    screen = s,
    height = dpi(32),
    border_width = dpi(0),
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
              bg = b.bg2,
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
              bg = b.bg2,
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

  volume_icon:connect_signal("button::press", function()
    awful.spawn.easy_async("pamixer -t", function()
      awesome.emit_signal("signal::peripheral::volume::update")
    end)
  end)

  pill_nixos:connect_signal("button::press", function()
    pill_systray.visible = not pill_systray.visible
    pill_systray.screen = awful.screen.focused()
  end)
  pill_systray:connect_signal("mouse::enter", function()
    pill_systray_hider:stop()
  end)
  pill_systray:connect_signal("mouse::leave", function()
    pill_systray_hider:again()
  end)
  s.wibar:connect_signal("mouse::leave", function()
    pill_systray_hider:again()
  end)

  pill_music:connect_signal("button::press", function()
    awesome.emit_signal("ui::media::toggle")
  end)
end)

