require("signal.mpris")

local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Music
--

local music = { }

local total_width = 350

local xdg_cache_home = h.join_path(os.getenv("HOME"), "/.cache/passivelemon/lemonix/media/")
if not h.is_dir(xdg_cache_home) then
  gears.filesystem.make_directories(xdg_cache_home)
end

local art_image_box = h.text({
  margin = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  x = dpi(130),
  y = dpi(130),
  shape = gears.shape.rounded_rect,
})

local title_text = h.text({
  x = dpi(532),
  y = dpi(17),
  halign = "center",
})

local artist_text = h.text({
  x = dpi(532),
  y = dpi(17),
  halign = "center",
})

local album_text = h.text({
  x = dpi(532),
  y = dpi(17),
  halign = "center",
})

local prev_button = h.button({
  x = dpi(50),
  y = dpi(50),
  shape = gears.shape.rounded_rect,
  text = "󰒮",
  font = b.sysfont(dpi(18)),
  button_press = function()
    awesome.emit_signal("signal::mpris::previous")
  end
})

local toggle_button = h.button({
  x = dpi(50),
  y = dpi(50),
  shape = gears.shape.rounded_rect,
  text = "󰐊",
  font = b.sysfont(dpi(17)),
  button_press = function()
    awesome.emit_signal("signal::mpris::toggle")
  end
})

local next_button = h.button({
  x = dpi(50),
  y = dpi(50),
  shape = gears.shape.rounded_rect,
  text = "󰒭",
  font = b.sysfont(dpi(18)),
  button_press = function()
    awesome.emit_signal("signal::mpris::next")
  end
})

local position_slider = h.slider({
  x = dpi(50 + 50 + 50),
  y = dpi(16),
  max = 100,
  handle_width = dpi(16),
  bar_height = dpi(6),
  bar_shape = gears.shape.rounded_rect,
  output_signal = "signal::mpris::position",
})

local function metadata_updater(metadata)
  if metadata.player.title == "" then
    art_image_box.visible = false
    artist_text.visible = false
    album_text.visible = false
    position_slider.visible = false
    title_text:get_children_by_id("textbox")[1].text = "No media found"
  else
    title_text:get_children_by_id("textbox")[1].text = metadata.media.title
    if metadata.media.artist == "" then
      artist_text.visible = false
    else
      artist_text.visible = true
      artist_text:get_children_by_id("textbox")[1].text = "By " .. metadata.media.artist
    end
    album_text:get_children_by_id("textbox")[1].text = "On " .. metadata.media.album
  end
end

local function toggle_updater(metadata)
  if metadata.player.status == "PLAYING" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰏤"
  elseif metadata.player.status == "PAUSED" then
    toggle_button:get_children_by_id("textbox")[1].text = "󰐊"
  end
end

local function position_updater(metadata)
  if (metadata.player.position == "") or (metadata.media.length == "") then
    position_slider.visible = false
  else
    position_slider.visible = true
    position_slider:get_children_by_id("slider")[1]._private.value = h.round(((metadata.player.position / metadata.media.length) * 100), 3)
    position_slider:emit_signal("widget::redraw_needed")
  end
end

music.control = h.background({
  layout = wibox.layout.fixed.horizontal,
  art_image_box,
  {
    widget = h.margin({
      layout = wibox.layout.fixed.vertical,
      title_text,
      artist_text,
      {
        layout = wibox.layout.flex.horizontal,
        prev_button,
        toggle_button,
        next_button,
      },
      position_slider,
    },
    {
      margins = {
        right = dpi(8),
        left = dpi(8),
      },
    })
  },
},
{
  -- control center width, margins
  x = dpi(total_width - (b.margins * 4)),
  -- art image height, margins
  y = dpi(130 + (b.margins * 2)),
  bg = b.bg_secondary,
  shape = gears.shape.rounded_rect,
})

music.notif = h.background({
  layout = wibox.layout.align.horizontal,
  art_image_box,
  {
    widget = h.margin({
      layout = wibox.layout.fixed.vertical,
      title_text,
      artist_text,
      album_text,
      {
        layout = wibox.layout.flex.horizontal,
        prev_button,
        toggle_button,
        next_button,
      },
    },
    {
      margins = {
        right = dpi(8),
        left = dpi(8),
      },
    })
  },
},
{
  -- control center width, margins
  x = dpi(total_width - (b.margins * 4)),
  -- art image height, margins
  y = dpi(130 + (b.margins * 2)),
  bg = b.bg_secondary,
  shape = gears.shape.rounded_rect,
})

awesome.connect_signal("signal::mpris::metadata", function(metadata)
  if metadata.player.available then
    music.control.visible = true
    art_image_box:get_children_by_id("imagebox")[1].image = metadata.media.art_image
    metadata_updater(metadata)
    toggle_updater(metadata)
    position_updater(metadata)
  else
    music.control.visible = false
  end
end)

return music

