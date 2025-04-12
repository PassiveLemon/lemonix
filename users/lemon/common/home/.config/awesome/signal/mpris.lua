local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local naughty = require("naughty")

local h = require("helpers")

local mpris = require("lgi").require("AstalMpris")

-- metadata = {
--   media = { (art_url) (title) (artist) (album) (length) (art_image) }
--   player = { (available) (name) (shuffle) (status) (loop) (position) (volume) }
-- }

local metadata = {
  media = {
    art_url = "",
    title = "",
    artist = "",
    album = "",
    length = "",
    art_image = nil,
  },
  player = {
    name = "",
    shuffle = "",
    status = "",
    loop = "",
    position = "",
    volume = "",
  },
}

local function emit()
  awesome.emit_signal("signal::mpris::metadata", metadata)
end

-- players = {
--   [(player)] = mpris.Player
-- }

local players = { }
-- This gets overriden as soon as a player becomes available so it doesn't really matter what this actually is. It's only set so we don't get nil errors
local global_player = mpris.Player.new(b.mpris_players[1])

local function init_players()
  for _, player in pairs(b.mpris_players) do
    players[player] = mpris.Player.new(player)
  end
end

init_players()

-- TODO: Implement player overrides and %all%.

local function art_image_locator(cache_dir, trim)
  local art_cache_dir = b.mpris_art_cache_dir
  -- We set a fallback directory if user does not define one
  if not art_cache_dir then
    art_cache_dir = "/tmp/passivelemon/lemonix/media/"
  end
  if not cache_dir then
    local art_path = h.join_path(art_cache_dir, trim)
    if h.is_file(art_path) then
      metadata.media.art_image = gears.surface.load_uncached(art_path)
    else
      awful.spawn.easy_async_with_shell("curl -Lso " .. art_path .. ' "' .. metadata.media.art_url .. '"', function()
        metadata.media.art_image = gears.surface.load_uncached(art_path)
      end)
    end
  else
    local player_art_path = h.join_path(cache_dir, trim)
    if h.is_file(player_art_path) then
      metadata.media.art_image = gears.surface.load_uncached(player_art_path)
    end
  end
end

-- art_image_player_lookup = {
--   [(player)] = { (cache) (trim) (backup) }
-- }

local art_image_player_lookup = {
  ["Feishin"] = {
    cache = nil,
    trim = nil,
    backup = "?id=(.*)&u=",
  },
  ["tauon"] = {
    cache = h.join_path(os.getenv("HOME"), "/.cache/TauonMusicBox/export/"),
    trim = "/(.*)",
    backup = nil,
  },
  ["spotify"] = {
    cache = nil,
    trim = nil,
    backup = "/(.*)",
  },
}

local function art_image_fetch()
  -- We normalize the album name and use that as the cache name for the album art, that way it's only downloaded once per album, which makes caching more efficient. In case the normalization results in a bad filename, we use a backup string
  local player_lookup = art_image_player_lookup[metadata.player.name]
  local trim = ""
  if not player_lookup.trim then
    local album_string = metadata.media.album:gsub("%W", "")
    if album_string == "" or not album_string then
      trim = metadata.media.art_url:match(player_lookup.backup)
    else
      trim = album_string
    end
  end
  art_image_locator(player_lookup.cache, trim)
end

-- If the art isn't already cached then the notification will have the art of the previous media
local function track_notification()
  -- awesome.emit_signal("ui::control::notification::mpris", true)
  if b.mpris_notifications and metadata.player.available then
    naughty.notification({
      icon = metadata.media.art_image,
      icon_size = 100,
      title = metadata.media.title,
      message = "By " .. metadata.media.artist .. "\nOn " .. metadata.media.album,
    })
  end
end

