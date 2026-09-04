-- Heavily inspired by https://github.com/chadcat7/crystal/blob/aura/ui/lock/init.lua/

require("ui.lock.lockscreen")

local awful = require("awful")

local h = require("helpers")

local lfs = require("lfs")

--
-- Lockscreen function
--

awesome.connect_signal("lock::activate", function()
  local input = ""
  awful.keygrabber({
    auto_start = true,
    stop_event = "release",
    mask_event_callback = true,
    keybindings = {
      awful.key {
        modifiers = { "Mod1", "Mod4", "Shift", "Control" },
        key = "Return",
        on_press = function()
          input = input
        end
      }
    },
    keypressed_callback = function(self, _, key)
      if #key == 1 then
        input = (input or "") .. key
      elseif key == "BackSpace" then
        input = input:sub(1, -2)
      elseif key == "Escape" then
        input = ""
      elseif key == "Return" then
        input = ""
        awesome.authenticate(input)
        awesome.unlock()
        self:stop()
      elseif key == "Caps_Lock" then
        awesome.emit_signal("signal::peripheral::caps::update")
      end
      awesome.emit_signal("ui::lock::keypress", key, #input)
    end
  })
end)

-- Don't require auth if login handoff from the .bash_profile script is present
local auth_file = h.join_path(os.getenv("HOME"), "/.cache/somewm/loginauth")
local lxl_ipc = h.join_path(os.getenv("HOME"), "/.config/lite-xl/ipc")
if h.is_file(auth_file) then
  os.remove(tostring(auth_file))
  -- The Lite-XL IPC plugin can prevent LXL from starting if an ipc.lua "socket" is left, which happens when LXL is SIGKILL'd. That usually only happens when the userspace doesn't shutdown properly and/or the computer powers off so we only want the sockets to be removed on startup in that event.
  for ipc in lfs.dir(lxl_ipc) do
    if ipc:match("^%d+%.lua$") then
      os.remove(h.join_path(lxl_ipc, ipc))
    end
  end
else
  awesome.lock()
end

