local awful = require("awful")
local gears = require("gears")

local playerctl = "playerctl -p spotify,tauon,Feishin -s"

local function round(number, place)
  local decimal = (10 ^ place)
  return (math.floor((number * decimal) + (0.5 / decimal)) / decimal)
end

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

local function emit()
  awesome.emit_signal("signal::playerctl::metadata", art_url, title, artist, album, shuffle, status, loop, position, length, volume)
end

local function metadata()
  awful.spawn.easy_async(playerctl .. " metadata -f 'artUrl_{{mpris:artUrl}}title_{{xesam:title}}artist_{{xesam:artist}}album_{{xesam:album}}shuffle_{{shuffle}}status_{{status}}loop_{{loop}}position_{{position}}length_{{mpris:length}}volume_{{volume}}'", function(stdout)
    stdout = stdout:gsub("\n", "")
    art_url = stdout:match("artUrl_(.*)title_") or ""
    title = stdout:match("title_(.*)artist_") or ""
    artist = stdout:match("artist_(.*)album_") or ""
    album = stdout:match("album_(.*)shuffle_") or ""
    shuffle = stdout:match("shuffle_(.*)status_") or ""
    status = stdout:match("status_(.*)loop_") or ""
    loop = stdout:match("loop_(.*)position_") or ""
    position = stdout:match("position_(.*)length_") or ""
    length = stdout:match("length_(.*)volume_") or ""
    volume = stdout:match("volume_(.*)") or ""
    emit()
  end)
end
metadata()
local playerctl_timer = gears.timer({
  timeout = 1,
  autostart = true,
  callback = function()
    metadata()
  end,
})

local function shuffler()
  playerctl_timer:stop()
  if shuffle == "true" then
    awful.spawn.spawn(playerctl .. " shuffle off")
    shuffle = "false"
    emit()
  elseif shuffle == "false" then
    awful.spawn.spawn(playerctl .. " shuffle on")
    shuffle = "true"
    emit()
  end
  playerctl_timer:start()
end

local function previouser()
  playerctl_timer:stop()
  awful.spawn.spawn(playerctl .. " previous")
  metadata()
  playerctl_timer:start()
end

local function toggler()
  playerctl_timer:stop()
  if status == "Playing" then
    awful.spawn.spawn(playerctl .. " pause")
    status = "Paused"
    emit()
  elseif status == "Paused" then
    awful.spawn.spawn(playerctl .. " play")
    status = "Playing"
    emit()
  end
  playerctl_timer:start()
end

local function nexter()
  playerctl_timer:stop()
  awful.spawn.spawn(playerctl .. " next")
  metadata()
  playerctl_timer:start()
end

local function looper()
  playerctl_timer:stop()
  if loop == "None" then
    awful.spawn.spawn(playerctl .. " loop Playlist")
    loop = "Playlist"
    emit()
  elseif loop == "Playlist" then
    awful.spawn.spawn(playerctl .. " loop Track")
    loop = "Track"
    emit()
  elseif loop == "Track" then
    awful.spawn.spawn(playerctl .. " loop None")
    loop = "None"
    emit()
  end
  playerctl_timer:start()
end

local function positioner(position_new)

end

local function volumer(volume_new)
  awful.spawn(playerctl .. " volume " .. round((volume_new / 100), 3))
end

awesome.connect_signal("signal::playerctl::update", function()
  playerctl_timer:stop()
  metadata()
  playerctl_timer:start()
end)

awesome.connect_signal("signal::playerctl::shuffle", function()
  shuffler()
end)

awesome.connect_signal("signal::playerctl::previous", function()
  previouser()
end)

awesome.connect_signal("signal::playerctl::toggle", function()
  toggler()
end)

awesome.connect_signal("signal::playerctl::next", function()
  nexter()
end)

awesome.connect_signal("signal::playerctl::loop", function()
  looper()
end)

--awesome.connect_signal("signal::playerctl::position", function(position_new)
--  positioner(position_new)
--end)

awesome.connect_signal("signal::playerctl::volume", function(volume_new)
  volumer(volume_new)
end)
