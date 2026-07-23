local gdk = require("lgi").require("Gdk") -- AWM is built with gtk3
local display = gdk.Display.get_default()
local keymap = gdk.Keymap.get_for_display(display)

-- State
local caps_state = false

local function emit()
  awesome.emit_signal("signal::peripheral::caps::state", caps_state)
end

function keymap:on_state_changed()
  local new_state = keymap:get_caps_lock_state()
  if caps_state ~= new_state then
    caps_state = new_state
  end
  emit()
end

