local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("modules.helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Control Center
--

-- Calendar
local calendar = wibox.widget {
  widget = wibox.container.margin,
  margins = { bottom = 0, },
  {
    widget = wibox.widget.textbox,
    markup = " 󰸗 ",
    align = "center",
    valign = "center",
    font = "Fira Code Nerd Font 11",
  },
}

-- Clock
local clock = wibox.widget {
  widget = wibox.container.margin,
  margins = { bottom = 0, },
  {
    widget = wibox.widget.textbox,
    markup = " 󰥔 ",
    align = "center",
    valign = "center",
    font = "Fira Code Nerd Font 11",
  },
}

local backgroundimage = helpers.simpleimg(192, 108, os.getenv("HOME") .. "/.background-image", 4, 4, 4, 4)
local profileimage = helpers.simpleimg(70, 70, os.getenv("HOME") .. "/.profile-image", 16, 58, 16, 58)

local artimage = helpers.simpleimg(132, 132, nil, 8, 4, 8, 8)

local title = helpers.simpletxt(252, 20, nil, beautiful.font, "left", 8, 4, 4, 4)

local artist = helpers.simpletxt(252, 20, nil, beautiful.font, "left", 4, 4, 4, 4)

local album = helpers.simpletxt(252, 20, nil, beautiful.font, "left", 4, 4, 4, 4)

local shuffle = helpers.simplebtn(100, 100, "󰒞", beautiful.font_large, 4, 4, 4, 4)

local prev = helpers.simplebtn(100, 100, "󰒮", beautiful.font_large, 4, 4, 4, 4)

local toggle = helpers.simplebtn(100, 100, "󰐊", beautiful.font_large, 4, 4, 4, 4)

local next = helpers.simplebtn(100, 100, "󰒭", beautiful.font_large, 4, 4, 4, 4)

local loop = helpers.simplebtn(100, 100, "󰑗", beautiful.font_large, 4, 4, 4, 4)

--wip
local position_cur = helpers.simpletxt(532, 15, nil, beautiful.font, "left", 4, 4, 4, 4)
local position_tot = helpers.simpletxt(532, 15, nil, beautiful.font, "left", 4, 4, 4, 4)
--

local position = helpers.simplesldr(252, 16, 16, 6, 100, 4, 4, 4, 4)

local volume_icon = helpers.simpleicn(18, 15, "󰕾", "Fira Code Nerd Font 12", 3, 5, 3, 0)

local volume = helpers.simplesldr(252, 16, 16, 6, 100, 4, 4, 4, 0)

local function artimageupdater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify metadata mpris:artUrl", function(artUrl)
    artUrl = artUrl.gsub(artUrl, "\n", "")
    if artUrl == "" or artUrl == "No players found" or artUrl == "No player could handle this command" then
      artimage.visible = false
      title:get_children_by_id("background")[1].forced_width = 400
    else
      artUrlTrim = artUrl.gsub(artUrl, ".*/", "")
      artUrlFile = gears.surface.load_silently("/tmp/mediamenu/" .. artUrlTrim, beautiful.layout_fullscreen)
      imageAspRat = (artUrlFile:get_width() / artUrlFile:get_height())
      ImageDynHeight = (132)
      imageDynWidth = math.floor((imageAspRat * ImageDynHeight) + 0.5)
      awful.spawn.with_shell("test -f /tmp/mediamenu/" .. artUrlTrim .. " || curl -Lso /tmp/mediamenu/" .. artUrlTrim .. " " .. artUrl)
      artimage:get_children_by_id("constraint")[1].forced_width = imageDynWidth
      artimage:get_children_by_id("constraint")[1].forced_height = ImageDynHeight
      artimage:get_children_by_id("imagebox")[1].image = artUrlFile
      artimage.visible = true
      title:get_children_by_id("background")[1].forced_width = (400 - 8 - imageDynWidth)
    end
    artist:get_children_by_id("background")[1].forced_width = title:get_children_by_id("textbox")[1].width
    album:get_children_by_id("background")[1].forced_width = title:get_children_by_id("textbox")[1].width
  end)
end

