local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")

local h = require("helpers")

local mpris = require("lgi").Playerctl

-- metadata = {
--   ["player"] = {
--     media = { (art_url) (title) (artist) (album) (length) (art_image) }
--     player = { (available) (name) (shuffle) (status) (loop) (position) (volume) }
--   }
-- }
local metadata = { }

-- players = {
--   ["player"] = (mpris.Player)
-- }
local players = { }

local manager = mpris.PlayerManager.new()

local function emit()
  awesome.emit_signal("signal::mpris::metadata", metadata)
end

local function init_player_default(p_name, p)
  -- Set default values for players
  if not players[p_name] then
    players[p_name] = p
    metadata[p_name] = {
      media = {
        art_url = "",
        title = "",
        artist = "",
        album = "",
        length = "1",
        art_image = nil,
      },
      player = {
        available = false,
        name = "",
        shuffle = "false",
        status = "STOPPED",
        loop = "NONE",
        position = "1",
        volume = "1",
      },
    }
  end
end

-- Init all currently existing players
local function init_undefined_players()
  for _, p_namex in ipairs(manager.player_names) do
    local p = mpris.Player.new_from_name(p_namex)
    local p_name = string.lower(p.player_name)
    manager:manage_player(p)
    init_player_default(p_name, p)
  end
end

local function init_defined_players()
  for _, p_namex in ipairs(b.mpris_players) do
    local p = mpris.Player.new(p_namex)
    local p_name = string.lower(p_namex)
    init_player_default(p_name, p)
  end
end

init_undefined_players()
init_defined_players()

-- Set the global player to the current player by order of priority in b.mpris_players
local function set_global_player()
  local p_list = b.mpris_players
  for _, p_namex in ipairs(p_list) do
    local p_name = string.lower(p_namex)
    if players[p_name] then
      players["global"] = players[p_name]
      metadata["global"] = metadata[p_name]
      return
    end
  end
end

set_global_player()

-- Remove players from metadata and players arrays when they are gone
-- local function clean_metadata()
--   for p_name, _ in pairs(players) do
--     if not h.table_contains(manager, p_name) then
--       players[p_name] = nil
--     end
--   end
--   for p_name, _ in pairs(metadata) do
--     if not h.table_contains(manager, p_name) then
--       metadata[p_name] = nil
--     end
--   end
-- end

-- Fetch art if not cached and load it
local function fetch_art_image(cache_dir, trim, pm)
  local art_cache_dir = b.mpris_art_cache_dir
  -- Set a fallback directory if user does not define one
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
--   ["player"] = {
--     (cache) -- Location of the players art cache if we can determine the name of the file based on the art_url
--     (trim) -- The part of art_url to use to find the art image cache. It's also used as the file name for our own caching if we cant use the players cache or the album string is bad
--   }
-- }
local art_image_player_lookup = {
  ["feishin"] = {
    cache = nil,
    trim = "?id=(.*)&u=",
  },
  ["tauon"] = {
    cache = h.join_path(os.getenv("HOME"), "/.cache/TauonMusicBox/export/"),
    trim = "/(.*)",
  },
  ["spotify"] = {
    cache = nil,
    trim = "/(.*)",
  },
}

-- We normalize the album name and use that as the cache name for the album art, that way it's only downloaded once per album, which makes caching more efficient. In case the normalization results in a bad filename, we use a backup string
local function art_image_handler(p_name, pm)
  local p_lookup = art_image_player_lookup[p_name]
  local trim = ""
  local cache = nil
  if p_lookup then
    cache = p_lookup.cache
    local album_string = pm.media.album:gsub("%W", "")
    if album_string == "" or not album_string then
      trim = pm.media.art_url:match(p_lookup.backup)
    else
      trim = album_string
    end
    fetch_art_image(cache, trim, pm)
  end
end

-- If the art isn't already cached then the notification will have the art of the previous media
local function track_notification(pm)
  local p_name = pm.player.name
  -- Don't show a notification if the music player is visible
  for _, c in ipairs(client.get()) do
    local c_instance = string.lower(c.instance or "")
    local c_class = string.lower(c.class or "")
    if (c_instance == p_name) or (c_class == p_name) then
      return
    end
  end
  if b.mpris_notifications and pm.player.available then
    awesome.emit_signal("ui::control::notification::mpris")
  end
end

-- Create a basic signature of static track metadata
local function get_metadata_sig(pm)
  if pm and pm.media then
    local sig = table.concat({
      pm.media.art_url or "",
      pm.media.title or "",
      pm.media.artist or "",
      pm.media.album or "",
      pm.media.length or "",
    })
    return sig
  else
    return ""
  end
end

-- sig_cache = {
--   ["player"] = (sig)
-- }
local sig_cache = { }

local function get_metadata(p_name, p, force_art)
  local pm = metadata[p_name]
  local old_sig = sig_cache[p_name]

  -- Media metadata
  pm.media.art_url = p:print_metadata_prop("mpris:artUrl") or ""
  pm.media.title = p:get_title() or ""
  pm.media.artist = p:get_artist() or ""
  pm.media.album = p:get_album() or ""
  pm.media.length = p:print_metadata_prop("mpris:length") or "1"

  -- Player metadata
  pm.player.available = true
  pm.player.name = p_name or ""
  pm.player.shuffle = p.shuffle or false
  pm.player.status = p.playback_status or "STOPPED"
  pm.player.loop = p.loop_status or "NONE"
  pm.player.position = p.position or "1"
  pm.player.volume = p.volume or "1"

  local new_sig = get_metadata_sig(pm)

  -- Fetch art image and send notification when the media metadata changes
  -- Compare the previously stored metadata signature to the newly fetched metadata
  if (old_sig ~= new_sig) or force_art then
    sig_cache[p_name] = new_sig
    art_image_handler(p_name, pm)
    -- Don't send a notification on AWM startup (old_sig will be nil only then)
    if old_sig ~= nil then
      track_notification(pm)
    end
  end
end

local function metadata_fetch(player, force_art)
  if player then
    get_metadata(string.lower(player.player_name), player)
  else
    for p_name, p in pairs(players) do
      get_metadata(p_name, p, force_art)
    end
  end
  emit()
end

-- Force a metadata and art fetch on load
metadata_fetch(nil, true)

local mpris_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function(self)
    init_undefined_players()
    -- clean_metadata()
    set_global_player()
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

local function mpris_call_wrapper(callback, override)
  mpris_timer:stop()
  if not override then
    local pm = metadata["global"]
    local p = players["global"]
    callback(pm, p)
  elseif override:gmatch("%%all%%") then
    for p_name, p in pairs(players) do
      local pm = metadata[p_name]
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
    pm.player.shuffle = not pm.player.shuffle
    p:set_shuffle(pm.player.shuffle)
    emit()
  end, override)
end

local function previouser(override)
  mpris_call_wrapper(function(_, p)
    p:previous()
    metadata_fetch(p)
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
    metadata_fetch(p)
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
    p:set_loop_status(pm.player.loop)
    emit()
  end, override)
end

local function positioner(position_new, override)
  mpris_call_wrapper(function(pm, p)
    p:set_position(h.round(((position_new * pm.media.length) / 100), 3))
  end, override)
end

local function volumer(volume_new, override)
  mpris_call_wrapper(function(pm, p)
    volume_new = h.round((volume_new / 100), 3)
    p:set_volume(volume_new)
    pm.player.volume = volume_new
    emit()
  end, override)
end

local function volume_stepper(volume_new, override)
  mpris_call_wrapper(function(pm, p)
    volume_new = (p.volume + h.round((volume_new / 100), 3))
    p:set_volume(volume_new)
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

