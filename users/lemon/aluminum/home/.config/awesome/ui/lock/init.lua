-- Mostly from https://github.com/chadcat7/crystal/blob/aura/ui/lock/init.lua/

require("ui.lock.lockscreen")

local awful = require("awful")

local pam = require("liblua_pam") -- Compile and link from https://github.com/RMTT/lua-pam/. `nix-shell -p cmake lua linux-pam`

--
-- Lockscreen function
--

local function auth(password)
  return pam.auth_current_user(password)
end

local function grab()
  local input = ""
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
        if #input < 32 then
          awesome.emit_signal("ui::lock::keypress", key, input, nil)
          if input == nil then
            input = key
          end
          input = input .. key
        else
          -- Doesn't actually backspace, we just use this so we can get the color
          awesome.emit_signal("ui::lock::keypress", "BackSpace", "", nil)
        end
      elseif key == "BackSpace" then
        awesome.emit_signal("ui::lock::keypress", key, input, nil)
        input = input:sub(1, -2)
      elseif key == "Escape" then
        awesome.emit_signal("ui::lock::keypress", key, input, nil)
        input = ""
      end
    end,
    keyreleased_callback = function(self, _, key, _)
      if key == "Return" then
        if auth(input) then
          awesome.emit_signal("ui::lock::keypress", key, input, true)
          awesome.emit_signal("ui::lock::state", false)
          input = ""
          self:stop()
        else
          awesome.emit_signal("ui::lock::keypress", key, input, false)
          awesome.emit_signal("ui::lock::state", true)
          input = ""
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

-- Lock by default
awesome.emit_signal('ui::lock::toggle')
