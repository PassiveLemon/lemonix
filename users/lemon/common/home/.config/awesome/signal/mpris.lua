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

local metadata = { }

-- players = {
--   ["player"] = mpris.Player
-- }

local players = { }

local function emit()
  awesome.emit_signal("signal::mpris::metadata", metadata)
end

local function init_players()
  local i = 0
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
    -- Temporary, set the global player to the first player
    if i == 0 then
      players["global"] = string.lower(player)
      i = 1
    end
  end
end

init_players()

local function art_image_locator(cache_dir, trim, pm)
  local art_cache_dir = b.mpris_art_cache_dir
  -- We set a fallback directory if user does not define one
  if not art_cache_dir then
    art_cache_dir = "/tmp/passivelemon/lemonix/media/"
  end
  if not cache_dir then
    local art_path = h.join_path(art_cache_dir, trim)
    if h.is_file(art_path) then
      pm.media.art_image = gears.surface.load_uncached(art_path)
    else
      awful.spawn.easy_async_with_shell("curl -Lso " .. art_path .. ' "' .. pm.media.art_url .. '"', function()
        pm.media.art_image = gears.surface.load_uncached(art_path)
      end)
    end
  else
    local player_art_path = h.join_path(cache_dir, trim)
    if h.is_file(player_art_path) then
      pm.media.art_image = gears.surface.load_uncached(player_art_path)
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

local function art_image_fetch(pm)
  -- We normalize the album name and use that as the cache name for the album art, that way it's only downloaded once per album, which makes caching more efficient. In case the normalization results in a bad filename, we use a backup string
  local player_lookup = art_image_player_lookup[string.lower(pm.player.name)]
  local trim = ""
  if not player_lookup.trim then
    local album_string = pm.media.album:gsub("%W", "")
    if album_string == "" or not album_string then
      trim = pm.media.art_url:match(player_lookup.backup)
    else
      trim = album_string
    end
  end
  art_image_locator(player_lookup.cache, trim, pm)
end

-- If the art isn't already cached then the notification will have the art of the previous media
local function track_notification(pm)
  local p_name = pm.player.name
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
  if b.mpris_notifications and pm.player.available then
    awesome.emit_signal("ui::control::notification::mpris")
  end
end

local function metadata_fetch()
  for p_name, p in pairs(players) do
    local pm = metadata[p_name]
    if p.available then
      -- Sleep here to "improve" responsiveness. Otherwise it happens so quickly that we end up grabbing the old media metadata
      awful.spawn.easy_async("sleep 0.1", function()
        -- TODO: Find a nicer way to do this.
        local old_media = pm.media.art_url..pm.media.title..pm.media.artist..pm.media.album..pm.media.length
        -- Might need to do (xxx or "") for other metadata, but so far only had issues with artist
        local new_media = p.art_url..p.title..(p.artist or "")..p.album..p.length

        -- Media metadata
        pm.media.art_url = p.art_url or ""
        pm.media.title = p.title or ""
        pm.media.artist = p.artist or ""
        pm.media.album = p.album or ""
        pm.media.length = p.length or "1"

        -- Player metadata
        pm.player.available = true
        pm.player.name = p_name or ""
        pm.player.shuffle = p.shuffle_status or "NONE"
        pm.player.status = p.playback_status or "PLAYING"
        pm.player.loop = p.loop_status or "PLAYLIST"
        pm.player.position = p.position or "1"
        pm.player.volume = p.volume or "1"

        -- Fetch art image and send notification when the media metadata changes
        -- Compare the previously stored metadata to the newly fetched metadata
        if old_media ~= new_media then
          art_image_fetch(pm)
          -- Don't send a notification on AWM startup
          if old_media ~= "" then
            track_notification(pm)
          end
        end
      end)
    else
      -- pm.player.available = false
    end
  end
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
    if metadata[players["global"]].player.status == "PLAYING" then
      self.timeout = 1
    else
      self.timeout = 5
    end
    if cur_timeout ~= self.timeout then
      self:again()
    end
  end,
})

local function mpris_call_wrapper(callback, override)
  mpris_timer:stop()
  if override == nil then
    local pm = metadata[players["global"]]
    local p = players[players["global"]]
    callback(pm, p)
  elseif override:gmatch("%%all%%") then
    -- Get all mpris players, not just the ones in theme.lua
    for _, mpris_p in ipairs(mpris.Mpris.new("awm").players) do
      local pm = metadata[mpris_p]
      local p = players[mpris_p]
      callback(pm, p)
    end
  else
    local pm = metadata[override]
    local p = players[override]
    callback(pm, p)
  end
  mpris_timer:start()
end

local function shuffler(override)
  mpris_call_wrapper(function(pm, p)
    if pm.player.shuffle == "ON" then
      pm.player.shuffle = "OFF"
    elseif pm.player.shuffle == "OFF" then
      pm.player.shuffle = "ON"
    end
    p:shuffle()
    emit()
  end, override)
end

local function previouser(override)
  mpris_call_wrapper(function(_, p)
    p:previous()
    metadata_fetch()
  end, override)
end

local function toggler(override)
  mpris_call_wrapper(function(pm, p)
    if pm.player.status == "PLAYING" then
      pm.player.status = "PAUSED"
    elseif pm.player.status == "PAUSED" then
      pm.player.status = "PLAYING"
    end
    p:play_pause()
    emit()
  end, override)
end

local function play_pauser(option, override)
  mpris_call_wrapper(function(_, p)
    if option == "play" then
      p:play()
    elseif option == "pause" then
      p:pause()
    end
  end, override)
end

local function nexter(override)
  mpris_call_wrapper(function(_, p)
    p:next()
    metadata_fetch()
  end, override)
end

local function looper(override)
  mpris_call_wrapper(function(pm, p)
    if pm.player.loop == "NONE" then
      pm.player.loop = "PLAYLIST"
    elseif pm.player.loop == "PLAYLIST" then
      pm.player.loop = "TRACK"
    elseif pm.player.loop == "TRACK" then
      pm.player.loop = "NONE"
    end
    p:loop()
    emit()
  end, override)
end

local function positioner(position_new, override)
  mpris_call_wrapper(function(pm, p)
    p.position = h.round(((position_new * pm.media.length) / 100), 3)
  end, override)
end

local function volumer(volume_new, override)
  mpris_call_wrapper(function(pm, p)
    volume_new = h.round((volume_new / 100), 3)
    p.volume = volume_new
    pm.player.volume = volume_new
    emit()
  end, override)
end

local function volume_stepper(volume_new, override)
  mpris_call_wrapper(function(pm, p)
    volume_new = (p.volume + h.round((volume_new / 100), 3))
    p.volume = volume_new
    pm.player.volume = volume_new
    emit()
  end, override)
end

awesome.connect_signal("signal::mpris::update", function()
  mpris_call_wrapper(function()
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

