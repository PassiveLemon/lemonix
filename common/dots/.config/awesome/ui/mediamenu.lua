local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Media management menu
--

local artimage = helpers.text({
  margins = {
    top = 4,
    right = 4,
    bottom = 4,
    left = 4,
  },
})
local title = helpers.text({
  x = 532,
  y = 17,
  margins = {
    top = 4,
    right = 4,
    bottom = 4,
    left = 4,
  },
  halign = "left",
})
local artist = helpers.text({
  x = 532,
  y = 17,
  margins = {
    top = 0,
    right = 4,
    bottom = 4,
    left = 4,
  },
  halign = "left",
})
local album = helpers.text({
  x = 532,
  y = 17,
  margins = {
    top = 0,
    right = 4,
    bottom = 4,
    left = 4,
  },
  halign = "left",
})
local shuffle = helpers.button({
  margins = {
    top = 4,
    right = 4,
    bottom = 4,
    left = 4,
  },
  x = 100,
  y = 100,
  shape = gears.shape.rounded_rect,
  text = "󰒞",
  font = beautiful.sysfont(24),
})
local prev = helpers.button({
  x = 100,
  y = 100,
  margins = {
    top = 4,
    right = 4,
    bottom = 4,
    left = 4,
  },
  shape = gears.shape.rounded_rect,
  text = "󰒮",
  font = beautiful.sysfont(24),
})
local toggle = helpers.button({
  x = 100,
  y = 100,
  margins = {
    top = 4,
    right = 4,
    bottom = 4,
    left = 4,
  },
  shape = gears.shape.rounded_rect,
  text = "󰐊",
  font = beautiful.sysfont(23),
})
local next = helpers.button({
  x = 100,
  y = 100,
  margins = {
    top = 4,
    right = 4,
    bottom = 4,
    left = 4,
  },
  shape = gears.shape.rounded_rect,
  text = "󰒭",
  font = beautiful.sysfont(24)
})
local loop = helpers.button({
  x = 100,
  y = 100,
  margins = {
    top = 4,
    right = 4,
    bottom = 4,
    left = 4,
  },
  shape = gears.shape.rounded_rect,
  text = "󰑗",
  font = beautiful.sysfont(26),
})

--wip
--local position_cur = helpers.simpletxt(532, 15, 4, 4, 4, 4, nil, beautiful.sysfont(10), "left")
--local position_tot = helpers.simpletxt(532, 15, 4, 4, 4, 4, nil, beautiful.sysfont(10), "left")
--

local position = helpers.slider({
  margins = {
    top = 4,
    right = 4,
    bottom = 4,
    left = 4,
  },
  x = 532,
  y = 16, 
  max = 100,
  handle_width = 16,
  bar_height = 6,
  bar_shape = gears.shape.rounded_rect,
})
local volume_icon = helpers.text({
  margins = {
    top = 3,
    right = 5,
    bottom = 3,
    left = 0,
  },
  x = 18, 
  y = 15,
  text = "󰕾",
  font = beautiful.sysfont(14),
})
local volume = helpers.slider({
  margins = {
    top = 4,
    right = 4,
    bottom = 4,
    left = 0,
  },
  x = 513,
  y = 16,
  max = 100,
  handle_width = 16,
  bar_height = 6,
  bar_shape = gears.shape.rounded_rect,
})

local function artimageupdater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify metadata mpris:artUrl", function(artUrl)
    local artUrl = artUrl:gsub(".*/", "")
    if artUrl == "" or artUrl == "No players found" or artUrl == "No player could handle this command" then
      artimage.visible = false
      title:get_children_by_id("background")[1].forced_width = 532
    else
      local tmpDir = os.getenv("HOME") .. "/.cache/lemonix/mediamenu/"
      local artUrlTrim = artUrl:gsub("\n", "")
      local artUrlFile = gears.surface.load_uncached(tmpDir .. artUrlTrim)
      local imageAspRat = (artUrlFile:get_width() / artUrlFile:get_height())
      local imageDynHeight = ((title:get_children_by_id("background")[1].forced_height * 3) + 8)
      local imageDynWidth =  helpers.round((imageAspRat * imageDynHeight), 1)
      awful.spawn.easy_async_with_shell("test -f " .. tmpDir .. artUrlTrim .. " && echo true || echo false", function(fileTest)
        local fileTest = fileTest:gsub("\n", "")
        if fileTest == "false" then
          artimage.visible = false
          imageDynWidth = 0
          awful.spawn.with_shell("curl -Lso " .. tmpDir .. artUrlTrim .. " " .. artUrl)
        end
      end)
      artimage:get_children_by_id("background")[1].forced_width = imageDynWidth
      artimage:get_children_by_id("background")[1].forced_height = imageDynHeight
      artimage:get_children_by_id("imagebox")[1].image = artUrlFile
      artimage.visible = true
      title:get_children_by_id("background")[1].forced_width = (532 - 8 - imageDynWidth)
    end
    artist:get_children_by_id("background")[1].forced_width = title:get_children_by_id("textbox")[1].width
    album:get_children_by_id("background")[1].forced_width = title:get_children_by_id("textbox")[1].width
  end)
end

