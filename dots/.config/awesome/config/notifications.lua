local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")
local naughty = require("naughty")

local dpi = beautiful.xresources.apply_dpi

--
-- Notifications
--

naughty.connect_signal("request::display", function(n)
  naughty.layout.box { notification = n }
end)

naughty.config.defaults.padding = 2
naughty.config.defaults.ontop = true
naughty.config.defaults.timeout = 3
naughty.config.defaults.icon_size = dpi(32)
naughty.config.defaults.screen = awful.screen.focused()
naughty.config.defaults.border_width = dpi(2)
naughty.config.defaults.border_color = "#535d6c"
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.margin = dpi(5)

ruled.notification.connect_signal('request::rules', function()
  ruled.notification.append_rule {
    rule       = { urgency = "critical" },
    properties = { bg = "#f35252", fg = beautiful.fg_normal, implicit_timeout = 5, timeout = 5, },
  }
  ruled.notification.append_rule {
    rule       = { urgency = "normal" },
    properties = { bg = beautiful.bg_normal, fg = beautiful.fg_normal, implicit_timeout = 3, timeout = 3, },
  }
  ruled.notification.append_rule {
    rule       = { urgency = "low" },
    properties = { bg = beautiful.bg_normal, fg = beautiful.fg_normal, implicit_timeout = 3, timeout = 3, },
  }
end)

-- Error handling
naughty.connect_signal("request::display_error", function(message, startup)
  naughty.notification {
    urgency = "critical",
    title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
    message = message,
  }
end)