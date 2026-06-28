local gears = require("gears")

local gdk = require("lgi").require("Gdk") -- AWM is built with gtk3
local display = gdk.Display.get_default()
local keymap = gdk.Keymap.get_for_display(display)

-- State
local caps_state = false

local function emit()
  awesome.emit_signal("signal::peripheral::caps::state", caps_state)
end

local function caps_query()
  local new_state = keymap:get_caps_lock_state()
  if caps_state ~= new_state then
    caps_state = new_state
  end
  emit()
end

caps_query()

local caps_query_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    caps_query()
  end,
})

-- The detected caps lock state does not update immediately so we cache our switched state
local function caps()
  caps_state = not caps_state
  emit()
end

awesome.connect_signal("signal::peripheral::caps::update", function()
  caps_query_timer:stop()
  caps()
  caps_query_timer:start()
end)

