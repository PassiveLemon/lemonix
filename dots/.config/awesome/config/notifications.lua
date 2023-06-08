local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

--
-- Notifications
--

beautiful.notification_margin = 8
beautiful.notification_border_width = 2
beautiful.notification_border_color = beautiful.accent
beautiful.notification_max_height = beautiful.notification_icon_size
beautiful.notification_icon_size = 64

naughty.config.defaults.timeout = 3
naughty.config.defaults.screen = awful.screen.focused()
naughty.config.defaults.ontop = true
naughty.config.defaults.margin = 8
naughty.config.defaults.border_width = 2
naughty.config.defaults.position = "bottom_right"

naughty.config.padding = 12

naughty.connect_signal("request::display", function(n)
  naughty.layout.box({ notification = n, })
end)

-- Error handling
naughty.connect_signal("request::display_error", function(message, startup)
  naughty.notification {
    urgency = "critical",
    title = "Oops, an error happened"..(startup and " during startup!" or "!"),
    message = message,
  }
end)