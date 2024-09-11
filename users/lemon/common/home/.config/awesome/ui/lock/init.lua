-- Mostly from https://github.com/chadcat7/crystal/blob/aura/ui/lock/init.lua/

require("ui.lock.lockscreen")

local awful = require("awful")

local h = require("helpers")
local pam = require("liblua_pam") -- Compile and link from https://github.com/RMTT/lua-pam/. `nix-shell -p cmake lua linux-pam`

--
-- Lockscreen function
--

local function auth(password)
  return pam.auth_current_user(password)
end

local function grab()
  local input = ""
  local input_count = 0
  local grabber = awful.keygrabber({
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
      if #key == 1 then
        if input_count < 32 then
          awesome.emit_signal("ui::lock::keypress", key, input_count, nil)
          if input == nil then
            input = key
          end
          input = input .. key
          input_count = input_count + 1
        elseif input_count > 33 then
          -- Doesn't actually enter escape, we just use this so we can show colors
          awesome.emit_signal("ui::lock::keypress", "Escape", 0, nil)
          input = ""
          input_count = 0
        else
          awesome.emit_signal("ui::lock::keypress", "BackSpace", 0, nil)
        end
      elseif key == "BackSpace" then
        awesome.emit_signal("ui::lock::keypress", key, input_count, nil)
        input = input:sub(1, -2)
        if input_count > 0 then
          input_count = input_count - 1
        end
      elseif key == "Escape" then
        awesome.emit_signal("ui::lock::keypress", key, 0, nil)
        input = ""
        input_count = 0
      elseif key == "Return" then
        awesome.emit_signal("ui::lock::keypress", key, 0, nil)
      end
    end,
    keyreleased_callback = function(self, _, key, _)
      if key == "Return" then
        if auth(input) then
          awesome.emit_signal("ui::lock::keypress", key, input_count, true)
          awesome.emit_signal("ui::lock::state", false)
          input = ""
          input_count = 0
          self:stop()
        else
          awesome.emit_signal("ui::lock::keypress", key, input_count, false)
          awesome.emit_signal("ui::lock::state", true)
          input = ""
          input_count = 0
        end
      end
    end
  })
  grabber:start()
end

awesome.connect_signal("ui::lock::toggle", function()
  awesome.emit_signal("ui::lock::state", true)
  grab()
end)

-- Startup locking behavior
if h.is_file(os.getenv("HOME") .. "/.cache/passivelemon/loginauth") then
  os.remove(os.getenv("HOME") .. "/.cache/passivelemon/loginauth")
else
  awesome.emit_signal('ui::lock::toggle')
end

