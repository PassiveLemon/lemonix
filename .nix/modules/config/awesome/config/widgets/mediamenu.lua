local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local click_to_hide = require("config.helpers.click_to_hide")

--
-- Media management menu
--

local title = wibox.widget {
  widget = wibox.widget.textbox,
  text = "No players found",
  align = "left",
  valign = "center",
}

local title_box = wibox.widget {
  widget = wibox.container.background(title),
  forced_width = 532,
  forced_height = 15,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
}

local artist = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

local artist_box = wibox.widget {
  widget = wibox.container.background(artist),
  forced_width = 532,
  forced_height = 15,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
}

local shuffle = wibox.widget {
  widget = wibox.widget.textbox,
  text = "󰒞",
  font = beautiful.font_large,
  align = "center",
  valign = "center",
}

local shuffle_box = wibox.widget {
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
  text = "󰐊",
  font = beautiful.font_large,
  align = "center",
  valign = "center",
}

local toggle_box = wibox.widget {
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
  text = "󰑗",
  font = beautiful.font_large,
  align = "center",
  valign = "center",
}

local loop_box = wibox.widget {
  widget = wibox.container.background(loop),
  forced_width = 100,
  forced_height = 100,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
  shape = gears.shape.rounded_rect,
}

local volume = wibox.widget {
  widget = wibox.widget.slider,
  maximum = 100,
  bar_height = 6,
  handle_width = 15,
}

local volume_box = wibox.widget {
  widget = wibox.container.background(volume),
  forced_width = 532,
  forced_height = 15,
  fg = beautiful.fg_normal,
  bg = beautiful.bg_normal,
}

local function updater()
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl metadata title"]], function(title_state)
    title.text = title_state
  end)
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl metadata artist"]], function(artist_state)
    artist.text = artist_state
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
  awful.spawn.easy_async([[sh -c "sleep 0.1 && playerctl volume"]], function(volume_state)
    volume.value = math.floor(volume_state * 100 + 0.5)
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
    margins = { top = 8, right = 8, bottom = 4, left = 8, },
    {
      layout = wibox.layout.fixed.vertical,
      title_box,
      artist_box,
    },
  },
  {
    widget = wibox.container.margin,
    margins = { top = 4, right = 8, bottom = 4, left = 8, },
    {
      layout = wibox.layout.fixed.horizontal,
      shuffle_box,
      prev,
      toggle_box,
      next,
      loop_box,
    },
  },
  {
    widget = wibox.container.margin,
    margins = { top = 4, right = 8, bottom = 8, left = 8, },
    {
      layout = wibox.layout.fixed.horizontal,
      volume_box,
    },
  },
}

local mediamenu_pop = awful.popup {
  widget = mediamenu_container,
  placement = awful.placement.centered,
  ontop = true,
  border_width = 2,
  border_color = beautiful.border_color_active,
}

mediamenu_pop.visible = false

shuffle_box:buttons(gears.table.join(awful.button({}, 1, function()
  shuffler()
end)))

shuffle_box:connect_signal("mouse::enter", function()
  shuffle_box.fg = beautiful.fg_focus
  shuffle_box.bg = beautiful.accent
end)

shuffle_box:connect_signal("mouse::leave", function()
  shuffle_box.fg = beautiful.fg_normal
  shuffle_box.bg = beautiful.bg_normal
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

toggle_box:buttons(gears.table.join(awful.button({}, 1, function()
  toggler()
end)))

toggle_box:connect_signal("mouse::enter", function()
  toggle_box.fg = beautiful.fg_focus
  toggle_box.bg = beautiful.accent
end)

toggle_box:connect_signal("mouse::leave", function()
  toggle_box.fg = beautiful.fg_normal
  toggle_box.bg = beautiful.bg_normal
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

loop_box:buttons(gears.table.join(awful.button({}, 1, function()
  looper()
end)))

loop_box:connect_signal("mouse::enter", function()
  loop_box.fg = beautiful.fg_focus
  loop_box.bg = beautiful.accent
end)

loop_box:connect_signal("mouse::leave", function()
  loop_box.fg = beautiful.fg_normal
  loop_box.bg = beautiful.bg_normal
end)

volume:connect_signal("property::value", function(_, volume_state)
	volume.value = volume_state
	awful.spawn("playerctl volume " .. (volume_state/100), false)
end)

local function signal()
  updater()
  mediamenu_pop.visible = not mediamenu_pop.visible
  mediamenu_pop.screen = awful.screen.focused()
end

click_to_hide.popup(mediamenu_pop, nil, true)

return { signal = signal, updater = updater }