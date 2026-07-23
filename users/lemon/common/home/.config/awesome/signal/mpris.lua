local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")

local h = require("helpers")

local mpris = require("lgi").Playerctl

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

-- art_cache = {
--   ["(trim)"] = (art_load_path)
-- }
local art_cache = { }

local manager = mpris.PlayerManager.new()

local function emit()
  awesome.emit_signal("signal::mpris::metadata", metadata)
end

-- Set default values for players
local function init_player_default(p_name, p)
  if not players[p_name] then
    players[p_name] = p
    metadata[p_name] = {
      media = {
        art_url = nil,
        title = nil,
        artist = nil,
        album = nil,
        length = 1,
        art_image = nil,
      },
      player = {
        available = false,
        name = p_name,
        shuffle = false,
        status = "PAUSED",
        loop = "NONE",
        position = 1,
        volume = 1,
      },
    }
  end
end

-- Fetch art and/or load it
local function fetch_art_image(cache, trim, pm)
  local disk_cache_dir = b.mpris_art_cache_dir
  -- Set a fallback directory if user does not define one
  if not disk_cache_dir then
    disk_cache_dir = "/tmp/passivelemon/lemonix/media/"
  end
  -- Use the players disk cache if possible
  local art_load_path = h.join_path(cache, trim)
  if not cache then
    art_load_path = h.join_path(disk_cache_dir, trim)
    -- Download the art if it's not cached on disk
    if not h.is_file(art_load_path) then
      awful.spawn.easy_async("curl -Lso " .. art_load_path .. ' "' .. pm.media.art_url .. '"', function()
        -- Explicitly covert to jpg
        awful.spawn.easy_async_with_shell("magick " .. art_load_path .. " " .. art_load_path .. ".jpg && mv -f " .. art_load_path .. ".jpg " .. art_load_path , function()
          ---@diagnostic disable-next-line: param-type-mismatch
          pm.media.art_image = gears.surface.load_silently(art_load_path)
        end)
      end)
      return
    end
  end
  -- Cache art if it's not already, then load it
  local art_cache_load = art_cache[trim]
  if not art_cache_load then
    ---@diagnostic disable-next-line: param-type-mismatch
    art_cache[trim] = gears.surface.load_silently(art_load_path)
    art_cache_load = art_cache[trim]
  end
  pm.media.art_image = art_load_path
end

-- art_image_player_lookup = {
--   ["(player)"] = {
--     (cache) -- Location of the players art cache if we can determine the name of the file based on the art_url
--     (pattern) -- The part of art_url to use to find the art image cache. It's also used as the file name for our own caching if we cant use the players cache or the album string is bad
--   }
-- }
-- If set to false, then art will not be fetched for the player
local art_image_player_lookup = {
  ["feishin"] = true,
  ["firefox"] = false,
  ["tauon"] = {
    cache = h.join_path(os.getenv("HOME"), "/.cache/TauonMusicBox/export/"),
    pattern = "/(.*)",
  },
  ["spotify"] = true,
}

local function art_image_handler(p_name, pm)
  local p_lookup = art_image_player_lookup[p_name]
  if not p_lookup then
    pm.media.art_image = nil
    return
  end
  if p_lookup == true then
    -- Normalize the artist and album name and use that as the cache name for the art, that way it's only downloaded once per album (Unless there's multiple artists), which makes caching more efficient
    local trim = pm.media.artist:gsub("%W", "") .. pm.media.album:gsub("%W", "")
    fetch_art_image(nil, trim, pm)
  else
    local cache = p_lookup.cache
    local trim = cache:match(p_lookup.pattern)
    fetch_art_image(cache, trim, pm)
  end
end

-- Check if a player client is visible
local function check_for_client(p_name)
  for s in screen do
    for _, c in ipairs(s.clients) do
      local c_instance = string.lower(c.instance or "")
      local c_class = string.lower(c.class or "")
      if (c_instance == p_name) or (c_class == p_name) then
        return true
      end
    end
  end
  return false
end

local function set_global_player()
  for _, p_name in ipairs(b.mpris_players) do
    local p = players[p_name]
    local pm = metadata[p_name]
    local p_g = players["global"]
    -- Set the first visible mpris player as the global player (by order of priority in b.mpris_players)
    -- Handle firefox differently, only show if media is playing. This allows media control, but won't let it take complete control
    if p and pm and ((pm.player.status == "PLAYING") or (p_name ~= "firefox")) then
      -- Pause the current global player before switching
      if p_g and (p_g ~= p) then
        p_g:pause()
      end
      players["global"] = p
      metadata["global"] = pm
      break
    end
  end
end

local function track_notification(p_name, pm)
  -- Only show if the player is playing and (optionally) if the player is not visible
  if b.mpris_notifs and (pm.player.status == "PLAYING") and (not (b.mpris_notifs_no_client and check_for_client(p_name))) then
    awesome.emit_signal("ui::control::notification::mpris")
  end
end

