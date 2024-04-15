local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")

local h = require("helpers")

local metadata = { }
local playerctl_cmd = "playerctl "

local function emit()
  awesome.emit_signal("signal::playerctl::metadata", metadata)
end

local function playerctl_clients()
  if b.playerctl_clients then
    playerctl_cmd = "playerctl -p '" .. b.playerctl_clients .. "' "
  end
end
playerctl_clients()

local function art_image_locator(client_cache_dir, art_url_trim)
  local art_cache_dir = b.playerctl_art_cache_dir
  if not art_cache_dir then -- We set a fallback directory if user does not define one.
    art_cache_dir = "/tmp/passivelemon/lemonix/media/"
  end
  if not client_cache_dir then
    h.file_test(art_cache_dir, art_url_trim, function(exists)
      if exists then
        metadata.art_image = gears.surface.load_uncached(art_cache_dir .. art_url_trim)
        emit()
      else
        awful.spawn.with_shell("curl -Lso " .. art_cache_dir .. art_url_trim .. ' "' .. metadata.art_url .. '"')
      end
    end)
  else
    h.file_test(client_cache_dir, art_url_trim, function(exists)
      if exists then
        metadata.art_image = gears.surface.load_uncached(client_cache_dir .. art_url_trim)
        emit()
      end
    end)
  end
end
local function art_image_fetch()
  -- By means of the highest priority client, we define the art file name (trim) by grabbing a unique part of the url and a client cache directory if supported.
  if metadata.player_name == "Feishin" then
    local art_url_trim = metadata.art_url:match("?id=(.*)&u=Lemon")
    art_image_locator(nil, art_url_trim)
  elseif metadata.player_name == "spotify" then
    local art_url_trim = metadata.art_url:gsub(".*/", "")
    art_image_locator(nil, art_url_trim)
  elseif metadata.player_name == "tauon" then
    local art_url_trim = metadata.art_url:gsub(".*/", "")
    local client_cache_dir = os.getenv("HOME") .. "/.cache/TauonMusicBox/export/"
    art_image_locator(client_cache_dir, art_url_trim)
  end
end

local function metadata_fetch(position_zero)
  awful.spawn.easy_async(playerctl_cmd .. "metadata -f 'artUrl_{{mpris:artUrl}}title_{{xesam:title}}artist_{{xesam:artist}}album_{{xesam:album}}length_{{mpris:length}}playerName_{{playerName}}shuffle_{{shuffle}}status_{{status}}loop_{{loop}}position_{{position}}volume_{{volume}}'", function(stdout)
    stdout = stdout:gsub("\n", "")
    if stdout == "No player could handle this command" then
      stdout = ""
    end
    -- Media metadata
    metadata.art_url = stdout:match("artUrl_(.*)title_") or ""
    metadata.title = stdout:match("title_(.*)artist_") or ""
    metadata.artist = stdout:match("artist_(.*)album_") or ""
    metadata.album = stdout:match("album_(.*)length_") or ""
    metadata.length = stdout:match("length_(.*)playerName_") or ""
    -- Client metadata
    metadata.player_name = stdout:match("playerName_(.*)shuffle_") or ""
    metadata.shuffle = stdout:match("shuffle_(.*)status_") or ""
    metadata.status = stdout:match("status_(.*)loop_") or ""
    metadata.loop = stdout:match("loop_(.*)position_") or ""
    metadata.position = stdout:match("position_(.*)volume_") or ""
    metadata.volume = stdout:match("volume_(.*)") or ""
    -- Override
    if position_zero then -- Just sets the position to the lowest value a 0-100 slider can actually show so it doesn't fallback to an nil value.
      metadata.position = (metadata.length / 525)
    end
    -- Only run art_image_fetch() if metadata has not been cached yet or the song has changed. Detected by comparing old and new stdouts for media metadata.
    if not metadata.raw_stdout or metadata.raw_stdout:match("artUrl_(.*)shuffle_") ~= stdout:match("artUrl_(.*)shuffle_") then
      metadata.raw_stdout = stdout
      art_image_fetch()
    else
      metadata.raw_stdout = stdout
      emit()
    end
  end)
end
metadata_fetch(true)

local playerctl_timer = gears.timer({
  timeout = 1,
  autostart = true,
  callback = function()
    metadata_fetch()
  end,
})

local function shuffler()
  playerctl_timer:stop()
  if metadata.shuffle == "true" then
    awful.spawn.spawn(playerctl_cmd .. "shuffle off")
    metadata.shuffle = "false"
  elseif metadata.shuffle == "false" then
    awful.spawn.spawn(playerctl_cmd .. "shuffle on")
    metadata.shuffle = "true"
  end
  emit()
  playerctl_timer:start()
end

local function previouser()
  playerctl_timer:stop()
  awful.spawn.spawn(playerctl_cmd .. "previous")
  metadata_fetch(true)
  playerctl_timer:start()
end

local function toggler()
  playerctl_timer:stop()
  if metadata.status == "Playing" then
    awful.spawn.spawn(playerctl_cmd .. "pause")
    metadata.status = "Paused"
  elseif metadata.status == "Paused" then
    awful.spawn.spawn(playerctl_cmd .. "play")
    metadata.status = "Playing"
  end
  emit()
  playerctl_timer:start()
end
local function play_pauser(option)
  playerctl_timer:stop()
  awful.spawn.spawn(playerctl_cmd .. option)
  playerctl_timer:start()
end

local function nexter()
  playerctl_timer:stop()
  awful.spawn.spawn(playerctl_cmd .. "next")
  metadata_fetch(true)
  playerctl_timer:start()
end

local function looper()
  playerctl_timer:stop()
  if metadata.loop == "None" then
    awful.spawn.spawn(playerctl_cmd .. "loop Playlist")
    metadata.loop = "Playlist"
  elseif metadata.loop == "Playlist" then
    awful.spawn.spawn(playerctl_cmd .. "loop Track")
    metadata.loop = "Track"
  elseif metadata.loop == "Track" then
    awful.spawn.spawn(playerctl_cmd .. "loop None")
    metadata.loop = "None"
  end
  emit()
  playerctl_timer:start()
end

local function positioner(position_new)
  playerctl_timer:stop()
  awful.spawn(playerctl_cmd .. "position " .. h.round(((position_new * metadata.length) / 100000000), 3))
  playerctl_timer:start()
end

local function volumer(volume_new)
  playerctl_timer:stop()
  awful.spawn(playerctl_cmd .. "volume " .. h.round((volume_new / 100), 3))
  playerctl_timer:start()
end

awesome.connect_signal("signal::playerctl::update", function()
  playerctl_timer:stop()
  metadata_fetch()
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
awesome.connect_signal("signal::playerctl::pause", function()
  play_pauser("pause")
end)
awesome.connect_signal("signal::playerctl::play", function()
  play_pauser("play")
end)

awesome.connect_signal("signal::playerctl::next", function()
  nexter()
end)

awesome.connect_signal("signal::playerctl::loop", function()
  looper()
end)

awesome.connect_signal("signal::playerctl::position", function(position_new)
  positioner(position_new)
end)

awesome.connect_signal("signal::playerctl::volume", function(volume_new)
  volumer(volume_new)
end)
