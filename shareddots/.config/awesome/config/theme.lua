local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local theme_assets = require("beautiful.theme_assets")

local themes_path = gears.filesystem.get_themes_dir()

--
-- Theme
--

local theme = { }

-- Font
theme.font          = "FiraMono Nerd Font Regular 10"
theme.font_large    = "FiraMono Nerd Font Regular 24"
theme.taglist_font  = theme.font
theme.tasklist_font = theme.font

-- Colors
theme.accent        = "#535d6c"

theme.bg_normal     = "#222222"
theme.bg_normal2    = "#292929"
theme.bg_minimize   = "#333333"
theme.bg_minimize2  = "#444444"
theme.bg_focus      = theme.accent
theme.bg_urgent     = "#f35252"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#aaaaaa"
theme.fg_normal2    = "#dcdcdc"
theme.fg_minimize   = "#8c8c8c"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"

-- Other
theme.border_width        = 3
theme.border_color_normal = "#000000"
theme.border_color_active = theme.accent
theme.border_color_marked = "#91231c"
theme.useless_gap         = 6

theme.tasklist_fg_minimize = theme.fg_normal2
theme.tasklist_disable_task_name = true
theme.tasklist_spacing = 1

-- Taglist
local taglist_square_size = 0
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, theme.fg_normal)

theme.layout_dwindle = themes_path .. "default/layouts/dwindlew.png"

--
-- Wallpaper
--

theme.icon_theme = "Papirus"
theme.wallpaper = os.getenv("HOME") .. "/.background-image"

screen.connect_signal("request::wallpaper", function(s)
  awful.wallpaper {
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
  }
end)

return theme