local function metadataupdater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify metadata xesam:title", function(title_state)
    local title_state = title_state:gsub("\n", "")
    if title_state == "" or title_state == "No players found" or title_state == "No player could handle this command" then
      artist.visible = false
      album.visible = false
      title:get_children_by_id("textbox")[1].text = "No media found"
    else
      title:get_children_by_id("textbox")[1].text = title_state
    end
  end)
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify metadata xesam:artist", function(artist_state)
    local artist_state = artist_state:gsub("\n", "")
    if artist_state == "" or artist_state == "No players found" or artist_state == "No player could handle this command" then
      artist.visible = false
    else
      artist.visible = true
      artist:get_children_by_id("textbox")[1].text = "By " .. artist_state
    end
  end)
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify metadata xesam:album", function(album_state)
    local album_state = album_state:gsub("\n", "")
    if album_state == "" or album_state == "No players found" or album_state == "No player could handle this command" then
      album.visible = false
    else
      album.visible = true
      album:get_children_by_id("textbox")[1].text = "On " .. album_state
    end
  end)
end

local function shuffleupdater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify shuffle", function(shuffle_state)
    if shuffle_state:find("On") then
      shuffle:get_children_by_id("textbox")[1].text = "󰒝"
    elseif shuffle_state:find("Off") then
      shuffle:get_children_by_id("textbox")[1].text = "󰒞"
    end
  end)
end

local function toggleupdater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify status", function(toggle_state)
    if toggle_state:find("Playing") then
      toggle:get_children_by_id("textbox")[1].text = "󰏤"
    elseif toggle_state:find("Paused") then
      toggle:get_children_by_id("textbox")[1].text = "󰐊"
    end
  end)
end

local function loopupdater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify loop", function(loop_state)
    if loop_state:find("None") then
      loop:get_children_by_id("textbox")[1].text = "󰑗"
    elseif loop_state:find("Playlist") then
      loop:get_children_by_id("textbox")[1].text = "󰑖"
    elseif loop_state:find("Track") then
      loop:get_children_by_id("textbox")[1].text = "󰑘"
    end
  end)
end

local positionset = true
local sliderupdate = false
local sliderselfupdate = true

-- This is terrible but it works. It gets a slider to update the players position without the position feeding back into the slider and causing recursion.
local function positionupdater(position_state)
  awful.spawn.easy_async("playerctl -p spotify position", function (current)
    local current = current:gsub("\n", "")
    if current == "" or current == "No players found" or current == "No player could handle this command" then
      position.visible = false
    else
      position.visible = true
      awful.spawn.easy_async("playerctl -p spotify metadata mpris:length", function(length)
        local length = length:gsub("\n", "")
        if length == "" or length == "No players found" or length == "No player could handle this command" then
          position.visible = false
        else
          if positionset == true then
            if position_state then
              awful.spawn("playerctl -p spotify position " .. helpers.round(((position_state * length) / (100000000)), 3))
            end
          end
          if sliderupdate == true then
            sliderselfupdate = false
            sliderupdate = false
            position:get_children_by_id("slider")[1].value = helpers.round(((current * 100000000) / (length)), 3)
          end
        end
      end)
    end
  end)
end

local function volumeupdater()
  awful.spawn.easy_async("playerctl -p spotify volume", function(volume_state)
    local volume_state = volume_state:gsub("\n", "")
    if volume_state == "" or volume_state == "No players found" or volume_state == "No player could handle this command" then
      volume.visible = false
      volume_icon.visible = false
    else
      volume.visible = true
      volume_icon.visible = true
      volume:get_children_by_id("slider")[1].value = helpers.round((volume_state * 100), 3)
    end
  end)
end

local function shuffler()
  awful.spawn.easy_async("playerctl -p spotify shuffle", function(shuffle_state)
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
  awful.spawn.easy_async("playerctl -p spotify status", function(toggle_state)
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
  awful.spawn.easy_async("playerctl -p spotify loop", function(loop_state)
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

local everythingupdater_timer = gears.timer {
  timeout = 1,
  autostart = true,
  callback = function()
    positionset = false
    sliderupdate = true
    artimageupdater()
    metadataupdater()
    toggleupdater()
    shuffleupdater()
    loopupdater()
    positionupdater()
    volumeupdater()
  end,
}

local main = awful.popup {
  placement = awful.placement.centered,
  border_width = 3,
  border_color = beautiful.border_color_active,
  ontop = true,
  visible = false,
  maximum_width = 548,
  widget = {
    layout = wibox.layout.margin,
    margins = {
      top = 4,
      right = 4,
      bottom = 4,
      left = 4,
    },
    {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.layout.fixed.horizontal,
        artimage,
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
  awful.spawn("playerctl -p spotify previous")
  artimageupdater()
  metadataupdater()
  toggleupdater()
  loopupdater()
  positionupdater()
end)

toggle:connect_signal("button::press", function()
  toggler()
end)

next:connect_signal("button::press", function()
  awful.spawn("playerctl -p spotify next")
  artimageupdater()
  metadataupdater()
  toggleupdater()
  loopupdater()
  positionupdater()
end)

loop:connect_signal("button::press", function()
  looper()
end)

position:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, position_state)
  if sliderselfupdate == true then
    slider.value = position_state
    positionupdater(position_state)
  end
  positionset = true
  sliderupdate = false
  sliderselfupdate = true
end)

volume:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, volume_state)
  slider.value = volume_state
	awful.spawn("playerctl -p spotify volume " .. helpers.round((volume_state/100), 3))
end)

local function signal()
  artimageupdater()
  metadataupdater()
  toggleupdater()
  shuffleupdater()
  loopupdater()
  positionupdater()
  volumeupdater()
  main.visible = not main.visible
  main.screen = awful.screen.focused()
  helpers.unfocus()
end

click_to_hide.popup(main, nil, true)

return {
  signal = signal,
  metadataupdater = metadataupdater,
  loopupdater = loopupdater,
  positionupdater = positionupdater,
}
