local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local click_to_hide = require("config.helpers.click_to_hide")

--
-- Media management menu
--

local mediamenu_pop_vis = false

local song_name = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}
local artist_name = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

local shuffle = wibox.widget {
  widget = wibox.widget.textbox,
  font = beautiful.font_large,
  align = "center",
  valign = "center",
}

local shuffle_bg = wibox.widget {
  widget = wibox.container.background(shuffle),
  forced_width = 100,
  forced_height = 100,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
}

local prev = wibox.widget {
  widget = wibox.container.background,
  forced_width = 100,
  forced_height = 100,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
  {
    widget = wibox.widget.textbox,
    text = "󰙣",
    font = beautiful.font_large,
    align = "center",
    valign = "center",
  },
}

local toggle = wibox.widget {
  widget = wibox.widget.textbox,
  font = beautiful.font_large,
  align = "center",
  valign = "center",
}

local toggle_bg = wibox.widget {
  widget = wibox.container.background(toggle),
  forced_width = 100,
  forced_height = 100,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
}

local next = wibox.widget {
  widget = wibox.container.background,
  forced_width = 100,
  forced_height = 100,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
  {
    widget = wibox.widget.textbox,
    text = "󰙡",
    font = beautiful.font_large,
    align = "center",
    valign = "center",
  },
}

local loop_bg = wibox.widget {
  widget = wibox.container.background,
  forced_width = 100,
  forced_height = 100,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
  {
    widget = wibox.widget.textbox,
    font = beautiful.font_large,
    align = "center",
    valign = "center",
  },
}

local function updater()
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl metadata title"]], function(song)
    song_name.text = song
  end)
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl metadata artist"]], function(artist)
    artist_name.text = artist
  end)
end

local function shuffler()
  awful.spawn("playerctl shuffle toggle")
  awful.spawn("playerctl shuffle", function(shuffle_state)
    if shuffle_state == "On" then
      shuffle.text = "On"
    elseif shuffle_state == "Off" then
      shuffle.text = "Off"
    end
  end)
end

local function toggler()
  awful.spawn("playerctl status", function(toggle_state)
    if toggle_state == "Playing" then
      toggle.text = "󰏥"
    elseif shuffle_state == "Paused" then
      toggle.text = "󰐌"
    end
  end)
end

--local function looper()

local mediamenu_container = wibox.widget {
  layout = wibox.layout.align.vertical,
  {
    widget = wibox.container.margin,
    margins = { top = 8, right = 8, bottom = 0, left = 8, },
    {
      layout = wibox.layout.fixed.vertical,
      song_name,
      artist_name,
    },
  },
  {
    widget = wibox.container.margin,
    margins = { top = 0, right = 8, bottom = 8, left = 8, },
    {
      layout = wibox.layout.fixed.horizontal,
      shuffle_bg,
      prev,
      toggle_bg,
      next,
      loop_bg,
    },
  },
}

local mediamenu_pop = awful.popup {
  widget = mediamenu_container,
  placement = awful.placement.centered,
  ontop = true,
  visible = mediamenu_pop_vis,
  border_width = 2,
  border_color = beautiful.border_color_active,
}

shuffle_bg:buttons(gears.table.join(awful.button({}, 1, function()
  shuffler()
end)))

shuffle_bg:connect_signal("mouse::enter", function()
  shuffle_bg.fg = beautiful.fg_focus
  shuffle_bg.bg = beautiful.accent
end)

shuffle_bg:connect_signal("mouse::leave", function()
  shuffle_bg.fg = beautiful.fg_normal
  shuffle_bg.bg = beautiful.bg_normal
end)

prev:buttons(gears.table.join(awful.button({}, 1, function()
  awful.spawn("playerctl previous", function()
    updater()
  end)
end)))

prev:connect_signal("mouse::enter", function()
  prev.fg = beautiful.fg_focus
  prev.bg = beautiful.accent
end)

prev:connect_signal("mouse::leave", function()
  prev.fg = beautiful.fg_normal
  prev.bg = beautiful.bg_normal
end)

toggle_bg:buttons(gears.table.join(awful.button({}, 1, function()
  awful.spawn("playerctl play-pause", function()
    updater()
  end)
end)))

toggle_bg:connect_signal("mouse::enter", function()
  toggle_bg.fg = beautiful.fg_focus
  toggle_bg.bg = beautiful.accent
end)

toggle_bg:connect_signal("mouse::leave", function()
  toggle_bg.fg = beautiful.fg_normal
  toggle_bg.bg = beautiful.bg_normal
end)

next:buttons(gears.table.join(awful.button({}, 1, function()
  awful.spawn("playerctl next", function()
    updater()
  end)
end)))

next:connect_signal("mouse::enter", function()
  next.fg = beautiful.fg_focus
  next.bg = beautiful.accent
end)

next:connect_signal("mouse::leave", function()
  next.fg = beautiful.fg_normal
  next.bg = beautiful.bg_normal
end)

loop_bg:buttons(gears.table.join(awful.button({}, 1, function()
  --looper()
end)))

loop_bg:connect_signal("mouse::enter", function()
  loop_bg.fg = beautiful.fg_focus
  loop_bg.bg = beautiful.accent
end)

loop_bg:connect_signal("mouse::leave", function()
  loop_bg.fg = beautiful.fg_normal
  loop_bg.bg = beautiful.bg_normal
end)

awesome.connect_signal("signal::mediamenu", function()
  updater()
  mediamenu_pop_vis = not mediamenu_pop_vis
  mediamenu_pop.visible = mediamenu_pop_vis
  mediamenu_pop.screen = awful.screen.focused()
end)

click_to_hide.popup(mediamenu_pop, nil, true)