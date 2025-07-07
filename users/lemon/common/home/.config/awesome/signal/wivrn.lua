local awful = require("awful")
local gears = require("gears")

-- TODO: Use lua lgi instead of busctl

local state_cache = false

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

local function wivrn()
  awful.spawn.easy_async("busctl --user get-property io.github.wivrn.Server /io/github/wivrn/Server io.github.wivrn.Server HeadsetConnected", function(wivrn_stdout)
    local wivrn_bus = wivrn_stdout:gsub("\n", "")
    if wivrn_bus == "b true" then
      if not state_cache then
        state_cache = true
        awful.spawn.with_shell("kill $(pgrep picom)")
        focus_steam()
      end
    else
      if state_cache then
        state_cache = false
        awful.spawn.with_shell("pidof -q picom || picom --realtime -b")
      end
    end
  end)
end

-- luacheck: ignore 211
local wivrn_timer = gears.timer({
  timeout = 2,
  autostart = true,
  callback = function()
    wivrn()
  end,
})

