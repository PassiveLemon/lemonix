local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")

local h = require("helpers")

local mpris = require("lgi").require("AstalMpris")

-- metadata = {
--   ["player"] = {
--     media = { (art_url) (title) (artist) (album) (length) (art_image) }
--     player = { (available) (name) (shuffle) (status) (loop) (position) (volume) }
--   }
-- }

local metadata = {
  ["global"] = {
    player = {
      available = false,
      status = "",
    },
  }
}

local function emit()
  awesome.emit_signal("signal::mpris::metadata", metadata)
end

-- players = {
--   [(player)] = mpris.Player
-- }

local players = { }

local function init_players()
  for _, player in ipairs(b.mpris_players) do
    players[string.lower(player)] = mpris.Player.new(player)
    metadata[string.lower(player)] = {
      media = {
        art_url = "",
        title = "",
        artist = "",
        album = "",
        length = "",
        art_image = nil,
      },
      player = {
        available = false,
        name = "",
        shuffle = "",
        status = "",
        loop = "",
        position = "",
        volume = "",
      },
    }
  end
end

init_players()

-- Temporary
local global_player = "feishin"

local function art_image_locator(cache_dir, trim, player)
  local player_metadata = metadata[player]
  local art_cache_dir = b.mpris_art_cache_dir
  -- We set a fallback directory if user does not define one
  if not art_cache_dir then
    art_cache_dir = "/tmp/passivelemon/lemonix/media/"
  end
  if not cache_dir then
    local art_path = h.join_path(art_cache_dir, trim)
    if h.is_file(art_path) then
      player_metadata.media.art_image = gears.surface.load_uncached(art_path)
    else
      awful.spawn.easy_async_with_shell("curl -Lso " .. art_path .. ' "' .. player_metadata.media.art_url .. '"', function()
        player_metadata.media.art_image = gears.surface.load_uncached(art_path)
      end)
    end
  else
    local player_art_path = h.join_path(cache_dir, trim)
    if h.is_file(player_art_path) then
      player_metadata.media.art_image = gears.surface.load_uncached(player_art_path)
    end
  end
end

-- art_image_player_lookup = {
--   [(player)] = {
--     (cache) -- Location of the players art cache if we can determine the name of the file based on the art_url
--     (trim) -- The part of art_url to use to find the art image cache
--     (backup) -- The part of the art_url to use as the file name for our own caching if we cant use the players cache
--   }
-- }

local art_image_player_lookup = {
  ["feishin"] = {
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

local function art_image_fetch(player)
  local player_metadata = metadata[player]
  -- We normalize the album name and use that as the cache name for the album art, that way it's only downloaded once per album, which makes caching more efficient. In case the normalization results in a bad filename, we use a backup string
  local player_lookup = art_image_player_lookup[string.lower(player_metadata.player.name)]
  local trim = ""
  if not player_lookup.trim then
    local album_string = player_metadata.media.album:gsub("%W", "")
    if album_string == "" or not album_string then
      trim = player_metadata.media.art_url:match(player_lookup.backup)
    else
      trim = album_string
    end
  end
  art_image_locator(player_lookup.cache, trim, player)
end

-- If the art isn't already cached then the notification will have the art of the previous media
local function track_notification(player)
  local player_metadata = metadata[player]
  local p_name = string.lower(player_metadata.player.name)
  -- Don't show a notification if the music player is visible
  for s in screen do
    for _, c in pairs(s.clients) do
      local c_instance = string.lower(c.instance or "")
      local c_class = string.lower(c.class or "")
      if c_instance == p_name or c_class == p_name then
        return
      end
    end
  end
  if b.mpris_notifications and player_metadata.player.available then
    awesome.emit_signal("ui::control::notification::mpris")
  end
end

-- If no overrides, set the global player to the same metadata?

local function metadata_fetch()
  for player_name, player in pairs(players) do
    local metadata_player = metadata[string.lower(player_name)]
    if player.available then
      -- Sleep here to "improve" responsiveness. Otherwise it happens so quickly that we end up grabbing the old media metadata
      awful.spawn.easy_async("sleep 0.1", function()
        -- TODO: Find a nicer way to do this.
        local old_media = metadata_player.media.art_url..metadata_player.media.title..metadata_player.media.artist..metadata_player.media.album..metadata_player.media.length
        -- Might need to do (xxx or "") for other metadata, but so far only had issues with artist
        local new_media = player.art_url..player.title..(player.artist or "")..player.album..player.length

        -- Media metadata
        metadata_player.media.art_url = player.art_url or ""
        metadata_player.media.title = player.title or ""
        metadata_player.media.artist = player.artist or ""
        metadata_player.media.album = player.album or ""
        metadata_player.media.length = player.length or "1"

        -- Player metadata
        metadata_player.player.available = true
        metadata_player.player.name = player_name or ""
        metadata_player.player.shuffle = player.shuffle_status or "NONE"
        metadata_player.player.status = player.playback_status or "PLAYING"
        metadata_player.player.loop = player.loop_status or "PLAYLIST"
        metadata_player.player.position = player.position or "1"
        metadata_player.player.volume = player.volume or "1"

        -- Fetch art image and send notification when the media metadata changes
        -- Compare the previously stored metadata to the newly fetched metadata
        if old_media ~= new_media then
          art_image_fetch(player_name)
          -- Don't send a notification on AWM startup
          if old_media ~= "" then
            track_notification(player_name)
          end
        end
        emit()
      end)
    else
      metadata_player.player.available = false
    end
  end
  emit()
end

metadata_fetch()

local function get_player(by_name)
  -- Fetch player from mpris itself, not this mpris signal
  -- local mpris_players = mpris.mpris.get_players()
  for name, player in pairs(players) do
    if name == by_name then
      return player
    end
  end
end

local mpris_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function(self)
    metadata_fetch()
    -- Speed up the poll if media is currently playing
    local cur_timeout = self.timeout
    if metadata["global"].player.status == "PLAYING" then
      self.timeout = 1
    else
      self.timeout = 5
    end
    if cur_timeout ~= self.timeout then
      self:again()
    end
  end,
})

