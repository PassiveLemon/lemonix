local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")

local h = require("helpers")

local mpris = require("lgi").Playerctl

-- Playerctl docs: https://lazka.github.io/pgi-docs/Playerctl-2.0/classes.html

-- metadata = {
--   ["(player)"] = {
--     media = { (art_url) (title) (artist) (album) (length) (art_image) }
--     player = { (available) (name) (shuffle) (status) (loop) (position) (volume) }
--   }
-- }
local metadata = { }

-- players = {
--   ["(player)"] = (mpris.Player)
-- }
local players = { }
local managed_players = { }

-- art_cache = {
--   ["(trim)"] = (art_load_path)
-- }
local art_cache = { }

-- sig_cache = {
--   ["(player)"] = (sig)
-- }
local sig_cache = { }

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

-- Init players and cleanup metadata
local function init_players()
  local active = { }
  for _, mp_name in ipairs(manager.player_names) do
    local p_id = string.lower(mp_name.name)
    active[p_id] = true

    local p = managed_players[p_id]
    if not p then
      p = mpris.Player.new_from_name(mp_name)
      managed_players[p_id] = p
      manager:manage_player(p)

      local p_name = string.lower(p.player_name)
      if h.table_contains(b.mpris_players, p_name) or (not b.mpris_strict_players) then
        init_player_default(p_name, p)
      end
    end
  end
  -- Remove metadata for no longer existing players
  for p_id, _ in pairs(managed_players) do
    if not active[p_id] then
      players[p_id] = nil
      managed_players[p_id] = nil
      metadata[p_id] = nil
      sig_cache[p_id] = nil
    end
  end
end

-- Set the global player to the current player by order of priority in b.mpris_players
local function set_global_player()
  for _, p_name in ipairs(b.mpris_players) do
    if players[p_name] then
      players["global"] = players[p_name]
      metadata["global"] = metadata[p_name]
      return
    end
  end
end

init_players()
set_global_player()

-- Fetch art if not cached and load it
local function fetch_art_image(cache, trim, pm)
  local disk_cache_dir = b.mpris_art_cache_dir
  -- Set a fallback directory if user does not define one
  if not disk_cache_dir then
    disk_cache_dir = "/tmp/passivelemon/lemonix/media/"
  end
  -- If the client has an accessible cache, use that. Otherwise, use our own
  local art_load_path = h.join_path(cache, trim)
  if not cache then
    art_load_path = h.join_path(disk_cache_dir, trim)
    if not h.is_file(art_load_path) then
      awful.spawn.easy_async("curl -Lso " .. disk_cache_dir .. ' "' .. pm.media.art_url .. '"', function()
        ---@diagnostic disable-next-line: param-type-mismatch
        pm.media.art_image = gears.surface.load_silently(art_load_path)
      end)
      return
    end
  end
  local art_cache_load = art_cache[trim]
  if not art_cache_load then
    ---@diagnostic disable-next-line: param-type-mismatch
    art_cache[trim] = gears.surface.load_silently(art_load_path)
    art_cache_load = art_cache[trim]
  end
  pm.media.art_image = art_cache_load
end

-- art_image_player_lookup = {
--   ["(player)"] = {
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

-- We normalize the artist and album name and use that as the cache name for the art, that way it's only downloaded once per album (Unless there's multiple artists), which makes caching more efficient. In case the normalization results in a bad filename, we use a backup string
local function art_image_handler(p_name, pm)
  local p_lookup = art_image_player_lookup[p_name]
  if p_lookup then
    local cache = p_lookup.cache
    local trim = pm.media.artist:gsub("%W", "") .. pm.media.album:gsub("%W", "")
    if trim == "" or not trim then
      trim = pm.media.art_url:match(p_lookup.backup)
    end
    fetch_art_image(cache, trim, pm)
  end
end

-- The notification may include the previous art image and then update to the new one. This happens due to the way the art images are loaded and can't really be avoided without potentially blocking the event loop
local function track_notification(pm)
  local p_name = pm.player.name
  if b.mpris_notifs_no_client then
    for s in screen do
      for _, c in ipairs(s.clients) do
        local c_instance = string.lower(c.instance or "")
        local c_class = string.lower(c.class or "")
        if (c_instance == p_name) or (c_class == p_name) then
          return
        end
      end
    end
  end
  if b.mpris_notifs and pm.player.available then
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

local function get_metadata(p_name, p)
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
  if (old_sig ~= new_sig) then
    sig_cache[p_name] = new_sig
    art_image_handler(p_name, pm)
    -- Don't send a notification on AWM startup (old_sig will be nil only then)
    if old_sig ~= nil then
      -- Temporarily set the global player to the player that just changed media so it can show in notifications
      players["global"] = players[p_name]
      metadata["global"] = metadata[p_name]
      track_notification(pm)
    end
  end
end

-- A player can be passed to get only that players metadata. Useful for next/previous controls
local function metadata_fetch(player)
  if player then
    get_metadata(string.lower(player.player_name), player)
  else
    for p_name, p in pairs(players) do
      if p_name ~= "global" then
        get_metadata(p_name, p)
      end
    end
  end
end

metadata_fetch()

local mpris_timer = gears.timer({
  timeout = 1,
  autostart = true,
  callback = function(self)
    init_players()
    metadata_fetch()
    set_global_player()
    emit()
    -- Speed up the poll if media is currently playing
    local cur_timeout = self.timeout
    if metadata["global"].player.status == "PLAYING" then
      self.timeout = 1
    else
      self.timeout = 3
    end
    if cur_timeout ~= self.timeout then
      self:again()
    end
  end,
})

local function mpris_call_wrapper(callback, override)
  mpris_timer:stop()
  local pm = metadata["global"]
  local p = players["global"]
  if override then
    if override:gmatch("%%all%%") then
      for p_name, px in pairs(players) do
        pm = metadata[p_name]
        p = px
      end
    else
      local p_name = string.lower(override)
      pm = metadata[p_name]
      p = players[p_name]
    end
  end
  if p and pm then
    callback(pm, p)
    emit()
  end
  mpris_timer:start()
end

local function shuffler(override)
  mpris_call_wrapper(function(pm, p)
    pm.player.shuffle = not pm.player.shuffle
    p:set_shuffle(pm.player.shuffle)
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
  end, override)
end

local function play_pauser(option, override)
  mpris_call_wrapper(function(_, p)
    if option then
      p:play()
    else
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
  end, override)
end

local function volume_stepper(volume_new, override)
  mpris_call_wrapper(function(pm, p)
    volume_new = (p.volume + h.round((volume_new / 100), 3))
    p:set_volume(volume_new)
    pm.player.volume = volume_new
  end, override)
end

awesome.connect_signal("signal::mpris::update", function()
  mpris_call_wrapper(function()
    metadata_fetch()
  end)
end)

-- Each control can have an override, either for a specific player or for all
-- Just pass the player name for a specific player or "%all%" to target every player
awesome.connect_signal("signal::mpris::shuffle", function(override)
  shuffler(override)
end)

awesome.connect_signal("signal::mpris::previous", function(override)
  previouser(override)
end)

awesome.connect_signal("signal::mpris::toggle", function(override)
  toggler(override)
end)
awesome.connect_signal("signal::mpris::play", function(override)
  play_pauser(true, override)
end)
awesome.connect_signal("signal::mpris::pause", function(override)
  play_pauser(false, override)
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

