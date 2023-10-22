local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")
local ruled = require("ruled")
local naughty = require("naughty")

--
-- Notifications
--

ruled.notification.connect_signal("request::rules", function()
  ruled.notification.append_rule {
    rule = { urgency = "critical" },
    properties = { bg = b.bg_urgent, fg = b.fg_normal, implicit_timeout = 5, timeout = 5, },
  }
  ruled.notification.append_rule {
    rule = { urgency = "normal" },
    properties = { bg = b.bg_normal, fg = b.fg_normal, implicit_timeout = 3, timeout = 3, },
  }
  ruled.notification.append_rule {
    rule = { urgency = "low" },
    properties = { bg = b.bg_normal, fg = b.fg_normal, implicit_timeout = 3, timeout = 3, },
  }
end)

b.notification_margin = 8
b.notification_border_width = 2
b.notification_border_color = b.border_color_active
b.notification_max_height = b.notification_icon_size
b.notification_icon_size = 64

naughty.config.defaults.timeout = 3
naughty.config.defaults.screen = awful.screen.focused()
naughty.config.defaults.ontop = true
naughty.config.defaults.margin = 8
naughty.config.defaults.border_width = 2
naughty.config.defaults.position = "bottom_right"

naughty.config.padding = 12

naughty.connect_signal("request::display", function(n)
  naughty.layout.box {
		notification = n,
		type = "notification",
		bg = b.bg_normal,
		widget_template = {
			id = "background_role",
			widget = naughty.container.background,
      {
        widget = wibox.container.margin,
        left = 4,
        right = 4,
        top = 4,
        bottom = 4,
        {
          layout = wibox.layout.align.horizontal,
          {
            widget = wibox.container.margin,
            left = 4,
            right = 4,
            top = 4,
            bottom = 4,
            {
              widget = wibox.container.constraint,
              strategy = "max",
              width = 89,
              height = 89,
              naughty.widget.icon,
            },
          },
          {
            layout = wibox.layout.align.vertical,
            {
              widget = wibox.container.constraint,
              strategy = "max",
              width = 400,
              {
                widget = wibox.container.margin,
                left = 4,
                right = 4,
                top = 4,
                bottom = 4,
                {
                  layout = wibox.layout.align.horizontal,
                  forced_height = 15,
                  naughty.widget.title,
                },
              },
            },
            {
              widget = wibox.container.constraint,
              strategy = "max",
              width = 400,
              {
                widget = wibox.container.constraint,
                strategy = "max",
                height = 200,
                {
                  widget = wibox.container.margin,
                  left = 4,
                  right = 4,
                  top = 0,
                  bottom = 4,
                  naughty.widget.message,
                },
              },
            },
          },
        },
      },
		},
	}
end)

-- Error handling
naughty.connect_signal("request::display_error", function(message, startup)
  naughty.notification {
    urgency = "critical",
    title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
    message = message,
  }
end)
