local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Media player
--

local xdg_cache_home = os.getenv("HOME") .. "/.cache/passivelemon/lemonix/media/"
h.dir_test(xdg_cache_home, function(exists)
  if not exists then
    awful.spawn.easy_async_with_shell("mkdir -p " .. xdg_cache_home)
  end
end)

local art_image_box = h.text({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
})

local title_text = h.text({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 532,
  y = 17,
  halign = "left",
})

local artist_text = h.text({
  margins = {
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 532,
  y = 17,
  halign = "left",
})

local album_text = h.text({
  margins = {
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 532,
  y = 17,
  halign = "left",
})

local shuffle_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 100,
  y = 100,
  shape = gears.shape.rounded_rect,
  text = "󰒞",
  font = b.sysfont(24),
})

local prev_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 100,
  y = 100,
  shape = gears.shape.rounded_rect,
  text = "󰒮",
  font = b.sysfont(24),
})

local toggle_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 100,
  y = 100,
  shape = gears.shape.rounded_rect,
  text = "󰐊",
  font = b.sysfont(23),
})

local next_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 100,
  y = 100,
  shape = gears.shape.rounded_rect,
  text = "󰒭",
  font = b.sysfont(24)
})

local loop_button = h.button({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 100,
  y = 100,
  shape = gears.shape.rounded_rect,
  text = "󰑗",
  font = b.sysfont(26),
})

local position_slider = h.slider({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 532,
  y = 16,
  max = 100,
  handle_width = 16,
  bar_height = 6,
  bar_shape = gears.shape.rounded_rect,
})

local volume_icon = h.text({
  margins = {
    top = 3,
    right = 5,
    bottom = 3,
  },
  x = 18,
  y = 15,
  text = "󰕾",
  font = b.sysfont(14),
})
local volume_slider = h.slider({
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
  },
  x = 513,
  y = 16,
  max = 100,
  handle_width = 16,
  bar_height = 6,
  bar_shape = gears.shape.rounded_rect,
})

local metadata = { }

local function art_image_updater()
  local image_dyn_height = ((title_text:get_children_by_id("background")[1].forced_height * 3) + 8)
  art_image_box:get_children_by_id("background")[1].forced_width = image_dyn_height
  art_image_box:get_children_by_id("background")[1].forced_height = image_dyn_height
  art_image_box:get_children_by_id("imagebox")[1].image = metadata.art_image
  art_image_box.visible = true
  title_text:get_children_by_id("background")[1].forced_width = (532 - 8 - image_dyn_height)
  artist_text:get_children_by_id("background")[1].forced_width = title_text:get_children_by_id("textbox")[1].width
  album_text:get_children_by_id("background")[1].forced_width = title_text:get_children_by_id("textbox")[1].width
end

local function metadata_updater()
  if metadata.title == "" then
    art_image_box.visible = false
    artist_text.visible = false
    album_text.visible = false
    position_slider.visible = false
    volume_icon.visible = false
    volume_slider.visible = false
    title_text:get_children_by_id("textbox")[1].text = "No media found"
  else
    title_text:get_children_by_id("textbox")[1].text = metadata.title
    if metadata.artist == "" then
      artist_text.visible = false
    else
      artist_text.visible = true
      artist_text:get_children_by_id("textbox")[1].text = "By " .. metadata.artist
    end
    if metadata.album == "" then
      album_text.visible = false
    else
      album_text.visible = true
      album_text:get_children_by_id("textbox")[1].text = "On " .. metadata.album
    end
  end
end

local function shuffle_updater()
  if metadata.shuffle == "true" then
    shuffle_button:get_children_by_id("textbox")[1].text = "󰒝"
  elseif metadata.shuffle == "false" then
    shuffle_button:get_children_by_id("textbox")[1].text = "󰒞"
  end
end

local function toggle_updater()
  if metadata.status == "Playing" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰏤"
  elseif metadata.status == "Paused" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰐊"
  end
end

