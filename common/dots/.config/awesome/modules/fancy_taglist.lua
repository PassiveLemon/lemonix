-- Credit to https://gist.github.com/intrntbrn/08af1058d887f4d10a464c6f272ceafa/

local awful = require("awful")
local wibox = require("wibox")

local module = {}

local function constrain_icon(widget)
  return {
    id = "margintest",
    widget = wibox.container.margin,
    top = 3,
    right = 1,
    bottom = 3,
    left = 1,
		{
			widget = wibox.container.constraint,
			height = 20,
			strategy = 'exact',
			widget,
    },
  }
end

local generate_filter = function(t)
	return function(c, scr)
		local ctags = c:tags()
		for _, v in ipairs(ctags) do
			if v == t then
				return true
			end
		end
		return false
	end
end

local fancytasklist = function(cfg, t)
	return awful.widget.tasklist({
		screen = cfg.screen or awful.screen.focused(),
		filter = generate_filter(t),
		buttons = cfg.tasklist_buttons,
		widget_template = {
			layout = wibox.layout.stack,
      {
				widget = wibox.container.margin,
				right = 2,
				{
					id = "clienticon",
					widget = awful.widget.clienticon,
				},
      },
      create_callback = function(self, c, _, _)
				self:get_children_by_id("clienticon")[1].client = c
			end,
		},
	})
end

function module.new(config)
	local cfg = config or {}

	local s = cfg.screen or awful.screen.focused()
	local taglist_buttons = cfg.taglist_buttons

	return awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
    buttons = taglist_buttons,
		widget_template = {
			layout = wibox.layout.fixed.horizontal,
			create_callback = function(self, _, index, _)
				local t = s.tags[index]
				self:get_children_by_id("tasklist_placeholder")[1]:add(fancytasklist(cfg, t))
      end,
			{
				id = "background_role",
				widget = wibox.container.background,
				{
          widget = wibox.container.margin,
          left = 2,
          {
            layout = wibox.layout.fixed.horizontal,
            -- tag
            {
              id = "text_role",
              widget = wibox.widget.textbox,
              align = "center",
            },
            -- tasklist
            constrain_icon {
              id = "tasklist_placeholder",
              layout = wibox.layout.fixed.horizontal,
            },
          },
				},
			},
		},
	})
end

return module
