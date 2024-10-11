local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")

local dpi = b.xresources.apply_dpi

local total_width = 350
local total_height = 218

local volume_icon = h.text({
  margins = {
    top = dpi(3),
    right = dpi(4),
    bottom = dpi(3),
    left = dpi(8),
  },
  x = dpi(18),
  y = dpi(15),
  bg = b.bg1,
  text = "󰕾",
  font = b.sysfont(dpi(14)),
})

local volume_slider = h.slider({
  margins = {
    right = dpi(16),
    left = b.margins,
  },
  x = dpi(total_width),
  y = dpi(16),
  bg = b.bg1,
  max = 100,
  handle_width = dpi(16),
  bar_height = dpi(6),
  bar_shape = gears.shape.rounded_rect,
})

volume_slider:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, volume_state)
  slider.value = volume_state
  awesome.emit_signal("signal::peripheral::volume", volume_state)
end)
awesome.connect_signal("signal::peripheral::volume::value", function(value)
  if value == -1 then
    volume_icon:get_children_by_id("textbox")[1].text = "󰝟"
  else
    volume_icon:get_children_by_id("textbox")[1].text = "󰕾"
  end
  if value >= 0 then
    volume_slider:get_children_by_id("slider")[1]._private.value = value
    volume_slider:emit_signal("widget::redraw_needed")
  end
end)

local volume_bar = wibox.widget({
  widget = wibox.container.margin,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  {
    id = "background",
    widget = wibox.container.background,
    forced_width = dpi(total_width - (b.margins * 4) - 32),
    forced_height = dpi(32),
    bg = b.bg1,
    fg = b.ui_main_fg,
    shape = gears.shape.rounded_bar,
    {
      layout = wibox.layout.fixed.horizontal,
      volume_icon,
      volume_slider,
    },
  },
})

local cancel_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "󰜺",
  font = b.sysfont(dpi(14)),
})

local lock_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "",
  font = b.sysfont(dpi(11)),
})

local poweroff_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "󰐥",
  font = b.sysfont(dpi(14)),
})

local restart_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "󰑓",
  font = b.sysfont(dpi(18)),
})

local power_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "󰐥",
  font = b.sysfont(dpi(14)),
})

local power_menu_button_group = wibox.widget({
  visible = false,
  layout = wibox.layout.fixed.horizontal,
  lock_button,
  poweroff_button,
  restart_button,
  cancel_button,
})

cancel_button:connect_signal("button::press", function()
  require("naughty").notify({ title = "cancel" })
  power_menu_button_group.visible = false
  power_button.visible = true
  volume_bar:get_children_by_id("background")[1].forced_width = dpi(total_width - (b.margins * 4) - 32)
end)

lock_button:connect_signal("button::press", function()
  require("naughty").notify({ title = "lock" })
end)

poweroff_button:connect_signal("button::press", function()
  require("naughty").notify({ title = "poweroff" })
end)

restart_button:connect_signal("button::press", function()
  require("naughty").notify({ title = "restart" })
end)

power_button:connect_signal("button::press", function()
  require("naughty").notify({ title = "power" })
  volume_bar:get_children_by_id("background")[1].forced_width = dpi(total_width - (b.margins * 4) - (32 * 4) - (b.margins * 6))
  power_button.visible = false
  power_menu_button_group.visible = true
end)

local brightness_icon = h.text({
  margins = {
    top = dpi(3),
    right = dpi(4),
    bottom = dpi(3),
    left = dpi(8),
  },
  x = dpi(18),
  y = dpi(15),
  bg = b.bg1,
  text = "",
  font = b.sysfont(dpi(14)),
})

local brightness_slider = h.slider({
  margins = {
    right = dpi(16),
    left = b.margins,
  },
  x = dpi(total_width),
  y = dpi(16),
  bg = b.bg1,
  max = 100,
  handle_width = dpi(16),
  bar_height = dpi(6),
  bar_shape = gears.shape.rounded_rect,
})
brightness_slider:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, brightness_state)
  slider.value = brightness_state
  awesome.emit_signal("signal::peripheral::brightness", brightness_state)
end)
awesome.connect_signal("signal::peripheral::brightness::value", function(value)
  if value >= 0 then
    brightness_slider:get_children_by_id("slider")[1]._private.value = value
    brightness_slider:emit_signal("widget::redraw_needed")
  end
end)

local brightness_bar = wibox.widget({
  widget = wibox.container.margin,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  {
    id = "background",
    widget = wibox.container.background,
    forced_width = dpi(total_width - (b.margins * 4)),
    forced_height = dpi(32),
    bg = b.bg1,
    fg = b.ui_main_fg,
    shape = gears.shape.rounded_bar,
    {
      layout = wibox.layout.fixed.horizontal,
      brightness_icon,
      brightness_slider,
    },
  },
})

if not has_brightness then
  brightness_bar.visible = false
end

local xdg_cache_home = os.getenv("HOME") .. "/.cache/passivelemon/lemonix/media/"
if not h.is_dir(xdg_cache_home) then
  gears.filesystem.make_directories(xdg_cache_home)
end