local function mpris_timer_wrapper(callback, override)
  mpris_timer:stop()
  if not override == nil then
    local override_player = get_player(override)
    callback(override_player)
  else
    callback(global_player)
  end
  mpris_timer:start()
end

local function shuffler(override)
  mpris_timer_wrapper(function(player)
    local metadata_player = metadata[player]
    if metadata_player.player.shuffle == "ON" then
      metadata_player.player.shuffle = "OFF"
    elseif metadata_player.player.shuffle == "OFF" then
      metadata_player.player.shuffle = "ON"
    end
    players[player]:shuffle()
    emit()
  end, override)
end

local function previouser(override)
  mpris_timer_wrapper(function(player)
    players[player]:previous()
    metadata_fetch()
  end, override)
end

local function toggler(override)
  mpris_timer_wrapper(function(player)
    local metadata_player = metadata[player]
    if metadata_player.player.status == "PLAYING" then
      metadata_player.player.status = "PAUSED"
    elseif metadata_player.player.status == "PAUSED" then
      metadata_player.player.status = "PLAYING"
    end
    players[player]:play_pause()
    emit()
  end, override)
end

local function play_pauser(option, override)
  mpris_timer_wrapper(function(player)
    if players[player] == "play" then
      player:play()
    elseif option == "pause" then
      players[player]:pause()
    end
  end, override)
end

local function nexter(override)
  mpris_timer_wrapper(function(player)
    players[player]:next()
    metadata_fetch()
  end, override)
end

local function looper(override)
  mpris_timer_wrapper(function(player)
    local metadata_player = metadata[player]
    if metadata_player.player.loop == "NONE" then
      metadata_player.player.loop = "PLAYLIST"
    elseif metadata_player.player.loop == "PLAYLIST" then
      metadata_player.player.loop = "TRACK"
    elseif metadata_player.player.loop == "TRACK" then
      metadata_player.player.loop = "NONE"
    end
    players[player]:loop()
    emit()
  end, override)
end

local function positioner(position_new, override)
  mpris_timer_wrapper(function(player)
    players[player].position = h.round(((position_new * metadata[player].media.length) / 100), 3)
  end, override)
end

local function volumer(volume_new, override)
  mpris_timer_wrapper(function(player)
    volume_new = h.round((volume_new / 100), 3)
    players[player].volume = volume_new
    metadata[player].player.volume = volume_new
    emit()
  end, override)
end

local function volume_stepper(volume_new, override)
  mpris_timer_wrapper(function(player)
    volume_new = (players[player].volume + h.round((volume_new / 100), 3))
    players[player].volume = volume_new
    metadata[player].player.volume = volume_new
    emit()
  end, override)
end

awesome.connect_signal("signal::mpris::update", function()
  mpris_timer_wrapper(function()
    metadata_fetch()
  end)
end)

awesome.connect_signal("signal::mpris::shuffle", function(override)
  shuffler(override)
end)

awesome.connect_signal("signal::mpris::previous", function(override)
  previouser(override)
end)

awesome.connect_signal("signal::mpris::toggle", function(override)
  toggler(override)
end)
awesome.connect_signal("signal::mpris::pause", function(override)
  play_pauser("pause", override)
end)
awesome.connect_signal("signal::mpris::play", function(override)
  play_pauser("play", override)
end)

awesome.connect_signal("signal::mpris::next", function(override)
  nexter(override)
end)

awesome.connect_signal("signal::mpris::loop", function(override)
  looper(override)
end)

awesome.connect_signal("signal::mpris::position", function(position_new, override)
  positioner(position_new, override)
end)

awesome.connect_signal("signal::mpris::volume", function(volume_new, override)
  volumer(volume_new, override)
end)

awesome.connect_signal("signal::mpris::volume::step", function(volume_new, override)
  volume_stepper(volume_new, override)
end)

