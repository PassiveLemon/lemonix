local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local naughty = require("naughty")

local helpers = require("config.helpers.helpers")
local click_to_hide = require("config.helpers.click_to_hide")

--
-- Media management menu
--

local title = helpers.simpletxt(516, 15, nil, beautiful.font, "left", 4, 4, 4, 8)

local artist = helpers.simpletxt(516, 15, nil, beautiful.font, "left", 0, 4, 4, 8)

local shuffle = helpers.simplebtn(100, 100, "󰒞", beautiful.font_large, 4, 4, 8, 4)

local prev = helpers.simplebtn(100, 100, "󰒮", beautiful.font_large, 4, 4, 8, 4)

local toggle = helpers.simplebtn(100, 100, "󰐊", beautiful.font_large, 4, 4, 8, 4)

local next = helpers.simplebtn(100, 100, "󰒭", beautiful.font_large, 4, 4, 8, 4)

local loop = helpers.simplebtn(100, 100, "󰑗", beautiful.font_large, 4, 4, 8, 4)

local position = helpers.simpleprog(532, 6, 532, 100, 4, 4, 4, 4)
local positionsldr = helpers.simplesldrhdn(532, 6, 0, 6, 100, 4, 8, 4, 8)

local volume = helpers.simplesldr(532, 16, 16, 6, 100, 4, 4, 4, 4)

local function metadataupdater()
  awful.spawn.easy_async([[sh -c "sleep 0.05 && playerctl metadata title"]], function(title_state)
    if title_state == "" or title_state:find("No player could handle this command") or title_state:find("No Players found") then
      artist.visible = false
      title:get_children_by_id("textbox")[1].text = "No media found"
    else
      artist.visible = true
      title:get_children_by_id("textbox")[1].text = title_state
    end
  end)
  awful.spawn.easy_async([[sh -c "sleep 0.05 && playerctl metadata artist"]], function(artist_state)
    artist:get_children_by_id("textbox")[1].text = artist_state
  end)
end

local function shuffleupdater()
  awful.spawn.easy_async([[sh -c "sleep 0.05 && playerctl shuffle"]], function(shuffle_state)
    if shuffle_state:find("On") then
      shuffle:get_children_by_id("textbox")[1].text = "󰒝"
    elseif shuffle_state:find("Off") then
      shuffle:get_children_by_id("textbox")[1].text = "󰒞"
    end
  end)
end

local function toggleupdater()
  awful.spawn.easy_async([[sh -c "sleep 0.05 && playerctl status"]], function(toggle_state)
    if toggle_state:find("Playing") then
      toggle:get_children_by_id("textbox")[1].text = "󰏤"
    elseif toggle_state:find("Paused") then
      toggle:get_children_by_id("textbox")[1].text = "󰐊"
    end
  end)
end

local function loopupdater()
  awful.spawn.easy_async([[sh -c "sleep 0.05 && playerctl loop"]], function(loop_state)
    if loop_state:find("None") then
      loop:get_children_by_id("textbox")[1].text = "󰑗"
    elseif loop_state:find("Playlist") then
      loop:get_children_by_id("textbox")[1].text = "󰑖"
    elseif loop_state:find("Track") then
      loop:get_children_by_id("textbox")[1].text = "󰑘"
    end
  end)
end

local function positionupdater(test1, position_state)
  awful.spawn.easy_async("playerctl position", function (current)
    if current == "" or current:find("No player could handle this command") or current:find("No Players found") then
      position.visible = false
      positionsldr.visible = false
    else
      position.visible = true
      positionsldr.visible = true
      awful.spawn.easy_async("playerctl metadata mpris:length", function(length)
        position:get_children_by_id("progressbar")[1].value = (((current * 1000000) / length) * 100)
        if position_state then
          awful.spawn("playerctl position " .. ((position_state * length) / (100000000)))
          position:get_children_by_id("progressbar")[1].value = position_state
        end
      end)
    end
  end)
end

local function volumeupdater()
  awful.spawn.easy_async("playerctl volume", function(volume_state)
    if volume_state == "" or volume_state:find("No player could handle this command") or volume_state:find("No Players found") then
      volume.visible = false
    else
      volume.visible = true
      volume:get_children_by_id("slider")[1].value = math.floor(volume_state * 100 + 0.5)
    end
  end)
end

local function shuffler()
  awful.spawn.easy_async("playerctl shuffle", function(shuffle_state)
    if shuffle_state:find("On") then
      awful.spawn("playerctl shuffle off")
    elseif shuffle_state:find("Off") then
      awful.spawn("playerctl shuffle on")
    end
    shuffleupdater()
  end)
end

local function toggler()
  awful.spawn.easy_async("playerctl status", function(toggle_state)
    if toggle_state:find("Playing") then
      awful.spawn("playerctl pause")
    elseif toggle_state:find("Paused") then
      awful.spawn("playerctl play")
    end
    toggleupdater()
  end)
end

local function looper()
  awful.spawn.easy_async("playerctl loop", function(loop_state)
    if loop_state:find("None") then
      awful.spawn("playerctl loop Playlist")
    elseif loop_state:find("Playlist") then
      awful.spawn("playerctl loop Track")
    elseif loop_state:find("Track") then
      awful.spawn("playerctl loop None")
    end
    loopupdater()
  end)
end

local timer = gears.timer {
  timeout = 1,
  autostart = true,
  callback = positionupdater
}

local mediamenu_container = wibox.widget {
  layout = wibox.layout.margin,
  margins = {
    top = 4,
    right = 4,
    bottom = 4,
    left = 4,
  },
  {
    layout = wibox.layout.align.vertical,
    {
      layout = wibox.layout.fixed.vertical,
      title,
      artist,
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
        positionsldr,
      },
      volume,
    },
  },
}

local mediamenu_pop = awful.popup {
  widget = mediamenu_container,
  placement = awful.placement.centered,
  ontop = true,
  border_width = 2,
  border_color = beautiful.border_color_active,
}

mediamenu_pop.visible = false

shuffle:connect_signal("button::press", function()
  gears.timer.start_new(0.1, function()
    shuffler()
  end)
end)

prev:connect_signal("button::press", function()
  awful.spawn("playerctl previous")
  gears.timer.start_new(0.1, function()
    metadataupdater()
    loopupdater()
    positionupdater()
  end)
end)

toggle:connect_signal("button::press", function()
  gears.timer.start_new(0.1, function()
    toggler()
  end)
end)

next:connect_signal("button::press", function()
  awful.spawn("playerctl next")
  gears.timer.start_new(0.1, function()
    metadataupdater()
    loopupdater()
    positionupdater()
  end)
end)

loop:connect_signal("button::press", function()
  looper()
end)

positionsldr:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, position_state)
  positionupdater(nil, position_state)
end)

volume:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, volume_state)
  slider.value = volume_state
	awful.spawn("playerctl volume " .. (volume_state/100))
end)

local function signal()
  gears.timer.start_new(0.1, function()
    metadataupdater()
    toggleupdater()
    shuffleupdater()
    loopupdater()
    positionupdater()
    volumeupdater()
  end)
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