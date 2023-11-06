local awful = require("awful")
local gears = require("gears")

local playerctl = "playerctl -p spotify,tauon,Sonixd"

local function emit(art_url, title, artist, album, shuffle, status, loop, position, length, volume)
  awesome.emit_signal('signal::playerctl', art_url, title, artist, album, shuffle, status, loop, position, length, volume)
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
    volume= stdout:match("volume_(.*)") or ""
    emit(art_url, title, artist, album, shuffle, status, loop, position, length, volume)
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

return { metadata = metadata }