local function loop_updater()
  if metadata.loop == "None" then
    loop_button:get_children_by_id("textbox")[1].text = "󰑗"
  elseif metadata.loop == "Playlist" then
    loop_button:get_children_by_id("textbox")[1].text = "󰑖"
  elseif metadata.loop == "Track" then
    loop_button:get_children_by_id("textbox")[1].text = "󰑘"
  end
end

local function position_updater()
  if (metadata.position == "") or (metadata.length == "") then
    position_slider.visible = false
  else
    position_slider.visible = true
    position_slider:get_children_by_id("slider")[1]._private.value = h.round(((metadata.position / metadata.length) * 100), 3)
    position_slider:emit_signal("widget::redraw_needed")
  end
end

local function volume_updater()
  if metadata.volume == "" then
    volume_slider.visible = false
    volume_icon.visible = false
  else
    volume_slider.visible = true
    volume_icon.visible = true
    volume_slider:get_children_by_id("slider")[1]._private.value = h.round((metadata.volume * 100), 3)
    volume_slider:emit_signal("widget::redraw_needed")
  end
end

local main = awful.popup({
  placement = awful.placement.centered,
  border_width = 3,
  border_color = b.border_color_active,
  ontop = true,
  visible = false,
  maximum_width = 548,
  type = "dock",
  widget = {
    widget = wibox.container.margin,
    margins = {
      top = b.margins,
      right = b.margins,
      bottom = b.margins,
      left = b.margins,
    },
    {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.layout.fixed.horizontal,
        art_image_box,
        {
          layout = wibox.layout.fixed.vertical,
          title_text,
          artist_text,
          album_text,
        },
      },
      {
        layout = wibox.layout.fixed.horizontal,
        shuffle_button,
        prev_button,
        toggle_button,
        next_button,
        loop_button,
      },
      {
        layout = wibox.layout.fixed.vertical,
        {
          layout = wibox.layout.stack,
          position_slider,
        },
        {
          layout = wibox.layout.fixed.horizontal,
          volume_icon,
          volume_slider,
        },
      },
    },
  },
})

shuffle_button:connect_signal("button::press", function()
  if metadata.shuffle == "On" then
    shuffle_button:get_children_by_id("textbox")[1].text = "󰒞"
  elseif metadata.shuffle == "Off" then
    shuffle_button:get_children_by_id("textbox")[1].text = "󰒝"
  end
  awesome.emit_signal("signal::playerctl::shuffle")
end)

prev_button:connect_signal("button::press", function()
  awesome.emit_signal("signal::playerctl::previous")
end)

toggle_button:connect_signal("button::press", function()
  if metadata.state == "Playing" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰐊"
  elseif metadata.state == "Paused" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰏤"
  end
  awesome.emit_signal("signal::playerctl::toggle")
end)

next_button:connect_signal("button::press", function()
  awesome.emit_signal("signal::playerctl::next")
end)

loop_button:connect_signal("button::press", function()
  if metadata.loop == "None" then
    loop_button:get_children_by_id("textbox")[1].text = "󰑖"
  elseif metadata.loop == "Playlist" then
    loop_button:get_children_by_id("textbox")[1].text = "󰑘"
  elseif metadata.loop == "Track" then
    loop_button:get_children_by_id("textbox")[1].text = "󰑗"
  end
  awesome.emit_signal("signal::playerctl::loop")
end)

position_slider:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, position_state)
  slider.value = position_state
  awesome.emit_signal("signal::playerctl::position", position_state)
end)

volume_slider:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, volume_state)
  slider.value = volume_state
  awesome.emit_signal("signal::playerctl::volume", volume_state)
end)

awesome.connect_signal("signal::playerctl::metadata", function(metadata_table)
  metadata = metadata_table
  art_image_updater()
  metadata_updater()
  shuffle_updater()
  toggle_updater()
  loop_updater()
  position_updater()
  volume_updater()
end)

awesome.connect_signal("ui::media::toggle", function()
  awesome.emit_signal("signal::playerctl::update")
  main.screen = awful.screen.focused()
  main.visible = not main.visible
  h.unfocus()
end)

click_to_hide.popup(main, nil, true)

