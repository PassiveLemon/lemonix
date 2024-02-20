local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Media player
--

local art_image = h.text({
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

--wip
--local position_cur = h.simpletxt(532, 15, 4, 4, 4, 4, nil, beautiful.sysfont(10), "left")
--local position_tot = h.simpletxt(532, 15, 4, 4, 4, 4, nil, beautiful.sysfont(10), "left")
--

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

local playerctl = "playerctl -p spotify,tauon,Feishin -s"
local art_dir = os.getenv("HOME") .. "/.cache/passivelemon/lemonix/media/"

local art_url = ""
local title = ""
local artist = ""
local album = ""
local shuffle = ""
local status = ""
local loop = ""
local position = ""
local length = ""
local volume = ""

-- Display updating functions

local function art_image_processor(art_dir, art_url_trim)
  local art_image_load = gears.surface.load_uncached(art_dir .. art_url_trim)
  local image_dyn_height = ((title_text:get_children_by_id("background")[1].forced_height * 3) + 8)
  art_image:get_children_by_id("background")[1].forced_width = image_dyn_height
  art_image:get_children_by_id("background")[1].forced_height = image_dyn_height
  art_image:get_children_by_id("imagebox")[1].image = art_image_load
  art_image.visible = true
  title_text:get_children_by_id("background")[1].forced_width = (532 - 8 - image_dyn_height)
  artist_text:get_children_by_id("background")[1].forced_width = title_text:get_children_by_id("textbox")[1].width
  album_text:get_children_by_id("background")[1].forced_width = title_text:get_children_by_id("textbox")[1].width
end
local function art_image_locator(art_dir, client_cache_dir, art_url_trim)
  if client_cache_dir == nil then
    h.file_test(art_dir, art_url_trim, function(file_test)
      if file_test == "true" then
        art_image_processor(art_dir, art_url_trim)
      else
        art_image.visible = false
        awful.spawn.with_shell("curl -Lso " .. art_dir .. art_url_trim .. ' "' .. art_url .. '"')
      end
    end)
  else
    h.file_test(client_cache_dir, art_url_trim, function(file_test)
      if file_test == "true" then
        art_image_processor(client_cache_dir, art_url_trim)
      end
    end)
  end
end
local function art_image_updater()
  if art_url == "" then
    art_image.visible = false
    title_text:get_children_by_id("background")[1].forced_width = 532
  else
    awful.spawn.easy_async("playerctl -l", function(player_list)
      if player_list:find("spotify") then
        local art_url_trim = art_url:gsub(".*/", "")
        art_image_locator(art_dir, nil, art_url_trim)
      elseif player_list:find("tauon") then
        local art_url_trim = art_url:gsub(".*/", "")
        local client_cache_dir = os.getenv("HOME") .. "/.cache/TauonMusicBox/export/"
        art_image_locator(art_dir, client_cache_dir, art_url_trim)
      elseif player_list:find("Feishin") then
        local art_url_trim = art_url:match("?id=(.*)&u=Lemon")
        art_image_locator(art_dir, nil, art_url_trim)
      end
    end)
  end
end

local function metadata_updater()
  if title == "" then
    artist_text.visible = false
    album_text.visible = false
    title_text:get_children_by_id("textbox")[1].text = "No media found"
  else
    title_text:get_children_by_id("textbox")[1].text = title
  end
  if artist == "" then
    artist_text.visible = false
  else
    artist_text.visible = true
    artist_text:get_children_by_id("textbox")[1].text = "By " .. artist
  end
  if album == "" then
    album_text.visible = false
  else
    album_text.visible = true
    album_text:get_children_by_id("textbox")[1].text = "On " .. album
  end
end

local function shuffle_updater()
  if shuffle == "true" then
    shuffle_button:get_children_by_id("textbox")[1].text = "󰒝"
  elseif shuffle == "false" then
    shuffle_button:get_children_by_id("textbox")[1].text = "󰒞"
  end
end

local function toggle_updater()
  if status == "Playing" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰏤"
  elseif status == "Paused" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰐊"
  end
end

local function loop_updater()
  if loop == "None" then
    loop_button:get_children_by_id("textbox")[1].text = "󰑗"
  elseif loop == "Playlist" then
    loop_button:get_children_by_id("textbox")[1].text = "󰑖"
  elseif loop == "Track" then
    loop_button:get_children_by_id("textbox")[1].text = "󰑘"
  end
end

local position_set = true
local slider_update = false
local slider_self_update = true
local function position_updater(position_state)
  if (position == "") or (length == "") then
    position_slider.visible = false
  else
    if position_set == true then
      if position_state then
        awful.spawn(playerctl .. " position " .. h.round(((position_state * length) / 100000000), 3))
      end
    end
    if slider_update == true then
      slider_self_update = false
      slider_update = false
      position_slider:get_children_by_id("slider")[1].value = h.round(((position / length) * 100), 3)
    end
  end
end

local function volume_updater()
  if volume == "" then
    volume_slider.visible = false
    volume_icon.visible = false
  else
    volume_slider.visible = true
    volume_icon.visible = true
    volume_slider:get_children_by_id("slider")[1].value = h.round((volume * 100), 3)
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
        art_image,
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
  if shuffle == "On" then
    shuffle_button:get_children_by_id("textbox")[1].text = "󰒞"
  elseif shuffle == "Off" then
    shuffle_button:get_children_by_id("textbox")[1].text = "󰒝"
  end
  awesome.emit_signal("signal::playerctl::shuffle")
end)

prev_button:connect_signal("button::press", function()
  awesome.emit_signal("signal::playerctl::previous")
end)

toggle_button:connect_signal("button::press", function()
  if state == "Playing" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰐊"
  elseif state == "Paused" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰏤"
  end
  awesome.emit_signal("signal::playerctl::toggle")
end)

next_button:connect_signal("button::press", function()
  awesome.emit_signal("signal::playerctl::next")
end)

loop_button:connect_signal("button::press", function()
  if loop == "None" then
    loop_button:get_children_by_id("textbox")[1].text = "󰑖"
  elseif loop == "Playlist" then
    loop_button:get_children_by_id("textbox")[1].text = "󰑘"
  elseif loop == "Track" then
    loop_button:get_children_by_id("textbox")[1].text = "󰑗"
  end
  awesome.emit_signal("signal::playerctl::loop")
end)

position_slider:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, position_state)
  if slider_self_update == true then
    slider.value = position_state
    position_updater(position_state)
  end
  position_set = true
  slider_update = false
  slider_self_update = true
end)

volume_slider:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, volume_state)
  slider.value = volume_state
  awesome.emit_signal("signal::playerctl::volume", volume_state)
end)

awesome.connect_signal("signal::playerctl::metadata", function(_art_url, _title, _artist, _album, _shuffle, _status, _loop, _position, _length, _volume)
  art_url = _art_url
  title = _title
  artist = _artist
  album = _album
  shuffle = _shuffle
  status = _status
  loop = _loop
  position = _position
  length = _length
  volume = _volume
  position_set = false
  slider_update = true
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

