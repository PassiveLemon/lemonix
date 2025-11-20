local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")

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
  local p_name = string.lower(metadata.player.name)
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
  if b.mpris_notifications and metadata.player.available then
    awesome.emit_signal("ui::control::notification::mpris")
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
          -- Might need to do (xxx or "") for other metadata, but so far only had issues with artist
          local new_media = player.art_url..player.title..(player.artist or "")..player.album..player.length

          -- Media metadata
          metadata.media.art_url = player.art_url or ""
          metadata.media.title = player.title or ""
          metadata.media.artist = player.artist or ""
          metadata.media.album = player.album or ""
          metadata.media.length = player.length or "1"

          -- Player metadata
          metadata.player.available = true
          metadata.player.name = player_name or ""
          metadata.player.shuffle = player.shuffle_status or "NONE"
          metadata.player.status = player.playback_status or "PLAYING"
          metadata.player.loop = player.loop_status or "PLAYLIST"
          metadata.player.position = player.position or "1"
          metadata.player.volume = player.volume or "1"

          global_player = player

          -- Fetch art image and send notification when the media metadata changes
          -- Compare the previously stored metadata to the newly fetched metadata
          if old_media ~= new_media then
            art_image_fetch()
            -- Don't send a notification on AWM startup
            if old_media ~= "" then
              track_notification()
            end
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

local function mpris_timer_wrapper(callback)
  mpris_timer:stop()
  callback()
  mpris_timer:start()
end

local function shuffler()
  mpris_timer_wrapper(function()
    if metadata.player.shuffle == "ON" then
      metadata.player.shuffle = "OFF"
    elseif metadata.player.shuffle == "OFF" then
      metadata.player.shuffle = "ON"
    end
    global_player:shuffle()
    emit()
  end)
end

local function previouser()
  mpris_timer_wrapper(function()
    global_player:previous()
    metadata_fetch()
  end)
end

local function toggler()
  mpris_timer_wrapper(function()
    if metadata.player.status == "PLAYING" then
      metadata.player.status = "PAUSED"
    elseif metadata.player.status == "PAUSED" then
      metadata.player.status = "PLAYING"
    end
    global_player:play_pause()
    emit()
  end)
end

local function play_pauser(option)
  mpris_timer_wrapper(function()
    if option == "play" then
      global_player:play()
    elseif option == "pause" then
      global_player:pause()
    end
  end)
end

local function nexter()
  mpris_timer_wrapper(function()
    global_player:next()
    metadata_fetch()
  end)
end

local function looper()
  mpris_timer_wrapper(function()
    if metadata.player.loop == "NONE" then
      metadata.player.loop = "PLAYLIST"
    elseif metadata.player.loop == "PLAYLIST" then
      metadata.player.loop = "TRACK"
    elseif metadata.player.loop == "TRACK" then
      metadata.player.loop = "NONE"
    end
    global_player:loop()
    emit()
  end)
end

local function positioner(position_new)
  mpris_timer_wrapper(function()
    global_player.position = h.round(((position_new * metadata.media.length) / 100), 3)
  end)
end

local function volumer(volume_new)
  mpris_timer_wrapper(function()
    volume_new = h.round((volume_new / 100), 3)
    global_player.volume = volume_new
    metadata.player.volume = volume_new
    emit()
  end)
end

local function volume_stepper(volume_new)
  mpris_timer_wrapper(function()
    volume_new = (global_player.volume + h.round((volume_new / 100), 3))
    global_player.volume = volume_new
    metadata.player.volume = volume_new
    emit()
  end)
end

awesome.connect_signal("signal::mpris::update", function()
  mpris_timer_wrapper(function()
    metadata_fetch()
  end)
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

awesome.connect_signal("signal::mpris::volume::step", function(volume_new)
  volume_stepper(volume_new)
end)

