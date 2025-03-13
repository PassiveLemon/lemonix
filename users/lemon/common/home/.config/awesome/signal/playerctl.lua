local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local naughty = require("naughty")

local h = require("helpers")

-- metadata = {
--   (raw_stdout)
--   media = { (art_url) (title) (artist) (album) (length) (art_image) }
--   client = { (client_name) (shuffle) (status) (loop) (position) (volume) }
-- }

local metadata = {
  raw_stdout = "",
  media = { },
  client = { }
}

local playerctl_cmd = "playerctl " -- This doesn't change. It gets the metadata of the song and active player
local playerctl_cmder = "playerctl " -- This one does change. It is used to control playerctl and can be overridden

local function emit()
  awesome.emit_signal("signal::playerctl::metadata", metadata)
end

if b.playerctl.players then
  playerctl_cmd = "playerctl -p '" .. b.playerctl.players .. "' "
  playerctl_cmder = "playerctl -p '" .. b.playerctl.players .. "' "
end

local function playerctl_players(override)
  if override then
    if override == "%all%" then
      playerctl_cmder = "playerctl --all-players "
    else
      playerctl_cmder = "playerctl -p '" .. override .. "' "
    end
  elseif b.playerctl.players then
    playerctl_cmder = "playerctl -p '" .. b.playerctl.players .. "' "
  end
end

local function art_image_locator(client_cache_dir, art_url_trim)
  local art_cache_dir = b.playerctl.art_cache_dir
  if not art_cache_dir then -- We set a fallback directory if user does not define one
    art_cache_dir = "/tmp/passivelemon/lemonix/media/"
  end
  if not client_cache_dir then
    local art_path = h.join_path(art_cache_dir, art_url_trim)
    if h.is_file(art_path) then
      metadata.media.art_image = gears.surface.load_uncached(art_path)
    else
      awful.spawn.easy_async_with_shell("curl -Lso " .. art_path .. ' "' .. metadata.media.art_url .. '"', function()
        metadata.media.art_image = gears.surface.load_uncached(art_path)
      end)
    end
  else
    local client_art_path = h.join_path(client_cache_dir, art_url_trim)
    if h.is_file(client_art_path) then
      metadata.media.art_image = gears.surface.load_uncached(client_art_path)
    end
  end
end

local function art_image_name(album, backup)
  local album_string = album:gsub("%W", "")
  if album_string == "" or album_string == nil then
    return backup
  else
    return album_string
  end
end

local function art_image_fetch()
  -- We normalize the album name and use that as the cache name for the album art, that way it's only downloaded once per album, which makes caching more efficient. In case the normalization results in a bad filename, we use a backup string
  if metadata.client.player_name == "tauon" then
    local art_url_trim = metadata.media.art_url:gsub(".*/", "")
    local client_cache_dir = h.join_path(os.getenv("HOME"), "/.cache/TauonMusicBox/export/")
    art_image_locator(client_cache_dir, art_url_trim)
  elseif metadata.client.player_name == "Feishin" then
    local art_image_name_backup = metadata.media.art_url:match("?id=(.*)&u=")
    local art_url_trim = art_image_name(metadata.media.album, art_image_name_backup)
    art_image_locator(nil, art_url_trim)
  elseif metadata.client.player_name == "spotify" then
    local art_image_name_backup = metadata.media.art_url:gsub(".*/", "")
    local art_url_trim = art_image_name(metadata.media.album, art_image_name_backup)
    art_image_locator(nil, art_url_trim)
  end
end

-- If the art isn't already cached then the notification will have the art of the previous media
local function track_notification()
  if (b.playerctl.notifications) and (metadata.raw_stdout ~= "") then
    naughty.notification({
      icon = metadata.media.art_image,
      icon_size = 100,
      title = metadata.media.title,
      message = "By " .. metadata.media.artist .. "\nOn " .. metadata.media.album,
    })
  end
end

local function metadata_fetch()
  awful.spawn.easy_async(playerctl_cmd .. "metadata -f 'artUrl_{{mpris:artUrl}}title_{{xesam:title}}artist_{{xesam:artist}}album_{{xesam:album}}length_{{mpris:length}}playerName_{{playerName}}shuffle_{{shuffle}}status_{{status}}loop_{{loop}}position_{{position}}volume_{{volume}}'", function(stdout_raw, _, _, code)
    local stdout = stdout_raw:gsub("\n", "")
    if code == 0 then
      -- Media metadata
      metadata.media.art_url = stdout:match("artUrl_(.*)title_") or ""
      metadata.media.title = stdout:match("title_(.*)artist_") or ""
      metadata.media.artist = stdout:match("artist_(.*)album_") or ""
      metadata.media.album = stdout:match("album_(.*)length_") or ""
      metadata.media.length = stdout:match("length_(.*)playerName_") or ""
      -- Client metadata
      metadata.client.player_name = stdout:match("playerName_(.*)shuffle_") or ""
      metadata.client.shuffle = stdout:match("shuffle_(.*)status_") or ""
      metadata.client.status = stdout:match("status_(.*)loop_") or ""
      metadata.client.loop = stdout:match("loop_(.*)position_") or ""
      metadata.client.position = stdout:match("position_(.*)volume_") or ""
      metadata.client.volume = stdout:match("volume_(.*)") or ""
      -- Fetch art image and send notification when the media metadata changes
      -- Compare the previously stored raw_stdout to the newly fetched stdout
      if metadata.raw_stdout:match("artUrl_(.*)playerName_") ~= stdout:match("artUrl_(.*)playerName_") then
        art_image_fetch()
        track_notification()
      end
    else
      stdout = ""
    end
    metadata.raw_stdout = stdout
    emit()
  end)
