local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Media management menu
--

local artimage = helpers.simpleimg(nil, nil, 4, 4, 4, 4, nil)
local title = helpers.simpletxt(532, 17, 4, 4, 4, 4, nil, beautiful.sysfont(10), "left")
local artist = helpers.simpletxt(532, 17, 0, 4, 4, 4, nil, beautiful.sysfont(10), "left")
local album = helpers.simpletxt(532, 17, 0, 4, 4, 4, nil, beautiful.sysfont(10), "left")
local shuffle = helpers.simplebtn(100, 100, 4, 4, 4, 4, "󰒞", beautiful.sysfont(24))
local prev = helpers.simplebtn(100, 100, 4, 4, 4, 4, "󰒮", beautiful.sysfont(24))
local toggle = helpers.simplebtn(100, 100, 4, 4, 4, 4, "󰐊", beautiful.sysfont(23))
local next = helpers.simplebtn(100, 100, 4, 4, 4, 4, "󰒭", beautiful.sysfont(24))
local loop = helpers.simplebtn(100, 100, 4, 4, 4, 4, "󰑗", beautiful.sysfont(26))

--wip
local position_cur = helpers.simpletxt(532, 15, 4, 4, 4, 4, nil, beautiful.sysfont(10), "left")
local position_tot = helpers.simpletxt(532, 15, 4, 4, 4, 4, nil, beautiful.sysfont(10), "left")
--
local position = helpers.simplesldr(532, 16, 4, 4, 4, 4, 16, 6, 100)
local volume_icon = helpers.simpleicn(18, 15, 3, 5, 3, 0, "󰕾", beautiful.sysfont(14))
local volume = helpers.simplesldr(513, 16, 4, 4, 4, 0, 16, 6, 100)

local function artimageupdater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify metadata mpris:artUrl", function(artUrl)
    artUrl = artUrl.gsub(artUrl, "\n", "")
    if artUrl == "" or artUrl == "No players found" or artUrl == "No player could handle this command" then
      artimage.visible = false
      title:get_children_by_id("background")[1].forced_width = 532
    else
      artUrlTrim = artUrl.gsub(artUrl, ".*/", "")
      artUrlFile = gears.surface.load_uncached("/tmp/mediamenu/" .. artUrlTrim)
      imageAspRat = (artUrlFile:get_width() / artUrlFile:get_height())
      imageDynHeight = ((title:get_children_by_id("background")[1].forced_height * 3) + 8)
      imageDynWidth =  helpers.simplernd((imageAspRat * imageDynHeight), 1)
      awful.spawn.easy_async_with_shell("test -f /tmp/mediamenu/" .. artUrlTrim .. " && echo true || echo false", function(fileTest)
        fileTest = fileTest.gsub(fileTest, "\n", "")
        if fileTest == "false" then
          artimage.visible = false
          imageDynWidth = 0
          awful.spawn.with_shell("curl -Lso /tmp/mediamenu/" .. artUrlTrim .. " " .. artUrl)
        end
      end)
      artimage:get_children_by_id("constraint")[1].forced_width = imageDynWidth
      artimage:get_children_by_id("constraint")[1].forced_height = imageDynHeight
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
    title_state = title_state.gsub(title_state, "\n", "")
    if title_state == "" or title_state == "No players found" or title_state == "No player could handle this command" then
      artist.visible = false
      album.visible = false
      title:get_children_by_id("textbox")[1].text = "No media found"
    else
      title:get_children_by_id("textbox")[1].text = title_state
    end
  end)
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify metadata xesam:artist", function(artist_state)
    artist_state = artist_state.gsub(artist_state, "\n", "")
    if artist_state == "" or artist_state == "No players found" or artist_state == "No player could handle this command" then
      artist.visible = false
    else
      artist.visible = true
      artist:get_children_by_id("textbox")[1].text = "By " .. artist_state
    end
  end)
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify metadata xesam:album", function(album_state)
    album_state = album_state.gsub(album_state, "\n", "")
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

positionset = true
sliderupdate = false
sliderselfupdate = true

-- This is terrible but it works. It gets a slider to update the players position without the position feeding back into the slider and causing recursion.
local function positionupdater(position_state)
  awful.spawn.easy_async("playerctl -p spotify position", function (current)
    current = current.gsub(current, "\n", "")
    if current == "" or current == "No players found" or current == "No player could handle this command" then
      position.visible = false
    else
      position.visible = true
      awful.spawn.easy_async("playerctl -p spotify metadata mpris:length", function(length)
        length = length.gsub(length, "\n", "")
        if length == "" or length == "No players found" or length == "No player could handle this command" then
          position.visible = false
        else
          if positionset == true then
            if position_state then
              awful.spawn("playerctl -p spotify position " .. helpers.simplernd(((position_state * length) / (100000000)), 3))
            end
          end
          if sliderupdate == true then
            sliderselfupdate = false
            sliderupdate = false
            position:get_children_by_id("slider")[1].value = helpers.simplernd(((current * 100000000) / (length)), 3)
          end
        end
      end)
    end
  end)
end

local function volumeupdater()
  awful.spawn.easy_async("playerctl -p spotify volume", function(volume_state)
    volume_state = volume_state.gsub(volume_state, "\n", "")
    if volume_state == "" or volume_state == "No players found" or volume_state == "No player could handle this command" then
      volume.visible = false
      volume_icon.visible = false
    else
      volume.visible = true
      volume_icon.visible = true
      volume:get_children_by_id("slider")[1].value = helpers.simplernd((volume_state * 100), 3)
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

local mediamenu_pop = awful.popup {
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
	awful.spawn("playerctl -p spotify volume " .. helpers.simplernd((volume_state/100), 3))
end)

local function signal()
  artimageupdater()
  metadataupdater()
  toggleupdater()
  shuffleupdater()
  loopupdater()
  positionupdater()
  volumeupdater()
  mediamenu_pop.visible = not mediamenu_pop.visible
  mediamenu_pop.screen = awful.screen.focused()
  helpers.unfocus()
end

click_to_hide.popup(mediamenu_pop, nil, true)

return {
  signal = signal,
  metadataupdater = metadataupdater,
  loopupdater = loopupdater,
  positionupdater = positionupdater,
}
