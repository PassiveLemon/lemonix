local awful = require("awful")

local function locker()
  awful.spawn([[sh -c " \
  playerctl pause; \
  xrandr --output DP-0 --brightness 0.5; \
  xrandr --output DP-2 --brightness 0.5; \
  i3lock-fancy-rapid 50 10 -n; \
  xrandr --output DP-0 --brightness 1; \
  xrandr --output DP-2 --brightness 1; \
  sleep 0.7 && playerctl play; \
  "]])
end

return { locker = locker }