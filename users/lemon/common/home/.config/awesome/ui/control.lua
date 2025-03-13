require("signal.playerctl")
require("signal.volume")

local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local user = require("config.user")

local dpi = b.xresources.apply_dpi

local total_width = 350

local volume_icon = h.button({
  margins = {
    top = dpi(3),
    right = dpi(4),
    bottom = dpi(3),
    left = dpi(8),
  },
  x = dpi(18),
  y = dpi(15),
  text = "󰕾",
  font = b.sysfont(dpi(14)),
  no_color = true,
  button_press = function()
    awful.spawn.easy_async("pamixer -t", function()
      awesome.emit_signal("signal::peripheral::volume::update")
    end)
  end
})

local volume_slider = h.slider({
  margins = {
    top = 0,
    right = dpi(16),
    bottom = 0,
    left = b.margins,
  },
  x = dpi(total_width),
  y = dpi(16),
  max = 100,
  handle_width = dpi(16),
  bar_height = dpi(6),
  bar_shape = gears.shape.rounded_rect,
  output_signal = "signal::peripheral::volume",
})
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

local volume_bar = h.background({
  layout = wibox.layout.fixed.horizontal,
  volume_icon,
  volume_slider,
},
{
  x = dpi(total_width - 32 - (b.margins * 6)),
  y = dpi(32),
  bg = b.bg_secondary,
  shape = gears.shape.rounded_bar,
})

local lock_button = h.button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "",
  font = b.sysfont(dpi(12)),
  button_press = function()
    awesome.emit_signal('ui::lock::toggle')
    awesome.emit_signal("signal::playerctl::pause", "%all%")
  end
})

local suspend_button = h.timed_button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "",
  font = b.sysfont(dpi(14)),
  button_press = function()
    awful.spawn("systemctl suspend")
  end
}, 1)
if not user.suspend then
  suspend_button.visible = false
end

local hibernate_button = h.timed_button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "",
  font = b.sysfont(dpi(16)),
  button_press = function()
    awful.spawn("systemctl hibernate")
  end
}, 2)
if not user.hibernate then
  hibernate_button.visible = false
end

local poweroff_button = h.timed_button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "󰐥",
  font = b.sysfont(dpi(15)),
  button_press = function()
    awful.spawn("systemctl poweroff")
  end
}, 3)

local restart_button = h.timed_button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "󰑓",
  font = b.sysfont(dpi(18)),
  button_press = function()
    awful.spawn("systemctl reboot")
  end
}, 5)

local power_button = h.button({
  x = dpi(32),
  y = dpi(32),
  shape = gears.shape.circle,
  text = "󰐥",
  font = b.sysfont(dpi(15)),
})

local power_menu_button_group = wibox.widget({
  layout = wibox.layout.fixed.vertical,
  lock_button,
  suspend_button,
  hibernate_button,
  poweroff_button,
  restart_button,
})

local brightness_icon = h.text({
  margins = {
    top = dpi(3),
    right = dpi(4),
    bottom = dpi(3),
    left = dpi(8),
  },
  x = dpi(18),
  y = dpi(15),
  text = "",
  font = b.sysfont(dpi(14)),
})

local brightness_slider = h.slider({
  margins = {
    top = 0,
    right = dpi(16),
    bottom = 0,
    left = b.margins,
  },
  x = dpi(total_width),
  y = dpi(16),
  max = 255,
  handle_width = dpi(16),
  bar_height = dpi(6),
  bar_shape = gears.shape.rounded_rect,
  output_signal = "signal::peripheral::brightness",
})
awesome.connect_signal("signal::peripheral::brightness::value", function(value)
  if value >= 0 then
    brightness_slider:get_children_by_id("slider")[1]._private.value = value
    brightness_slider:emit_signal("widget::redraw_needed")
  end
end)

local brightness_bar = h.background({
  layout = wibox.layout.fixed.horizontal,
  brightness_icon,
  brightness_slider,
},
{
  x = dpi(total_width - (b.margins * 4)),
  y = dpi(32),
  bg = b.bg_secondary,
  shape = gears.shape.rounded_bar,
})

if not user.has_brightness then
  brightness_bar.visible = false
else
  require("signal.brightness")
end

local xdg_cache_home = h.join_path(os.getenv("HOME"), "/.cache/passivelemon/lemonix/media/")
if not h.is_dir(xdg_cache_home) then
  gears.filesystem.make_directories(xdg_cache_home)
end

local metadata = {
  media = { },
  client = { }
}