local function get_metadata(p_name, p, pm)
  pm.media.art_url = p:print_metadata_prop("mpris:artUrl")
  pm.media.title = p:get_title()
  pm.media.artist = p:get_artist()
  pm.media.album = p:get_album()
  pm.media.length = p:print_metadata_prop("mpris:length")
  art_image_handler(p_name, pm)
  -- Temporarily set the global player to the player that just changed media so it can show in notifications
  players["global"] = p
  metadata["global"] = pm
  track_notification(p_name, pm)
end

local function poll_player(p_name, p)
  local pm = metadata[p_name]
  if pm then
    pm.player.available = p.can_control
    pm.player.position = p.position
  end
end

local function post_manage(p_name, p)
  local pm = metadata[p_name]
  get_metadata(p_name, p, pm)
  pm.player.status = p.playback_status
  pm.player.loop = p.loop_status
  pm.player.shuffle = p.shuffle
  pm.player.volume = p.volume
  poll_player(p_name, p)
  function p:on_metadata()
    get_metadata(p_name, p, pm)
    pm.player.position = p.position
    poll_player(p_name, p)
    set_global_player()
    emit()
  end
  function p:on_playback_status(status)
    pm.player.status = status
    set_global_player()
    emit()
  end
  function p:on_loop_status(status)
    pm.player.loop = status
    emit()
  end
  function p:on_shuffle(shuffle)
    pm.player.shuffle = shuffle
    emit()
  end
  function p:on_seeked(position)
    pm.player.position = position
    emit()
  end
  function p:on_volume(volume)
    pm.player.volume = volume
    emit()
  end
end

local mpris_timer = gears.timer({
  timeout = 1,
  autostart = false,
  callback = function()
    poll_player("global", players["global"])
    emit()
  end,
})

local function manage_player(mp_name)
  local p_name = string.lower(mp_name.name)
  local p = mpris.Player.new_from_name(mp_name)
  manager:manage_player(p)
  if #players == 0 then
    mpris_timer:start()
  end
  if h.table_contains(b.mpris_players, p_name) or (not b.mpris_strict_players) then
    init_player_default(p_name, p)
  end
  return p_name, p
end

-- Manage new players
function manager:on_name_appeared(mp_name)
  local p_name, p = manage_player(mp_name)
  post_manage(p_name, p)
end

-- Manage existing players
local function init_manage()
  for _, mp_name in ipairs(manager.player_names) do
    local p_name, p = manage_player(mp_name)
    post_manage(p_name, p)
  end
end

init_manage()

-- Remove cache for no longer existing players
function manager:on_name_vanished(mp_name)
  local p_name = string.lower(mp_name.name)
  players[p_name] = nil
  metadata[p_name] = nil
  if #players == 0 then
    mpris_timer:stop()
  end
end

local function mpris_call_wrapper(callback, override)
  mpris_timer:stop()
  local p = players["global"]
  local pm = metadata["global"]
  if override then
    if override:match("%%all%%") then
      for p_name, px in pairs(players) do
        p = px
        pm = metadata[p_name]
      end
    else
      local p_name = string.lower(override)
      p = players[p_name]
      pm = metadata[p_name]
    end
  end
  if p and pm then
    callback(p, pm)
    emit()
  end
  mpris_timer:start()
end

local function toggler(override)
  mpris_call_wrapper(function(p, _)
    p:play_pause()
  end, override)
end

local function play_pauser(option, override)
  mpris_call_wrapper(function(p, _)
    if option then
      p:play()
    else
      p:pause()
    end
  end, override)
end

local function previouser(override)
  mpris_call_wrapper(function(p, _)
    p:previous()
  end, override)
end

local function nexter(override)
  mpris_call_wrapper(function(p, _)
    p:next()
  end, override)
end

local function looper(override)
  mpris_call_wrapper(function(p, pm)
    p:set_loop_status(pm.player.loop)
  end, override)
end

local function shuffler(override)
  mpris_call_wrapper(function(p, pm)
    p:set_shuffle(pm.player.shuffle)
  end, override)
end

local function positioner(position_new, override)
  mpris_call_wrapper(function(p, pm)
    p:set_position(h.round(((position_new * pm.media.length) / 100), 3))
  end, override)
end

local function volumer(volume_new, override)
  mpris_call_wrapper(function(p, _)
    volume_new = h.round((volume_new / 100), 3)
    p:set_volume(volume_new)
  end, override)
end

local function volume_stepper(volume_new, override)
  mpris_call_wrapper(function(p, _)
    volume_new = (p.volume + h.round((volume_new / 100), 3))
    p:set_volume(volume_new)
  end, override)
end

-- Each control can have an override, either for a specific player or for all
-- Just pass the player name for a specific player or "%all%" to target every player
awesome.connect_signal("signal::mpris::toggle", function(override)
  toggler(override)
end)

awesome.connect_signal("signal::mpris::play", function(override)
  play_pauser(true, override)
end)

awesome.connect_signal("signal::mpris::pause", function(override)
  play_pauser(false, override)
end)

awesome.connect_signal("signal::mpris::previous", function(override)
  previouser(override)
end)

awesome.connect_signal("signal::mpris::next", function(override)
  nexter(override)
end)

awesome.connect_signal("signal::mpris::loop", function(override)
  looper(override)
end)

awesome.connect_signal("signal::mpris::shuffle", function(override)
  shuffler(override)
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

