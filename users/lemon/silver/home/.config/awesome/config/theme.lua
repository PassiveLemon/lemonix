local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local menubar_utils = require "menubar.utils"

local theme_assets = require("beautiful.theme_assets")
local themes_path = gears.filesystem.get_themes_dir()

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
theme.font          = theme.sysfont(10)
theme.taglist_font  = theme.sysfont(10)
theme.tasklist_font = theme.sysfont(10)

-- Mono
theme.bg0      = "#222222"
theme.bg1      = "#272727"
theme.bg2      = "#303030"
theme.bg3      = "#343434"
theme.bg4      = "#383838"

theme.fg0      = "#aaaaaa"
theme.fg1      = "#dcdcdc"
theme.fg2      = "#8c8c8c"
theme.fg3      = "#ffffff"
theme.fg4      = "#ffffff"

-- Color
theme.bg       = theme.bg0
theme.fg       = theme.fg0
theme.blackd   = "#31343a"
theme.blackl   = "#40454f"
theme.redd     = "#f05d6b"
theme.redl     = theme.redd
theme.greend   = "#93cb6b"
theme.greenl   = theme.greend
theme.yellowd  = "#eac56f"
theme.yellowl  = theme.yellowd
theme.blued    = "#61b8ff"
theme.bluel    = theme.blued
theme.magentad = "#cd61ec"
theme.magental = theme.magentad
theme.cyand    = "#53d2e0"
theme.cyanl    = theme.cyand
theme.whited   = "#c6c6c6"
theme.whitel   = "#e2e2e2"

-- Links
theme.bg_normal      = theme.bg0
theme.bg_minimize    = theme.bg2
theme.bg_focus       = theme.bg4
theme.bg_urgent      = theme.redd

theme.fg_normal      = theme.fg0
theme.fg_minimize    = theme.fg2
theme.fg_focus       = theme.fg1
theme.fg_urgent      = theme.fg3

theme.ui_main_bg     = theme.bg0
theme.ui_main_fg     = theme.fg0
theme.ui_button_bg   = theme.bg1
theme.ui_button_fg   = theme.fg0
theme.ui_slider_bg   = theme.bg2
theme.ui_slider_fg   = theme.fg0
theme.ui_progress_bg = theme.bg2
theme.ui_progress_fg = theme.fg0

theme.border_width        = 3
theme.border_color_normal = theme.blackd
theme.border_color_active = theme.blackl

theme.tasklist_fg_minimize       = theme.fg_focus
theme.tasklist_disable_task_name = true
theme.tasklist_spacing           = 1

theme.taglist_squares_sel = theme_assets.taglist_squares_sel(0, theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(0, theme.fg_normal)

theme.bg_systray = theme.bg2

theme.useless_gap = 6

theme.margins = 4

theme.layout_dwindle = themes_path .. "default/layouts/dwindlew.png"

-- Media
theme.playerctl_players = "tauon,spotify,Feishin"
theme.playerctl_art_cache_dir = os.getenv("HOME") .. "/.cache/passivelemon/lemonix/media/"

--
-- Wallpaper & icons
--

theme.icon_theme = "Papirus"

client.connect_signal("property::class", function(c)
  if not c.class then return end
  c.theme_icon = menubar_utils.lookup_icon(string.lower(c.class)) or c.icon
end)

theme.wallpaper = os.getenv("HOME") .. "/.wallpaper-image"

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
        image = theme.wallpaper,
        upscale = true,
        downscale = true,
      },
    },
  })
end)

return theme

