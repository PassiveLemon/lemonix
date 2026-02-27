require("signal.mpris")

local gears = require("gears")
local b = require("beautiful")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Music
--

local music = { }

music.pill = h.button({
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(2),
  },
  x = dpi(24),
  y = dpi(24),
  shape = gears.shape.circle,
  text = "󰎈",
  button_press = function()
    awesome.emit_signal("ui::control::toggle")
  end
})
awesome.connect_signal("signal::mpris::metadata", function(metadata)
  local pm = metadata["global"]
  if pm and pm.player.status == "PLAYING" then
    music.pill.visible = true
  else
    music.pill.visible = false
  end
end)

return music