local function metadata_fetch()
  -- Get first available player
  for player_name, player in pairs(players) do
    if player.available then
      -- Sleep here to "improve" responsiveness. Otherwise it happens so quickly that we end up grabbing the old media metadata
      awful.spawn.easy_async("sleep 0.1", function()
        if player.available then
          local old_media = metadata.media.art_url..metadata.media.title..metadata.media.artist..metadata.media.album..metadata.media.length
          local new_media = player.art_url..player.title..player.artist..player.album..player.length

          -- Media metadata
          metadata.media.art_url = player.art_url
          metadata.media.title = player.title
          metadata.media.artist = player.artist
          metadata.media.album = player.album
          metadata.media.length = player.length

          -- Player metadata
          metadata.player.available = true
          metadata.player.name = player_name
          metadata.player.shuffle = player.shuffle_status
          metadata.player.status = player.playback_status
          metadata.player.loop = player.loop_status
          metadata.player.position = player.position
          metadata.player.volume = player.volume

          global_player = player

          -- Fetch art image and send notification when the media metadata changes
          -- Compare the previously stored metadata to the newly fetched metadata
          if old_media ~= new_media then
            art_image_fetch()
            track_notification()
          end
          emit()
        end
      end)
      return
    end
  end
  metadata.player.available = false
  emit()
end

metadata_fetch()

local mpris_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function(self)
    metadata_fetch()
    -- Speed up the poll if media is currently playing
    local cur_timeout = self.timeout
    if metadata.player.status == "PLAYING" then
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
  mpris_timer:stop()
  if metadata.player.shuffle == "ON" then
    metadata.player.shuffle = "OFF"
  elseif metadata.player.shuffle == "OFF" then
    metadata.player.shuffle = "ON"
  end
  global_player:shuffle()
  emit()
  mpris_timer:start()
end

local function previouser()
  mpris_timer:stop()
  global_player:previous()
  metadata_fetch()
  mpris_timer:start()
end

local function toggler()
  mpris_timer:stop()
  if metadata.player.status == "PLAYING" then
    metadata.player.status = "PAUSED"
  elseif metadata.player.status == "PAUSED" then
    metadata.player.status = "PLAYING"
  end
  global_player:play_pause()
  emit()
  mpris_timer:start()
end

local function play_pauser(option)
  mpris_timer:stop()
  if option == "play" then
    global_player:play()
  elseif option == "pause" then
    global_player:pause()
  end
  mpris_timer:start()
end

local function nexter()
  mpris_timer:stop()
  global_player:next()
  metadata_fetch()
  mpris_timer:start()
end

local function looper()
  mpris_timer:stop()
  if metadata.player.loop == "NONE" then
    metadata.player.loop = "PLAYLIST"
  elseif metadata.player.loop == "PLAYLIST" then
    metadata.player.loop = "TRACK"
  elseif metadata.player.loop == "TRACK" then
    metadata.player.loop = "NONE"
  end
  global_player:loop()
  emit()
  mpris_timer:start()
end

local function positioner(position_new)
  mpris_timer:stop()
  global_player.position = h.round(((position_new * metadata.media.length) / 100), 3)
  mpris_timer:start()
end

local function volumer(volume_new)
  mpris_timer:stop()
  global_player.volume = h.round((volume_new / 100), 3)
  mpris_timer:start()
end

awesome.connect_signal("signal::mpris::update", function()
  mpris_timer:stop()
  metadata_fetch()
  mpris_timer:start()
end)

awesome.connect_signal("signal::mpris::shuffle", function()
  shuffler()
end)

awesome.connect_signal("signal::mpris::previous", function()
  previouser()
end)

awesome.connect_signal("signal::mpris::toggle", function()
  toggler()
end)
awesome.connect_signal("signal::mpris::pause", function()
  play_pauser("pause")
end)
awesome.connect_signal("signal::mpris::play", function()
  play_pauser("play")
end)

awesome.connect_signal("signal::mpris::next", function()
  nexter()
end)

awesome.connect_signal("signal::mpris::loop", function()
  looper()
end)

awesome.connect_signal("signal::mpris::position", function(position_new)
  positioner(position_new)
end)

awesome.connect_signal("signal::mpris::volume", function(volume_new)
  volumer(volume_new)
end)