local art_image_box = h.text({
  x = dpi(130),
  y = dpi(130),
  shape = gears.shape.rounded_rect,
})

local title_text = h.text({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = dpi(532),
  y = dpi(17),
  bg = b.bg1,
  halign = "center",
})

local artist_text = h.text({
  margins = {
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = dpi(532),
  y = dpi(17),
  bg = b.bg1,
  halign = "center",
})

local prev_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = dpi(50),
  y = dpi(50),
  shape = gears.shape.rounded_rect,
  text = "󰒮",
  font = b.sysfont(dpi(18)),
})

local toggle_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = dpi(50),
  y = dpi(50),
  shape = gears.shape.rounded_rect,
  text = "󰐊",
  font = b.sysfont(dpi(17)),
})

local next_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = dpi(50),
  y = dpi(50),
  shape = gears.shape.rounded_rect,
  text = "󰒭",
  font = b.sysfont(dpi(18)),
})

local position_slider = h.slider({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = dpi(50 + 50 + 50),
  y = dpi(16),
  bg = b.bg1,
  max = 100,
  handle_width = dpi(16),
  bar_height = dpi(6),
  bar_shape = gears.shape.rounded_rect,
})

local metadata = {
  media = { },
  client = { }
}

local function metadata_updater()
  if metadata.media.title == "" then
    art_image_box.visible = false
    artist_text.visible = false
    position_slider.visible = false
    title_text:get_children_by_id("textbox")[1].text = "No media found"
  else
    title_text:get_children_by_id("textbox")[1].text = metadata.media.title
    if metadata.media.artist == "" then
      artist_text.visible = false
    else
      artist_text.visible = true
      artist_text:get_children_by_id("textbox")[1].text = "By " .. metadata.media.artist
    end
  end
end

local function toggle_updater()
  if metadata.client.status == "Playing" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰏤"
  elseif metadata.client.status == "Paused" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰐊"
  end
end

local function position_updater()
  if (metadata.client.position == "") or (metadata.media.length == "") then
    position_slider.visible = false
  else
    position_slider.visible = true
    position_slider:get_children_by_id("slider")[1]._private.value = h.round(((metadata.client.position / metadata.media.length) * 100), 3)
    position_slider:emit_signal("widget::redraw_needed")
  end
end

local media_player_bar = wibox.widget({
  widget = wibox.container.margin,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  {
    id = "background",
    widget = wibox.container.background,
    forced_width = dpi(total_width - (b.margins * 4)),
    forced_height = dpi(130),
    bg = b.bg1,
    fg = b.ui_main_fg,
    shape = gears.shape.rounded_rect,
    {
      layout = wibox.layout.fixed.horizontal,
      art_image_box,
      {
        widget = wibox.container.margin,
        margins = {
          top = b.margins,
          right = dpi(16),
          bottom = b.margins,
          left = dpi(16),
        },
        {
          layout = wibox.layout.fixed.vertical,
          title_text,
          artist_text,
          {
            layout = wibox.layout.flex.horizontal,
            prev_button,
            toggle_button,
            next_button,
          },
          position_slider,
        },
      },
    },
  },
})

prev_button:connect_signal("button::press", function()
  awesome.emit_signal("signal::playerctl::previous")
end)

toggle_button:connect_signal("button::press", function()
  if metadata.client.state == "Playing" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰐊"
  elseif metadata.client.state == "Paused" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰏤"
  end
  awesome.emit_signal("signal::playerctl::toggle")
end)

next_button:connect_signal("button::press", function()
  awesome.emit_signal("signal::playerctl::next")
end)

position_slider:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, position_state)
  slider.value = position_state
  awesome.emit_signal("signal::playerctl::position", position_state)
end)

awesome.connect_signal("signal::playerctl::metadata", function(metadata_table)
  metadata = metadata_table
  if metadata.raw_stdout == "" then
    media_player_bar.visible = false
  else
    media_player_bar.visible = true
    art_image_box:get_children_by_id("imagebox")[1].image = metadata.media.art_image
    metadata_updater()
    toggle_updater()
    position_updater()
  end
end)

awful.screen.connect_for_each_screen(function(s)
  local main = awful.popup({
    x = dpi(s.geometry.x + 12),
    y = dpi(32 + 12),
    border_width = dpi(3),
    border_color = b.border_color_active,
    ontop = true,
    visible = false,
    screen = s,
    type = "popup_menu",
    widget = {
      widget = wibox.container.margin,
      margins = {
        top = b.margins,
        right = b.margins,
        bottom = b.margins,
        left = b.margins,
      },
      {
        id = "background",
        widget = wibox.container.background,
        bg = b.ui_main_bg,
        {
          layout = wibox.layout.fixed.vertical,
          {
            layout = wibox.layout.fixed.horizontal,
            volume_bar,
            power_button,
            power_menu_button_group,
          },
          brightness_bar,
          media_player_bar,
        },
      },
    },
  })

  awesome.connect_signal("ui::control::toggle", function()
    awesome.emit_signal("signal::playerctl::update")
    if main.screen.index == awful.screen.focused().index then
      main.visible = not main.visible
    else
      main.visible = false
    end
  end)

  click_to_hide.popup(main, nil, true)
end)