end

metadata_fetch()

local playerctl_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function(self)
    metadata_fetch()
    -- Speed up the poll if media is currently playing
    local cur_timeout = self.timeout
    if (metadata.client.status == "Playing") then
      self.timeout = 1
    else
      self.timeout = 5
    end
    if cur_timeout ~= self.timeout then
      self:again()
    end
  end,
})

local function shuffler()
  playerctl_timer:stop()
  if metadata.client.shuffle == "true" then
    awful.spawn.spawn(playerctl_cmder .. "shuffle off")
    metadata.client.shuffle = "false"
  elseif metadata.client.shuffle == "false" then
    awful.spawn.spawn(playerctl_cmder .. "shuffle on")
    metadata.client.shuffle = "true"
  end
  emit()
  playerctl_timer:start()
end

local function previouser()
  playerctl_timer:stop()
  awful.spawn.spawn(playerctl_cmder .. "previous")
  metadata_fetch()
  playerctl_timer:start()
end

local function toggler()
  playerctl_timer:stop()
  if metadata.client.status == "Playing" then
    awful.spawn.spawn(playerctl_cmder .. "pause")
    metadata.client.status = "Paused"
  elseif metadata.client.status == "Paused" then
    awful.spawn.spawn(playerctl_cmder .. "play")
    metadata.client.status = "Playing"
  end
  emit()
  playerctl_timer:start()
end

local function play_pauser(option)
  playerctl_timer:stop()
  awful.spawn.spawn(playerctl_cmder .. option)
  playerctl_timer:start()
end

local function nexter()
  playerctl_timer:stop()
  awful.spawn.spawn(playerctl_cmder .. "next")
  metadata_fetch()
  playerctl_timer:start()
end

local function looper()
  playerctl_timer:stop()
  if metadata.client.loop == "None" then
    awful.spawn.spawn(playerctl_cmder .. "loop Playlist")
    metadata.client.loop = "Playlist"
  elseif metadata.client.loop == "Playlist" then
    awful.spawn.spawn(playerctl_cmder .. "loop Track")
    metadata.client.loop = "Track"
  elseif metadata.client.loop == "Track" then
    awful.spawn.spawn(playerctl_cmder .. "loop None")
    metadata.client.loop = "None"
  end
  emit()
  playerctl_timer:start()
end

local function positioner(position_new)
  playerctl_timer:stop()
  awful.spawn(playerctl_cmder .. "position " .. h.round(((position_new * metadata.media.length) / 100000000), 3))
  playerctl_timer:start()
end

local function volumer(volume_new)
  playerctl_timer:stop()
  awful.spawn(playerctl_cmder .. "volume " .. h.round((volume_new / 100), 3))
  playerctl_timer:start()
end

awesome.connect_signal("signal::playerctl::update", function()
  playerctl_timer:stop()
  metadata_fetch()
  playerctl_timer:start()
end)

awesome.connect_signal("signal::playerctl::shuffle", function(player_override)
  playerctl_players(player_override)
  shuffler()
end)

awesome.connect_signal("signal::playerctl::previous", function(player_override)
  playerctl_players(player_override)
  previouser()
end)

awesome.connect_signal("signal::playerctl::toggle", function(player_override)
  playerctl_players(player_override)
  toggler()
end)
awesome.connect_signal("signal::playerctl::pause", function(player_override)
  playerctl_players(player_override)
  play_pauser("pause")
end)
awesome.connect_signal("signal::playerctl::play", function(player_override)
  playerctl_players(player_override)
  play_pauser("play")
end)

awesome.connect_signal("signal::playerctl::next", function(player_override)
  playerctl_players(player_override)
  nexter()
end)

awesome.connect_signal("signal::playerctl::loop", function(player_override)
  playerctl_players(player_override)
  looper()
end)

awesome.connect_signal("signal::playerctl::position", function(position_new, player_override)
  playerctl_players(player_override)
  positioner(position_new)
end)

awesome.connect_signal("signal::playerctl::volume", function(volume_new, player_override)
  playerctl_players(player_override)
  volumer(volume_new)
end)

