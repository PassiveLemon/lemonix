local awful = require("awful")
local b = require("beautiful")
local wibox = require("wibox")
local menubar_utils = require("menubar.utils")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Theme
--

local theme = { }

-- Font
function theme.sysfont(size)
  return "FiraCode Nerd Font Mono Ret" .. " " .. size
end
function theme.cusfont(font, size)
  return font .. " " .. size
end
theme.font          = theme.sysfont(dpi(10))
theme.taglist_font  = theme.sysfont(dpi(10))
theme.tasklist_font = theme.sysfont(dpi(10))

-- Mono
theme.bg0      = "#222222"
theme.bg1      = "#292929"
theme.bg2      = "#323232"
theme.bg3      = "#363636"

theme.fg0      = "#8c8c8c"
theme.fg1      = "#aaaaaa"
theme.fg2      = "#dcdcdc"
theme.fg3      = "#ffffff"

-- Color
theme.whited   = "#c6c6c6"
theme.whitel   = "#e2e2e2"
theme.blackd   = "#31343a"
theme.blackl   = "#40454f"
theme.red      = "#f05d6b"
theme.orange   = "#f7aa60"
theme.yellow   = "#eac56f"
theme.green    = "#93cb6b"
theme.cyan     = "#53d2e0"
theme.blue     = "#61b8ff"
theme.magenta  = "#cd61ec"

-- Links
theme.bg             = theme.bg0
theme.fg             = theme.fg0

theme.bg_primary     = theme.bg0
theme.bg_secondary   = theme.bg1
theme.bg_normal      = theme.bg0
theme.bg_minimize    = theme.bg2
theme.bg_focus       = theme.bg3
theme.bg_urgent      = theme.red

theme.fg_primary     = theme.fg1
theme.fg_normal      = theme.fg1
theme.fg_minimize    = theme.fg0
theme.fg_focus       = theme.fg2
theme.fg_urgent      = theme.fg3

theme.border_width         = dpi(3)
theme.border_color_primary = theme.blackd
theme.border_color_normal  = theme.blackd
theme.border_color_active  = theme.blackl
theme.border_color_urgent  = theme.red

theme.tasklist_disable_task_name = true
theme.tasklist_spacing           = dpi(1)

theme.bg_systray = theme.bg_secondary
theme.systray_icon_spacing = dpi(1)
theme.systray_icon_size = dpi(21)

theme.useless_gap = dpi(6)

-- Don't dpi() this, it is applied in widget definitions
theme.margins = 4

-- Media
theme.mpris_players = { "Feishin" }
theme.mpris_art_cache_dir = h.join_path(os.getenv("HOME"), "/.cache/passivelemon/lemonix/media/")
theme.mpris_notifications = true

--
-- Wallpaper & icons
--

theme.icon_theme = "Papirus"

client.connect_signal("property::class", function(c)
  if c.class then
    c.theme_icon = menubar_utils.lookup_icon(string.lower(c.class)) or c.icon
  end
end)

theme.wallpaper = h.join_path(os.getenv("HOME"), "/.wallpaper-image")
theme.lockscreen = h.join_path(os.getenv("HOME"), "/.lockscreen-image")
if not h.is_file(theme.lockscreen) then
  awful.spawn.with_shell("convert " .. theme.wallpaper .. " -filter Gaussian -blur 0x6 -fill 222222c1 -colorize 50% " .. theme.lockscreen)
end

screen.connect_signal("request::wallpaper", function(s)
  awful.wallpaper({
    screen = s,
    widget = {
      widget = wibox.container.tile,
      valign = "center",
      halign = "center",
      tiled = false,
      {
        widget = wibox.widget.imagebox,
        -- Breaks awm
        -- image = gears.surface.crop_surface({
        --   surface = gears.surface.load_uncached(theme.wallpaper),
        --   ratio = s.geometry.width/s.geometry.height,
        -- }),
        image = theme.wallpaper,
        upscale = true,
        downscale = true,
      },
    },
  })
end)

return theme

