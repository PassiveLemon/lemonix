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

local title = h.text({
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

local artist = h.text({
  margins = {
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 532,
  y = 17,
  halign = "left",
})

local album = h.text({
  margins = {
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  x = 532,
  y = 17,
  halign = "left",
})

local shuffle = h.button({
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

local prev = h.button({
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

local toggle = h.button({
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

local next = h.button({
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

local loop = h.button({
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

local position = h.slider({
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
local volume = h.slider({
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

-- Display updating functions

local function art_image_processor(art_dir, art_url_trim)
  local art_image_load = gears.surface.load_uncached(art_dir .. art_url_trim)
  local image_dyn_height = ((title:get_children_by_id("background")[1].forced_height * 3) + 8)
  art_image:get_children_by_id("background")[1].forced_width = image_dyn_height
  art_image:get_children_by_id("background")[1].forced_height = image_dyn_height
  art_image:get_children_by_id("imagebox")[1].image = art_image_load
  art_image.visible = true
  title:get_children_by_id("background")[1].forced_width = (532 - 8 - image_dyn_height)
  artist:get_children_by_id("background")[1].forced_width = title:get_children_by_id("textbox")[1].width
  album:get_children_by_id("background")[1].forced_width = title:get_children_by_id("textbox")[1].width
end
local function art_image_locator(art_dir, client_cache_dir, art_url_trim, art_url)
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
local function art_image_updater(art_url)
  local function _updater(art_url)
    if art_url == "" then
      art_image.visible = false
      title:get_children_by_id("background")[1].forced_width = 532
    else
      awful.spawn.easy_async("playerctl -l", function(player_list)
        if player_list:find("spotify") then
          local art_url_trim = art_url:gsub(".*/", "")
          art_image_locator(art_dir, nil, art_url_trim, art_url)
        elseif player_list:find("tauon") then
          local art_url_trim = art_url:gsub(".*/", "")
          local client_cache_dir = os.getenv("HOME") .. "/.cache/TauonMusicBox/export/"
          art_image_locator(art_dir, client_cache_dir, art_url_trim, art_url)
        elseif player_list:find("Feishin") then
          local art_url_trim = art_url:match("?id=(.*)&u=Lemon")
          art_image_locator(art_dir, nil, art_url_trim, art_url)
        end
      end)
    end
  end
  if art_url then
    _updater(art_url)
  else
    -- If you run a playerctl command that changes the song, the command will exit but not always after changing the metadata information. This helps ensure that the new metadata is there before running the next command.
    awful.spawn.easy_async_with_shell("sleep 0.05 && " .. playerctl .. " metadata -f {{mpris:artUrl}}", function(art_url)
      _updater(art_url)
    end)
  end
end

local function metadata_updater(title_state, artist_state, album_state)
  local function _title_updater(title_state)
    if title_state == "" then
      artist.visible = false
      album.visible = false
      title:get_children_by_id("textbox")[1].text = "No media found"
    else
      title:get_children_by_id("textbox")[1].text = title_state
    end
  end
  local function _artist_updater(artist_state)
    if artist_state == "" then
      artist.visible = false
    else
      artist.visible = true
      artist:get_children_by_id("textbox")[1].text = "By " .. artist_state
    end
  end
  local function _album_updater(album_state)
    if album_state == "" then
      album.visible = false
    else
      album.visible = true
      album:get_children_by_id("textbox")[1].text = "On " .. album_state
    end
  end
  if title_state then
    _title_updater(title_state)
  else
    awful.spawn.easy_async_with_shell("sleep 0.05 && " .. playerctl .. " metadata -f {{xesam:title}}", function(title_state)
      _title_updater(title_state)
    end)
  end
  if artist_state then
    _artist_updater(artist_state)
  else
    awful.spawn.easy_async_with_shell("sleep 0.05 && " .. playerctl .. " metadata -f {{xesam:artist}}", function(artist_state)
      _artist_updater(artist_state)
    end)
  end
  if album_state then
    _album_updater(album_state)
  else
    awful.spawn.easy_async_with_shell("sleep 0.05 && " .. playerctl .. " metadata -f {{xesam:album}}", function(album_state)
      _album_updater(album_state)
    end)
  end
end

local function shuffle_updater(shuffle_state)
  local function _updater(shuffle_state)
    -- Returning true or false when using metadata -f seems to be a bug? It's been reported upstream.
    if shuffle_state == "On" or shuffle_state == "true" then
      shuffle:get_children_by_id("textbox")[1].text = "󰒝"
    elseif shuffle_state == "Off" or shuffle_state == "false" then
      shuffle:get_children_by_id("textbox")[1].text = "󰒞"
    end
  end
  if shuffle_state then
    _updater(shuffle_state)
  else
    awful.spawn.easy_async_with_shell("sleep 0.05 && " .. playerctl .. " metadata -f {{shuffle}}", function(shuffle_state)
      _updater(shuffle_state)
    end)
  end
end

local function toggle_updater(toggle_state)
  local function _updater(toggle_state)
    if toggle_state == "Playing" then
      toggle:get_children_by_id("textbox")[1].text = "󰏤"
    elseif toggle_state == "Paused" then
      toggle:get_children_by_id("textbox")[1].text = "󰐊"
    end
  end
  if toggle_state then
    _updater(toggle_state)
  else
    awful.spawn.easy_async_with_shell("sleep 0.05 && " .. playerctl .. " metadata -f {{status}}", function(toggle_state)
      _updater(toggle_state)
    end)
  end
end

local function loop_updater(loop_state)
  local function _updater(loop_state)
    if loop_state == "None" then
      loop:get_children_by_id("textbox")[1].text = "󰑗"
    elseif loop_state == "Playlist" then
      loop:get_children_by_id("textbox")[1].text = "󰑖"
    elseif loop_state == "Track" then
      loop:get_children_by_id("textbox")[1].text = "󰑘"
    end
  end
  if loop_state then
    _updater(loop_state)
  else
    awful.spawn.easy_async_with_shell("sleep 0.05 && " .. playerctl .. " metadata -f {{loop}}", function(loop_state)
      _updater(loop_state)
    end)
  end
end

local position_set = true
local slider_update = false
local slider_self_update = true
local function position_updater(position_state, current, length)
  local function _updater(position_state, current, length)
    if (current == "") or (length == "") then
      position.visible = false
    else
      if position_set == true then
        if position_state then
          awful.spawn(playerctl .. " position " .. h.round(((position_state * length) / 100000000), 3))
        end
      end
      if slider_update == true then
        slider_self_update = false
        slider_update = false
        position:get_children_by_id("slider")[1].value = h.round(((current / length) * 100), 3)
      end
    end
  end
  if (current and length) then
    _updater(position_state, current, length)
  else
    awful.spawn.easy_async(playerctl .. " metadata -f {{position}}", function(current)
      awful.spawn.easy_async(playerctl .. " metadata -f {{mpris:length}}", function(length)
        _updater(position_state, current, length)
      end)
    end)
  end
end

local function volume_updater(volume_state)
  local function _updater(volume_state)
    if volume_state == "" then
      volume.visible = false
      volume_icon.visible = false
    else
      volume.visible = true
      volume_icon.visible = true
      volume:get_children_by_id("slider")[1].value = h.round((volume_state * 100), 3)
    end
  end
  if volume_state then
    _updater(volume_state)
  else
    awful.spawn.easy_async(playerctl .. " metadata -f {{volume}}", function(volume_state)
      _updater(volume_state)
    end)
  end
end

-- Controlling functions

local function shuffler()
  awful.spawn.easy_async(playerctl .. " shuffle", function(shuffle_state)
    shuffle_state = shuffle_state:gsub("\n", "")
    if shuffle_state == "On" then
      awful.spawn(playerctl .. " shuffle off")
      shuffle:get_children_by_id("textbox")[1].text = "󰒞"
    elseif shuffle_state == "Off" then
      awful.spawn(playerctl .. " shuffle on")
      shuffle:get_children_by_id("textbox")[1].text = "󰒝"
    end
  end)
end

local function previouser()
  awful.spawn.easy_async(playerctl .. " previous", function()
    awesome.emit_signal("signal::playerctl::update")
  end)
end

local function toggler()
  awful.spawn.easy_async(playerctl .. " status", function(toggle_state)
    toggle_state = toggle_state:gsub("\n", "")
    if toggle_state == "Playing" then
      awful.spawn(playerctl .. " pause")
      toggle:get_children_by_id("textbox")[1].text = "󰐊"
    elseif toggle_state == "Paused" then
      awful.spawn(playerctl .. " play")
      toggle:get_children_by_id("textbox")[1].text = "󰏤"
    end
    awesome.emit_signal("signal::playerctl::update")
  end)
end

local function nexter()
  awful.spawn.easy_async(playerctl .. " next", function()
    awesome.emit_signal("signal::playerctl::update")
  end)
end

local function looper()
  awful.spawn.easy_async(playerctl .. " loop", function(loop_state)
    loop_state = loop_state:gsub("\n", "")
    if loop_state == "None" then
      awful.spawn(playerctl .. " loop Playlist")
      loop:get_children_by_id("textbox")[1].text = "󰑖"
    elseif loop_state == "Playlist" then
      awful.spawn(playerctl .. " loop Track")
      loop:get_children_by_id("textbox")[1].text = "󰑘"
    elseif loop_state == "Track" then
      awful.spawn(playerctl .. " loop None")
      loop:get_children_by_id("textbox")[1].text = "󰑗"
    end
  end)
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
          title,
          artist,
          album,
        },
      },
      {
        layout = wibox.layout.fixed.horizontal,
        shuffle,
        prev,
        toggle,
        next,
        loop,
      },
      {
        layout = wibox.layout.fixed.vertical,
        {
          layout = wibox.layout.stack,
          position,
        },
        {
          layout = wibox.layout.fixed.horizontal,
          volume_icon,
          volume,
        },
      },
    },
  },
})

shuffle:connect_signal("button::press", function()
  shuffler()
end)

prev:connect_signal("button::press", function()
  previouser()
end)

toggle:connect_signal("button::press", function()
  toggler()
end)

next:connect_signal("button::press", function()
  nexter()
end)

loop:connect_signal("button::press", function()
  looper()
end)

position:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, position_state)
  if slider_self_update == true then
    slider.value = position_state
    position_updater(position_state)
  end
  position_set = true
  slider_update = false
  slider_self_update = true
end)

volume:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, volume_state)
  slider.value = volume_state
	awful.spawn(playerctl .. " volume " .. h.round((volume_state / 100), 3))
end)

awesome.connect_signal("signal::playerctl::metadata", function(art_url, title, artist, album, shuffle, status, loop, position, length, volume)
  position_set = false
  slider_update = true
  art_image_updater(art_url)
  metadata_updater(title, artist, album)
  shuffle_updater(shuffle)
  toggle_updater(status)
  loop_updater(loop)
  position_updater(nil, position, length)
  volume_updater(volume)
end)

awesome.connect_signal("ui::media::toggle", function()
  awesome.emit_signal("signal::playerctl::update")
  main.screen = awful.screen.focused()
  main.visible = not main.visible
  h.unfocus()
end)

awesome.connect_signal("ui::media::nexter", function()
  nexter()
end)
awesome.connect_signal("ui::media::toggler", function()
  toggler()
end)
awesome.connect_signal("ui::media::previouser", function()
  previouser()
end)

click_to_hide.popup(main, nil, true)

