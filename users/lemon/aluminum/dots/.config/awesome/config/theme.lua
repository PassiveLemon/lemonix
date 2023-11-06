local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")

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
theme.bg_normal     = theme.bg0
theme.bg_minimize   = theme.bg2
theme.bg_focus      = theme.bg4
theme.bg_urgent     = theme.redd
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = theme.fg0
theme.fg_minimize   = theme.fg2
theme.fg_focus      = theme.fg3
theme.fg_urgent     = theme.fg3

-- Other
theme.accent        = "#535d6c"

theme.border_width        = 3
theme.border_color_normal = theme.blackd
theme.border_color_active = theme.accent

theme.tasklist_fg_minimize       = theme.fg_focus
theme.tasklist_disable_task_name = true
theme.tasklist_spacing           = 1

theme.taglist_squares_sel = theme_assets.taglist_squares_sel(0, theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(0, theme.fg_normal)

theme.useless_gap = 6

theme.margins = 4

theme.layout_dwindle = themes_path .. "default/layouts/dwindlew.png"

--
-- Wallpaper
--

theme.icon_theme = "Papirus"
awful.spawn.easy_async_with_shell("test -f " .. os.getenv("HOME") .. "/.wallpaper-image && echo true || echo false", function(fileTest)
  fileTest = fileTest:gsub("\n", "")
  if fileTest == "false" then
    naughty.notify({ title = "No wallpaper found" })
  end
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

