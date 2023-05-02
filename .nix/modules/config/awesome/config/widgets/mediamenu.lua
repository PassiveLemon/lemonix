local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("config.helpers.helpers")
local click_to_hide = require("config.helpers.click_to_hide")

--
-- Media management menu
--

local title = helpers.simpletxt(532, 15, nil, beautiful.font, "left")

local artist = helpers.simpletxt(532, 15, nil, beautiful.font, "left")

local shuffle = helpers.simplebtn(100, 100, "󰒞", beautiful.font_large)

local prev = helpers.simplebtn(100, 100, "󰒮", beautiful.font_large)

local toggle = helpers.simplebtn(100, 100, "󰐊", beautiful.font_large)

local next = helpers.simplebtn(100, 100, "󰒭", beautiful.font_large)

local loop = helpers.simplebtn(100, 100, "󰑗", beautiful.font_large)

local volume = helpers.simplesldr(532, 15, 6, 15)

local function updater()
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl metadata title"]], function(title_state)
    title:get_children_by_id("textbox")[1].text = title_state
  end)
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl metadata artist"]], function(artist_state)
    artist:get_children_by_id("textbox")[1].text = artist_state
  end)
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl shuffle"]], function(shuffle_state)
    if shuffle_state:find("On") then
      shuffle:get_children_by_id("textbox")[1].text = "󰒝"
    elseif shuffle_state:find("Off") then
      shuffle:get_children_by_id("textbox")[1].text = "󰒞"
    end
  end)
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl status"]], function(toggle_state)
    if toggle_state:find("Playing") then
      toggle:get_children_by_id("textbox")[1].text = "󰏤"
    elseif toggle_state:find("Paused") then
      toggle:get_children_by_id("textbox")[1].text = "󰐊"
    end
  end)
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl loop"]], function(loop_state)
    if loop_state:find("None") then
      loop:get_children_by_id("textbox")[1].text = "󰑗"
    elseif loop_state:find("Playlist") then
      loop:get_children_by_id("textbox")[1].text = "󰑖"
    elseif loop_state:find("Track") then
      loop:get_children_by_id("textbox")[1].text = "󰑘"
    end
  end)
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl volume"]], function(volume_state)
    if volume_state:find("No player could handle this command") then
      volume.value = 0
    else
      volume.value = math.floor(volume_state * 100 + 0.5)
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
    updater()
  end)
end

local function toggler()
  awful.spawn.easy_async("playerctl status", function(toggle_state)
    if toggle_state:find("Playing") then
      awful.spawn("playerctl pause")
    elseif toggle_state:find("Paused") then
      awful.spawn("playerctl play")
    end
    updater()
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
    updater()
  end)
end

local mediamenu_container = wibox.widget {
  layout = wibox.layout.align.vertical,
  {
    widget = wibox.container.margin,
    margins = { top = 8, right = 8, bottom = 4, left = 8, },
    {
      layout = wibox.layout.fixed.vertical,
      title,
      artist,
    },
  },
  {
    widget = wibox.container.margin,
    margins = { top = 4, right = 8, bottom = 4, left = 8, },
    {
      layout = wibox.layout.fixed.horizontal,
      shuffle,
      prev,
      toggle,
      next,
      loop,
    },
  },
  {
    widget = wibox.container.margin,
    margins = { top = 4, right = 8, bottom = 8, left = 8, },
    {
      layout = wibox.layout.fixed.horizontal,
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
  shuffler()
end)

prev:connect_signal("button::press", function()
  awful.spawn("playerctl previous")
  updater()
end)

toggle:connect_signal("button::press", function()
  toggler()
end)

next:connect_signal("button::press", function()
  awful.spawn("playerctl next")
  updater()
end)

loop:connect_signal("button::press", function()
  looper()
end)

volume:connect_signal("property::value", function(_, volume_state)
	volume.value = volume_state
	awful.spawn("playerctl volume " .. (volume_state/100), false)
end)

local function signal()
  updater()
  mediamenu_pop.visible = not mediamenu_pop.visible
  mediamenu_pop.screen = awful.screen.focused()
end

click_to_hide.popup(mediamenu_pop, nil, true)

return {
  signal = signal,
  updater = updater,
}