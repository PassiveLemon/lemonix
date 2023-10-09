local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Media management menu
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
  x = 532,
  y = 17,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  halign = "left",
})
local artist = h.text({
  x = 532,
  y = 17,
  margins = {
    top = 0,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  halign = "left",
})
local album = h.text({
  x = 532,
  y = 17,
  margins = {
    top = 0,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
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
  x = 100,
  y = 100,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  shape = gears.shape.rounded_rect,
  text = "󰒮",
  font = b.sysfont(24),
})
local toggle = h.button({
  x = 100,
  y = 100,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  shape = gears.shape.rounded_rect,
  text = "󰐊",
  font = b.sysfont(23),
})
local next = h.button({
  x = 100,
  y = 100,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
  shape = gears.shape.rounded_rect,
  text = "󰒭",
  font = b.sysfont(24)
})
local loop = h.button({
  x = 100,
  y = 100,
  margins = {
    top = b.margins,
    right = b.margins,
    bottom = b.margins,
    left = b.margins,
  },
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
    left = 0,
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
    left = 0,
  },
  x = 513,
  y = 16,
  max = 100,
  handle_width = 16,
  bar_height = 6,
  bar_shape = gears.shape.rounded_rect,
})

local playerctl = "playerctl -p spotify,tauon"
local tmp_dir = os.getenv("HOME") .. "/.cache/lemonix/mediamenu/"

local function art_image_updater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && " .. playerctl .. " metadata mpris:artUrl", function(art_url)
    local art_url = art_url:gsub("\n", "")
    if art_url == "" or art_url == "No players found" or art_url == "No player could handle this command" then
      art_image.visible = false
      title:get_children_by_id("background")[1].forced_width = 532
    else
      -- Resize and scale the image box based on preview dimensions. Pointless if the image is always the same shape.
      local art_url_trim = art_url:gsub(".*/", "")
      local art_url_file = gears.surface.load_uncached(tmp_dir .. art_url_trim)
      local image_asp_rat = (art_url_file:get_width() / art_url_file:get_height())
      local image_dyn_height = ((title:get_children_by_id("background")[1].forced_height * 3) + 8)
      local image_dyn_width =  h.round((image_asp_rat * image_dyn_height), 1)
      awful.spawn.easy_async_with_shell("test -f " .. tmp_dir .. art_url_trim .. " && echo true || echo false", function(file_test)
        local file_test = file_test:gsub("\n", "")
        if file_test == "false" then
          art_image.visible = false
          awful.spawn.with_shell("curl -Lso " .. tmp_dir .. art_url_trim .. " " .. art_url)
        end
      end)
      art_image:get_children_by_id("background")[1].forced_width = image_dyn_width
      art_image:get_children_by_id("background")[1].forced_height = image_dyn_height
      art_image:get_children_by_id("imagebox")[1].image = art_url_file
      art_image.visible = true
      title:get_children_by_id("background")[1].forced_width = (532 - 8 - image_dyn_width)
    end
    artist:get_children_by_id("background")[1].forced_width = title:get_children_by_id("textbox")[1].width
    album:get_children_by_id("background")[1].forced_width = title:get_children_by_id("textbox")[1].width
  end)
end

local function metadata_updater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && " .. playerctl .. " metadata xesam:title", function(title_state)
    local title_state = title_state:gsub("\n", "")
    if title_state == "" or title_state == "No players found" or title_state == "No player could handle this command" then
      artist.visible = false
      album.visible = false
      title:get_children_by_id("textbox")[1].text = "No media found"
    else
      title:get_children_by_id("textbox")[1].text = title_state
    end
  end)
  awful.spawn.easy_async_with_shell("sleep 0.15 && " .. playerctl .. " metadata xesam:artist", function(artist_state)
    local artist_state = artist_state:gsub("\n", "")
    if artist_state == "" or artist_state == "No players found" or artist_state == "No player could handle this command" then
      artist.visible = false
    else
      artist.visible = true
      artist:get_children_by_id("textbox")[1].text = "By " .. artist_state
    end
  end)
  awful.spawn.easy_async_with_shell("sleep 0.15 && " .. playerctl .. " metadata xesam:album", function(album_state)
    local album_state = album_state:gsub("\n", "")
    if album_state == "" or album_state == "No players found" or album_state == "No player could handle this command" then
      album.visible = false
    else
      album.visible = true
      album:get_children_by_id("textbox")[1].text = "On " .. album_state
    end
  end)
end

local function shuffle_updater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && " .. playerctl .. " shuffle", function(shuffle_state)
    if shuffle_state:find("On") then
      shuffle:get_children_by_id("textbox")[1].text = "󰒝"
    elseif shuffle_state:find("Off") then
      shuffle:get_children_by_id("textbox")[1].text = "󰒞"
    end
  end)
end

