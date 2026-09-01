local awful = require("awful")

local systemctl = "systemctl --user start "
awful.spawn("systemctl --user import-environment WAYLAND_DISPLAY")
awful.spawn("dbus-update-activation-environment --systemd WAYLAND_DISPLAY")
awful.spawn("xhost +SI:localuser:root") -- Allow root programs to access display
awful.spawn(systemctl .. "nixos-fake-graphical-session.target")

awesome.set_idle_timeout("dpms", 180, function() awesome.dpms_off() end)
awesome.set_idle_timeout("lock", 300, function() awesome.lock() end)

client.connect_signal("property::fullscreen", function()
  local present = false
  for _, c in ipairs(client.get()) do
    if c.fullscreen then
      present = true
      break
    end
  end
  awesome.idle_inhibit = present
end)

awesome.connect_signal("logind::prepare_sleep", function(going_to_sleep)
  if going_to_sleep then awesome.lock() end
end)

awesome.connect_signal("lock::deactivate", function()
  awesome.emit_signal("signal::peripheral::volume::unmute", true)
  -- Unhide all clients
  for s in screen do
    for _, c in ipairs(s.hidden_clients) do
      c.hidden = false
    end
  end
end)

awesome.connect_signal("lock::activate", function()
  awesome.emit_signal("signal::mpris::pause", "%all%")
  awesome.emit_signal("signal::peripheral::volume::mute", true)
  -- Hide all clients and unset focus
  for s in screen do
    s.wibar.ontop = false
    for _, c in ipairs(s.clients) do
      c.hidden = true
    end
  end
  client.focus = nil
end)

