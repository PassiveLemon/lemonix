local awful = require("awful")

local function locker()
  awful.spawn("sh -c ' \
  playerctl pause; \
  i3lock-fancy-rapid 50 10 -n; \
  playerctl play; \
  '")
end

return { locker = locker }