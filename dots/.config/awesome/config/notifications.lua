local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local ruled = require("ruled")
local naughty = require("naughty")

local helpers = require("helpers")

--
-- Notifications
--

ruled.notification.connect_signal('request::rules', function()
  ruled.notification.append_rule {
    rule = { urgency = "critical" },
    properties = { bg = beautiful.bg_urgent, fg = beautiful.fg_normal, implicit_timeout = 5, timeout = 5, },
  }
  ruled.notification.append_rule {
    rule = { urgency = "normal" },
    properties = { bg = beautiful.bg_normal, fg = beautiful.fg_normal, implicit_timeout = 3, timeout = 3, },
  }
  ruled.notification.append_rule {
    rule = { urgency = "low" },
    properties = { bg = beautiful.bg_normal, fg = beautiful.fg_normal, implicit_timeout = 3, timeout = 3, },
  }
end)

beautiful.notification_margin = 8
beautiful.notification_border_width = 2
beautiful.notification_border_color = beautiful.border_color_active
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
  naughty.layout.box {
		notification = n,
		type = "notification",
		bg = beautiful.bg_normal,
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
              width = 69,
              height = 69,
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
                height = 50,
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
