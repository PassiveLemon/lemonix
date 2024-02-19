-- Mostly from https://github.com/chadcat7/crystal/blob/aura/ui/lock/init.lua/

require("ui.lock.lockscreen")

local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local pam = require("liblua_pam") -- Compile and link from https://github.com/RMTT/lua-pam/

local function auth(password)
  return pam.auth_current_user(password)
end

local function visible(v)
  awesome.emit_signal("ui::lock::screen", v)
end

local input = ""
local function grab()
  local grabber = awful.keygrabber {
    auto_start = true,
    stop_event = "release",
    mask_event_callback = true,
    keybindings = {
      awful.key {
        modifiers = { "Mod1", "Mod4", "Shift", "Control" },
        key = "Return",
        on_press = function(_)
          input = input
        end
      }
    },
    keypressed_callback = function(_, _, key, _)
      if key == "Escape" then
        input = ""
        return
      end
      if #key == 1 then
        awesome.emit_signal("ui::lock::keypress", key, input, nil)
        if input == nil then
          input = key
          return
        end
        input = input .. key
      elseif key == "BackSpace" then
        awesome.emit_signal("ui::lock::keypress", key, input, nil)
        input = input:sub(1, -2)
      end
    end,
    keyreleased_callback = function(self, _, key, _)
      if key == "Return" then
        if auth(input) then
          awesome.emit_signal("ui::lock::keypress", key, input, true)
          self:stop()
          visible(false)
          input = ""
        else
          awesome.emit_signal("ui::lock::keypress", key, input, false)
          visible(true)
          grab()
          input = ""
        end
      end
    end
  }
  grabber:start()
end

awesome.connect_signal("ui::lock::toggle", function()
  visible(true)
  grab()
end)