local art_image_box = h.text({
  margin = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  x = dpi(130),
  y = dpi(130),
  shape = gears.shape.rounded_rect,
})

local title_text = h.text({
  x = dpi(532),
  y = dpi(17),
  halign = "center",
})

local artist_text = h.text({
  x = dpi(532),
  y = dpi(17),
  halign = "center",
})

local prev_button = h.button({
  x = dpi(50),
  y = dpi(50),
  shape = gears.shape.rounded_rect,
  text = "󰒮",
  font = b.sysfont(dpi(18)),
  button_press = function()
    awesome.emit_signal("signal::playerctl::previous")
  end
})

local toggle_button = h.button({
  x = dpi(50),
  y = dpi(50),
  shape = gears.shape.rounded_rect,
  text = "󰐊",
  font = b.sysfont(dpi(17)),
})

local next_button = h.button({
  x = dpi(50),
  y = dpi(50),
  shape = gears.shape.rounded_rect,
  text = "󰒭",
  font = b.sysfont(dpi(18)),
  button_press = function()
    awesome.emit_signal("signal::playerctl::next")
  end
})

local position_slider = h.slider({
  x = dpi(50 + 50 + 50),
  y = dpi(16),
  max = 100,
  handle_width = dpi(16),
  bar_height = dpi(6),
  bar_shape = gears.shape.rounded_rect,
  output_signal = "signal::playerctl::position",
})

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

local media_player_bar = h.background({
  layout = wibox.layout.fixed.horizontal,
  art_image_box,
  {
    widget = h.margin({
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
    {
      margins = {
        right = dpi(8),
        left = dpi(8),
      },
    })
  },
},
{ -- There's something up in here that stops removing the margin around the art image. It's stuck with a 4px margin
  x = dpi(total_width - (b.margins * 4)),
  y = dpi(130 + (b.margins * 2)),
  bg = b.bg_secondary,
  shape = gears.shape.rounded_rect,
})

toggle_button:connect_signal("button::press", function()
  if metadata.client.state == "Playing" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰐊"
  elseif metadata.client.state == "Paused" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰏤"
  end
  awesome.emit_signal("signal::playerctl::toggle")
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
  local power_popup = h.timed_popup({
    --      screen width, margin, main popup width
    x = (dpi(s.geometry.x + 353) + (b.useless_gap * 2)),
    --      bar height, margin
    y = (dpi(32) + (b.useless_gap * 2)),
    screen = s,
    bg = b.bg_primary,
    fg = b.fg_primary,
    border_width = b.border_width,
    border_color = b.border_color_active,
    ontop = true,
    visible = false,
    type = "popup_menu",
    hide_on_click_anywhere = true,
    widget = h.background({
      layout = wibox.layout.fixed.vertical,
      power_menu_button_group,
    },
    {
      bg = b.bg_primary,
    })
  }, 5)

  power_button:connect_signal("button::press", function()
    if power_popup.screen.index == awful.screen.focused().index then
      power_popup:toggle()
    else
      power_popup:toggle(false)
    end
  end)

  local main = h.timed_popup({
    --      screen width, gap
    x = (dpi(s.geometry.x) + (b.useless_gap * 2)),
    --      bar height, gap
    y = (dpi(32) + (b.useless_gap * 2)),
    screen = s,
    bg = b.bg_primary,
    fg = b.fg_primary,
    border_width = b.border_width,
    border_color = b.border_color_active,
    ontop = true,
    visible = false,
    type = "popup_menu",
    hide_on_click_anywhere = true,
    widget = h.background({
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.layout.fixed.horizontal,
        volume_bar,
        power_button,
      },
      brightness_bar,
      media_player_bar,
    },
    {
      bg = b.bg_primary,
    }),
    mouse_enter = function()
      power_popup:stop()
    end,
    mouse_leave = function()
      power_popup:again()
    end
  }, 5)

  power_popup:connect_signal("mouse::enter", function()
    main:stop()
  end)
  power_popup:connect_signal("mouse::leave", function()
    main:again()
  end)

  awesome.connect_signal("ui::control::toggle", function(force)
    awesome.emit_signal("signal::playerctl::update")
    if force == true then
      main:toggle(true)
    elseif force == false then
      main:toggle(false)
      power_popup:toggle(false)
    elseif main.screen.index == awful.screen.focused().index then
      main:toggle()
      power_popup:toggle(false)
    else
      main:toggle(false)
      power_popup:toggle(false)
    end
  end)
end)