local function metadataupdater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify metadata xesam:title", function(title_state)
    title_state = title_state.gsub(title_state, "\n", "")
    if title_state == "" or title_state == "No players found" or title_state == "No player could handle this command" then
      artist.visible = false
      album.visible = false
      title:get_children_by_id("textbox")[1].text = "No media found"
    else
      title:get_children_by_id("textbox")[1].text = title_state
    end
  end)
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify metadata xesam:artist", function(artist_state)
    artist_state = artist_state.gsub(artist_state, "\n", "")
    if artist_state == "" or artist_state == "No players found" or artist_state == "No player could handle this command" then
      artist.visible = false
    else
      artist.visible = true
      artist:get_children_by_id("textbox")[1].text = "By " .. artist_state
    end
  end)
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify metadata xesam:album", function(album_state)
    album_state = album_state.gsub(album_state, "\n", "")
    if album_state == "" or album_state == "No players found" or album_state == "No player could handle this command" then
      album.visible = false
    else
      album.visible = true
      album:get_children_by_id("textbox")[1].text = "On " .. album_state
    end
  end)
end

local function shuffleupdater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify shuffle", function(shuffle_state)
    shuffle:get_children_by_id("textbox")[1].font = beautiful.font_large
    if shuffle_state:find("On") then
      shuffle:get_children_by_id("textbox")[1].text = "󰒝"
    elseif shuffle_state:find("Off") then
      shuffle:get_children_by_id("textbox")[1].text = "󰒞"
    end
  end)
end

local function toggleupdater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify status", function(toggle_state)
    toggle:get_children_by_id("textbox")[1].font = beautiful.font_large
    if toggle_state:find("Playing") then
      toggle:get_children_by_id("textbox")[1].text = "󰏤"
    elseif toggle_state:find("Paused") then
      toggle:get_children_by_id("textbox")[1].text = "󰐊"
    end
  end)
end

local function loopupdater()
  awful.spawn.easy_async_with_shell("sleep 0.15 && playerctl -p spotify loop", function(loop_state)
    loop:get_children_by_id("textbox")[1].font = beautiful.font_large
    if loop_state:find("None") then
      loop:get_children_by_id("textbox")[1].text = "󰑗"
    elseif loop_state:find("Playlist") then
      loop:get_children_by_id("textbox")[1].text = "󰑖"
    elseif loop_state:find("Track") then
      loop:get_children_by_id("textbox")[1].text = "󰑘"
    end
  end)
end

positionset = true
sliderupdate = false
sliderselfupdate = true

local function positionupdater(position_state)
  awful.spawn.easy_async("playerctl -p spotify position", function (current)
    current = current.gsub(current, "\n", "")
    if current == "" or current == "No players found" or current == "No player could handle this command" then
      position.visible = false
    else
      position.visible = true
      awful.spawn.easy_async("playerctl -p spotify metadata mpris:length", function(length)
        length = length.gsub(length, "\n", "")
        if length == "" or length == "No players found" or length == "No player could handle this command" then
          position.visible = false
        else
          if positionset == true then
            if position_state then
              awful.spawn("playerctl -p spotify position " .. ((position_state * length) / (100000000)))
            end
          end
          if sliderupdate == true then
            sliderselfupdate = false
            sliderupdate = false
            position:get_children_by_id("slider")[1].value = ((current * 100000000) / (length))
          end
        end
      end)
    end
  end)
end

local function volumeupdater()
  awful.spawn.easy_async("playerctl -p spotify volume", function(volume_state)
    volume_state = volume_state.gsub(volume_state, "\n", "")
    if volume_state == "" or volume_state == "No players found" or volume_state == "No player could handle this command" then
      volume.visible = false
      volume_icon.visible = false
    else
      volume.visible = true
      volume_icon.visible = true
      volume:get_children_by_id("slider")[1].value = math.floor(volume_state * 100 + 0.5)
    end
  end)
end

local function shuffler()
  awful.spawn.easy_async("playerctl -p spotify shuffle", function(shuffle_state)
    if shuffle_state:find("On") then
      awful.spawn("playerctl shuffle off")
      shuffle:get_children_by_id("textbox")[1].text = "󰒞"
    elseif shuffle_state:find("Off") then
      awful.spawn("playerctl shuffle on")
      shuffle:get_children_by_id("textbox")[1].text = "󰒝"
    end
  end)
end

local function toggler()
  awful.spawn.easy_async("playerctl -p spotify status", function(toggle_state)
    if toggle_state:find("Playing") then
      awful.spawn("playerctl pause")
      toggle:get_children_by_id("textbox")[1].text = "󰐊"
    elseif toggle_state:find("Paused") then
      awful.spawn("playerctl play")
      toggle:get_children_by_id("textbox")[1].text = "󰏤"
    end
  end)
end

