local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local click_to_hide = require("config.helpers.click_to_hide")

--
-- Media management menu
--

local mediamenu_pop_vis = false

local title_text = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}
local artist_text = wibox.widget {
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
    text = "󰒮",
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
    text = "󰒭",
    font = beautiful.font_large,
    align = "center",
    valign = "center",
  },
}

local loop = wibox.widget {
  widget = wibox.widget.textbox,
  font = beautiful.font_large,
  align = "center",
  valign = "center",
}

local loop_bg = wibox.widget {
  widget = wibox.container.background(loop),
  forced_width = 100,
  forced_height = 100,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
}

local function updater()
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl metadata title"]], function(title)
    title_text.text = title
  end)
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl metadata artist"]], function(artist)
    artist_text.text = artist
  end)
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl shuffle"]], function(shuffle_state)
    if shuffle_state:find("On") then
      shuffle.text = "󰒝"
    elseif shuffle_state:find("Off") then
      shuffle.text = "󰒞"
    end
  end)
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl status"]], function(toggle_state)
    if toggle_state:find("Playing") then
      toggle.text = "󰏤"
    elseif toggle_state:find("Paused") then
      toggle.text = "󰐊"
    end
  end)
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl loop"]], function(loop_state)
    if loop_state:find("None") then
      loop.text = "󰑗"
    elseif loop_state:find("Playlist") then
      loop.text = "󰑖"
    elseif loop_state:find("Track") then
      loop.text = "󰑘"
    end
  end)
end

local function shuffler()
  awful.spawn.easy_async("playerctl shuffle", function(shuffle_state)
    if shuffle_state:find("On") then
      awful.spawn("playerctl shuffle off")
    elseif shuffle_state:find("Off") then
      awful.spawn("playerctl shuffle on")
    end
    updater()
  end)
end

local function toggler()
  awful.spawn.easy_async("playerctl status", function(toggle_state)
    if toggle_state:find("Playing") then
      awful.spawn("playerctl pause")
    elseif toggle_state:find("Paused") then
      awful.spawn("playerctl play")
    end
    updater()
  end)
end

local function looper()
  awful.spawn.easy_async("playerctl loop", function(loop_state)
    if loop_state:find("None") then
      awful.spawn("playerctl loop Playlist")
    elseif loop_state:find("Playlist") then
      awful.spawn("playerctl loop Track")
    elseif loop_state:find("Track") then
      awful.spawn("playerctl loop None")
    end
    updater()
  end)
end

local mediamenu_container = wibox.widget {
  layout = wibox.layout.align.vertical,
  {
    widget = wibox.container.margin,
    margins = { top = 8, right = 8, bottom = 0, left = 8, },
    {
      layout = wibox.layout.fixed.vertical,
      title_text,
      artist_text,
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
  awful.spawn("playerctl previous")
  updater()
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
  toggler()
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
  awful.spawn("playerctl next")
  updater()
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
  looper()
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