local function toggle_updater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && " .. playerctl .. " status", function(toggle_state)
    if toggle_state:find("Playing") then
      toggle:get_children_by_id("textbox")[1].text = "󰏤"
    elseif toggle_state:find("Paused") then
      toggle:get_children_by_id("textbox")[1].text = "󰐊"
    end
  end)
end

local function loop_updater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && " .. playerctl .. " loop", function(loop_state)
    if loop_state:find("None") then
      loop:get_children_by_id("textbox")[1].text = "󰑗"
    elseif loop_state:find("Playlist") then
      loop:get_children_by_id("textbox")[1].text = "󰑖"
    elseif loop_state:find("Track") then
      loop:get_children_by_id("textbox")[1].text = "󰑘"
    end
  end)
end

local position_set = true
local slider_update = false
local slider_self_update = true

-- This is terrible but it works. It gets a slider to update the players position without the position feeding back into the slider and causing recursion.
local function position_updater(position_state)
  awful.spawn.easy_async(playerctl .. " position", function(current)
    local current = current:gsub("\n", "")
    if current == "" or current == "No players found" or current == "No player could handle this command" then
      position.visible = false
    else
      position.visible = true
      awful.spawn.easy_async(playerctl .. " metadata mpris:length", function(length)
        local length = length:gsub("\n", "")
        if length == "" or length == "No players found" or length == "No player could handle this command" then
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
            position:get_children_by_id("slider")[1].value = h.round(((current * 100000000) / (length)), 3)
          end
        end
      end)
    end
  end)
end

local function volume_updater()
  awful.spawn.easy_async(playerctl .. " volume", function(volume_state)
    local volume_state = volume_state:gsub("\n", "")
    if volume_state == "" or volume_state == "No players found" or volume_state == "No player could handle this command" then
      volume.visible = false
      volume_icon.visible = false
    else
      volume.visible = true
      volume_icon.visible = true
      volume:get_children_by_id("slider")[1].value = h.round((volume_state * 100), 3)
    end
  end)
end

local function shuffler()
  awful.spawn.easy_async(playerctl .. " shuffle", function(shuffle_state)
    if shuffle_state:find("On") then
      awful.spawn("playerctl -p spotify shuffle off")
      shuffle:get_children_by_id("textbox")[1].text = "󰒞"
    elseif shuffle_state:find("Off") then
      awful.spawn("playerctl -p spotify shuffle on")
      shuffle:get_children_by_id("textbox")[1].text = "󰒝"
    end
  end)
end

local function toggler()
  awful.spawn.easy_async(playerctl .. " status", function(toggle_state)
    if toggle_state:find("Playing") then
      awful.spawn("playerctl -p spotify pause")
      toggle:get_children_by_id("textbox")[1].text = "󰐊"
    elseif toggle_state:find("Paused") then
      awful.spawn("playerctl -p spotify play")
      toggle:get_children_by_id("textbox")[1].text = "󰏤"
    end
  end)
end

local function looper()
  awful.spawn.easy_async(playerctl .. " loop", function(loop_state)
    if loop_state:find("None") then
      awful.spawn("playerctl -p spotify loop Playlist")
      loop:get_children_by_id("textbox")[1].text = "󰑖"
    elseif loop_state:find("Playlist") then
      awful.spawn("playerctl -p spotify loop Track")
      loop:get_children_by_id("textbox")[1].text = "󰑘"
    elseif loop_state:find("Track") then
      awful.spawn("playerctl -p spotify loop None")
      loop:get_children_by_id("textbox")[1].text = "󰑗"
    end
  end)
end

local everything_updater = gears.timer {
  timeout = 1,
  autostart = true,
  callback = function()
    position_set = false
    slider_update = true
    art_image_updater()
    metadata_updater()
    toggle_updater()
    shuffle_updater()
    loop_updater()
    position_updater()
    volume_updater()
  end,
}

local main = awful.popup {
  placement = awful.placement.centered,
  border_width = 3,
  border_color = b.border_color_active,
  ontop = true,
  visible = false,
  maximum_width = 548,
  widget = {
    layout = wibox.layout.margin,
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
}

shuffle:connect_signal("button::press", function()
  shuffler()
end)

prev:connect_signal("button::press", function()
  awful.spawn(playerctl .. " previous")
  art_image_updater()
  metadata_updater()
  toggle_updater()
  loop_updater()
  position_updater()
end)

toggle:connect_signal("button::press", function()
  toggler()
end)

next:connect_signal("button::press", function()
  awful.spawn(playerctl .. " next")
  art_image_updater()
  metadata_updater()
  toggle_updater()
  loop_updater()
  position_updater()
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

local function signal()
  art_image_updater()
  metadata_updater()
  toggle_updater()
  shuffle_updater()
  loop_updater()
  position_updater()
  volume_updater()
  main.visible = not main.visible
  main.screen = awful.screen.focused()
  h.unfocus()
end

click_to_hide.popup(main, nil, true)

return {
  signal = signal,
  metadata_updater = metadata_updater,
  loop_updater = loop_updater,
  position_updater = position_updater,
}