local function looper()
  awful.spawn.easy_async("playerctl -p spotify loop", function(loop_state)
    if loop_state:find("None") then
      awful.spawn("playerctl loop Playlist")
      loop:get_children_by_id("textbox")[1].text = "󰑖"
    elseif loop_state:find("Playlist") then
      awful.spawn("playerctl loop Track")
      loop:get_children_by_id("textbox")[1].text = "󰑘"
    elseif loop_state:find("Track") then
      awful.spawn("playerctl loop None")
      loop:get_children_by_id("textbox")[1].text = "󰑗"
    end
  end)
end

local everythingupdater_timer = gears.timer {
  timeout = 1,
  autostart = true,
  callback = function()
    positionset = false
    sliderupdate = true
    artimageupdater()
    metadataupdater()
    toggleupdater()
    shuffleupdater()
    loopupdater()
    positionupdater()
    volumeupdater()
  end,
}

local controlcenter = awful.popup {
  border_width = 0,
  ontop = true,
  visible = false,
  widget = {
    layout = wibox.layout.fixed.vertical,
    {
      layout = wibox.layout.fixed.horizontal,
      {
        widget = wibox.container.margin,
        top = 4,
        right = 4,
        bottom = 4,
        left = 4,
        {
          widget = wibox.container.background,
          forced_width = 444,
          bg = beautiful.bg_normal,
          { -- Control center body
            layout = wibox.layout.fixed.vertical,
            {
              layout = wibox.layout.fixed.horizontal,
              { -- Systray
                widget = wibox.container.margin,
                top = 4,
                right = 4,
                bottom = 4,
                left = 4,
                {
                  widget = wibox.container.background,
                  forced_width = 198,
                  forced_height = 26,
                  bg = beautiful.bg_minimize,
                  {
                    layout = wibox.layout.fixed.horizontal,
                    wibox.widget.systray,
                  },
                },
              },
              { -- Time/Date
                widget = wibox.container.margin,
                top = 4,
                right = 4,
                bottom = 4,
                left = 4,
                {
                  widget = wibox.container.background,
                  forced_width = 230,
                  forced_height = 26,
                  bg = beautiful.bg_minimize,
                  {
                    layout = wibox.layout.fixed.horizontal,
                    helpers.simplewtch([[sh -c "echo ' '$USER@ && hostname"]], 60),
                  },
                },
              },
            },
            {
              layout = wibox.layout.fixed.horizontal,
              { -- Background image
                layout = wibox.layout.stack,
                backgroundimage,
                profileimage,
              },
              {
                widget = wibox.container.margin,
                top = 4,
                right = 4,
                bottom = 4,
                left = 4,
                { -- Stats
                  widget = wibox.container.background,
                  forced_width = 304,
                  forced_height = 26,
                  bg = beautiful.bg_minimize,
                },
              },
            },
            {
              layout = wibox.layout.fixed.horizontal,
              { -- Music player
                widget = wibox.container.margin,
                top = 4,
                right = 4,
                bottom = 4,
                left = 4,
                { -- Body
                  widget = wibox.container.background,
                  forced_width = 436,
                  forced_height = 148,
                  bg = beautiful.bg_minimize,
                  {
                    layout = wibox.layout.fixed.horizontal,
                    artimage,
                    { -- Slider body
                      layout = wibox.layout.fixed.vertical,
                      {
                        layout = wibox.layout.fixed.horizontal,
                        title,
                      },
                      {
                        layout = wibox.layout.fixed.horizontal,
                        artist,
                      },
                      {
                        layout = wibox.layout.fixed.horizontal,
                        album,
                      },
                      {
                        layout = wibox.layout.fixed.horizontal,
                        position,
                      },
                      {
                        layout = wibox.layout.fixed.horizontal,
                        volume_icon,
                        volume,
                      },
                    },
                    { -- Button body
                      layout = wibox.layout.fixed.vertical,
                      { -- Shuffle
                        widget = wibox.container.margin,
                        top = 8,
                        right = 8,
                        bottom = 4,
                        left = 4,
                        {
                          widget = wibox.container.background,
                          forced_width = 20,
                          forced_height = 20,
                          bg = beautiful.bg_minimize2,
                        },
                      },
                      { -- Prev
                        widget = wibox.container.margin,
                        top = 4,
                        right = 8,
                        bottom = 4,
                        left = 4,
                        {
                          widget = wibox.container.background,
                          forced_width = 20,
                          forced_height = 20,
                          bg = beautiful.bg_minimize2,
                        },
                      },
                      { -- Toggle
                        widget = wibox.container.margin,
                        top = 4,
                        right = 8,
                        bottom = 4,
                        left = 4,
                        {
                          widget = wibox.container.background,
                          forced_width = 20,
                          forced_height = 20,
                          bg = beautiful.bg_minimize2,
                        },
                      },
                      { -- Next
                        widget = wibox.container.margin,
                        top = 4,
                        right = 8,
                        bottom = 4,
                        left = 4,
                        {
                          widget = wibox.container.background,
                          forced_width = 20,
                          forced_height = 20,
                          bg = beautiful.bg_minimize2,
                        },
                      },
                      { -- Loop
                        widget = wibox.container.margin,
                        top = 4,
                        right = 8,
                        bottom = 8,
                        left = 4,
                        {
                          widget = wibox.container.background,
                          forced_width = 20,
                          forced_height = 20,
                          bg = beautiful.bg_minimize2,
                        },
                      },
                    },
                  },
                },
              },
            },
            {
              layout = wibox.layout.fixed.horizontal,
              { -- System volume slider
                widget = wibox.container.margin,
                top = 4,
                right = 4,
                bottom = 4,
                left = 4,
                {
                  widget = wibox.container.background,
                  forced_width = 436,
                  forced_height = 20,
                  bg = beautiful.bg_minimize,
                },
              },
            },
            { -- Hot buttons
              layout = wibox.layout.fixed.horizontal,
              { -- 
                widget = wibox.container.margin,
                top = 4,
                right = 4,
                bottom = 4,
                left = 4,
                {
                  widget = wibox.container.background,
                  forced_width = 66,
                  forced_height = 66,
                  bg = beautiful.bg_minimize,
                },
              },
              { -- 
                widget = wibox.container.margin,
                top = 4,
                right = 4,
                bottom = 4,
                left = 4,
                {
                  widget = wibox.container.background,
                  forced_width = 66,
                  forced_height = 66,
                  bg = beautiful.bg_minimize,
                },
              },
              { -- 
                widget = wibox.container.margin,
                top = 4,
                right = 4,
                bottom = 4,
                left = 4,
                {
                  widget = wibox.container.background,
                  forced_width = 66,
                  forced_height = 66,
                  bg = beautiful.bg_minimize,
                },
              },
              { -- 
                widget = wibox.container.margin,
                top = 4,
                right = 4,
                bottom = 4,
                left = 4,
                {
                  widget = wibox.container.background,
                  forced_width = 66,
                  forced_height = 66,
                  bg = beautiful.bg_minimize,
                },
              },
              { -- 
                widget = wibox.container.margin,
                top = 4,
                right = 4,
                bottom = 4,
                left = 4,
                {
                  widget = wibox.container.background,
                  forced_width = 66,
                  forced_height = 66,
                  bg = beautiful.bg_minimize,
                },
              },
              { -- 
                widget = wibox.container.margin,
                top = 4,
                right = 4,
                bottom = 4,
                left = 4,
                {
                  widget = wibox.container.background,
                  forced_width = 66,
                  forced_height = 66,
                  bg = beautiful.bg_minimize,
                },
              },
            },
          },
        },
      },
      { -- Right pseudoborder
        widget = wibox.container.background,
        forced_width = 3,
        bg = beautiful.border_color_active,
      },
    },
    { -- Bottom pseudoborder
      widget = wibox.container.background,
      forced_height = 3,
      bg = beautiful.border_color_active,
    },
  },
}

