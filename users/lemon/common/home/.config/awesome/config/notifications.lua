local awful = require("awful")
local b = require("beautiful")
local wibox = require("wibox")
local ruled = require("ruled")
local naughty = require("naughty")

local dpi = b.xresources.apply_dpi

--
-- Notifications
--

ruled.notification.connect_signal("request::rules", function()
  ruled.notification.append_rule({
    rule = { urgency = "critical" },
    properties = { bg = b.bg_urgent, fg = b.fg_normal, implicit_timeout = 5, timeout = 5 },
  })
  ruled.notification.append_rule({
    rule = { urgency = "normal" },
    properties = { bg = b.bg_normal, fg = b.fg_normal, implicit_timeout = 3, timeout = 3 },
  })
  ruled.notification.append_rule({
    rule = { urgency = "low" },
    properties = { bg = b.bg_normal, fg = b.fg_normal, implicit_timeout = 3, timeout = 3 },
  })
end)

b.notification_margin = (b.margins * 2)
b.notification_border_width = b.border_width
b.notification_border_color = b.border_color_active
b.notification_icon_size = dpi(64)
b.notification_max_height = b.notification_icon_size
b.notification_spacing = dpi(4)

naughty.config.padding = dpi(12)

naughty.config.defaults.timeout = 3
naughty.config.defaults.screen = awful.screen.focused()
naughty.config.defaults.ontop = true
naughty.config.defaults.margin = (b.margins * 2)
naughty.config.defaults.border_width = b.border_width
naughty.config.defaults.position = "bottom_right"

naughty.connect_signal("request::display", function(n)
  naughty.layout.box({
		notification = n,
		type = "notification",
		bg = b.bg_normal,
		widget_template = {
			id = "background_role",
			widget = naughty.container.background,
      {
        widget = wibox.container.margin,
        left = b.margins,
        right = b.margins,
        top = b.margins,
        bottom = b.margins,
        {
          layout = wibox.layout.align.horizontal,
          {
            widget = wibox.container.margin,
            left = b.margins,
            right = b.margins,
            top = b.margins,
            bottom = b.margins,
            {
              widget = wibox.container.constraint,
              strategy = "max",
              width = dpi(89),
              height = dpi(89),
              naughty.widget.icon,
            },
          },
          {
            layout = wibox.layout.align.vertical,
            {
              widget = wibox.container.constraint,
              strategy = "max",
              width = dpi(400),
              {
                widget = wibox.container.margin,
                left = b.margins,
                right = b.margins,
                top = b.margins,
                bottom = b.margins,
                {
                  layout = wibox.layout.align.horizontal,
                  forced_height = dpi(15),
                  naughty.widget.title,
                },
              },
            },
            {
              widget = wibox.container.constraint,
              strategy = "max",
              width = dpi(400),
              {
                widget = wibox.container.constraint,
                strategy = "max",
                height = dpi(200),
                {
                  widget = wibox.container.margin,
                  left = b.margins,
                  right = b.margins,
                  top = b.margins,
                  bottom = b.margins,
                  naughty.widget.message,
                },
              },
            },
          },
        },
      },
		},
	})
end)

-- Error handling
naughty.connect_signal("request::display_error", function(message, startup)
  naughty.notification({
    urgency = "critical",
    title = "Oops, an error happened" .. ((startup and " during startup!") or "!"),
    message = message,
  })
end)

