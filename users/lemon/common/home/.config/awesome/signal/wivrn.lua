local awful = require("awful")
local gears = require("gears")

local ast_Wp = require("lgi").require("AstalWp")
local wp = ast_Wp.get_default()
local audio = wp.audio

-- State
local cached_speaker = audio.default_speaker
local cached_microphone = audio.default_microphone

local function focus_steam()
  for _, c in ipairs(client.get()) do
    if c.class == "steam" and c.name:match("^Steam$") then
      local s = c.screen
      local t = c.first_tag
      if s and t then
        awful.screen.focus(s)
        t:view_only()
      end
      break
    end
  end
end

local function wivrn_connected()
  awful.spawn("systemctl --user stop picom")
  awful.spawn("systemctl --user stop easyeffects")
  focus_steam()
end

local function wivrn_disconnected()
  awful.spawn("systemctl --user restart picom")
  awful.spawn("systemctl --user restart easyeffects")
end

gears.timer.start_new(0, function()
  function wp:on_node_added(node)
    local id = node.id
    local name = node.name
    if name == "wivrn.sink" then
      cached_speaker = audio.default_speaker
      local speaker = audio:get_speaker(id)
      speaker:set_is_default(true)
      wivrn_connected()
    elseif name == "wivrn.source" then
      cached_microphone = audio.default_microphone
      local microphone = audio:get_microphone(id)
      microphone:set_is_default(true)
    end
  end

  function wp:on_node_removed(node)
    local name = node.name
    if name == "wivrn.sink" then
      cached_speaker:set_is_default(true)
      wivrn_disconnected()
    elseif name == "wivrn.source" then
      cached_microphone:set_is_default(true)
    end
  end
end)