shuffle:connect_signal("button::press", function()
  shuffler()
end)

prev:connect_signal("button::press", function()
  awful.spawn("playerctl previous")
  artimageupdater()
  metadataupdater()
  toggleupdater()
  loopupdater()
  positionupdater()
end)

toggle:connect_signal("button::press", function()
  toggler()
end)

next:connect_signal("button::press", function()
  awful.spawn("playerctl next")
  artimageupdater()
  metadataupdater()
  toggleupdater()
  loopupdater()
  positionupdater()
end)

loop:connect_signal("button::press", function()
  looper()
end)

position:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, position_state)
  if sliderselfupdate == true then
    slider.value = position_state
    positionupdater(position_state)
  end
  positionset = true
  sliderupdate = false
  sliderselfupdate = true
end)

volume:get_children_by_id("slider")[1]:connect_signal("property::value", function(slider, volume_state)
  slider.value = volume_state
	awful.spawn("playerctl volume " .. (volume_state/100))
end)

local function signal()
  artimageupdater()
  metadataupdater()
  toggleupdater()
  shuffleupdater()
  loopupdater()
  positionupdater()
  volumeupdater()
  controlcenter.visible = not controlcenter.visible
  controlcenter.screen = awful.screen.focused()
end

click_to_hide.popup(controlcenter, nil, true)

return {
  signal = signal,
}
