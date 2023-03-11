pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
require("awful.hotkeys_popup.keys")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

---- Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
  naughty.notification {
    urgency = "critical",
    title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
    message = message
  }
end)

beautiful.init("/home/lemon/.config/awesome/config/theme.lua")

terminal = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

menubar.utils.terminal = terminal

modkey = "Mod4"

mymainmenu = awful.menu({items = {
  { "awesome", myawesomemenu, beautiful.awesome_icon },
  { "open terminal", terminal }
}})
mylauncher = awful.widget.launcher({image = beautiful.awesome_icon, menu = mymainmenu })


---- Tag layout
tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts({
--        awful.layout.suit.floating,
--        awful.layout.suit.tile,
--        awful.layout.suit.tile.left,
--        awful.layout.suit.tile.bottom,
--        awful.layout.suit.tile.top,
--        awful.layout.suit.fair,
--        awful.layout.suit.fair.horizontal,
--        awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
--        awful.layout.suit.max,
--        awful.layout.suit.max.fullscreen,
--        awful.layout.suit.magnifier,
--        awful.layout.suit.corner.nw,
  })
end)

--
-- Wallpaper
--

screen.connect_signal("request::wallpaper", function(s)
  awful.wallpaper {
    screen = s,
    widget = {
      {
        image     = beautiful.wallpaper,
        upscale   = true,
        downscale = true,
        widget    = wibox.widget.imagebox,
      },
      valign = "center",
      halign = "center",
      tiled  = false,
      widget = wibox.container.tile,
    }
  }
end)

--
-- Wibar
--

local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")

mytextclock = wibox.widget.textclock(" %a %b %d, %I:%M ")

screen.connect_signal("request::desktop_decoration", function(s)
  awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 " }, s, awful.layout.layouts[1])

  -- Create a layoutbox widget
  s.mylayoutbox = awful.widget.layoutbox {
    screen  = s,
  }

  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
  }

  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist {
    screen  = s,
    filter  = awful.widget.tasklist.filter.currenttags,
  }

  -- Create the wibox
  s.mywibox = awful.wibar({
    position = "top",
    screen   = s,
    height   = 25
  })

  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left
      layout = wibox.layout.fixed.horizontal,
      s.mytaglist,
      cpu_widget({
        width = 20,
      }),
      ram_widget({
        color_used = "#f35252",
        color_buf = "#f3d052",
      }),
      --volume_widget(),
    },
    s.mytasklist, -- Middle
    { -- Right
      layout = wibox.layout.fixed.horizontal,
      wibox.widget.systray({
        forced_height = 6,
        forced_width = 6,
      }),
      mytextclock,
      s.mylayoutbox,
    },
  }
end)

--
-- Keybindings
--

awful.keyboard.append_global_keybindings({
  awful.key({ modkey, "Control" }, "r", awesome.restart,
  {description = "reload awesome", group = "awesome"}),

  awful.key({ modkey, }, "Return", function () awful.spawn(terminal) end,
  {description = "open a terminal", group = "launcher"}),

  awful.key({ modkey, }, "space", function () awful.spawn( "rofi -show drun -theme /home/lemon/.config/rofi/lemon.rasi -show-icons" ) end,
  { description = "run rofi", group = "launcher" }),

  awful.key({ modkey, }, "p", function () awful.spawn( "sh /home/lemon/.config/rofi/powermenu.sh" ) end,
  { description = "run powermenu", group = "launcher" }),

  awful.key({ modkey, }, "s", hotkeys_popup.show_help,
  {description="show help", group="utility"}),

  awful.key({ modkey, }, "Print", function () awful.spawn( "flameshot gui" ) end,
  {description="flameshot", group="utility"}),

  awful.key({ }, "XF86AudioRaiseVolume", function () awful.spawn( "pamixer -i 1" ) end,
  {description="increase volume", group="media"}),

  awful.key({ }, "XF86AudioLowerVolume", function () awful.spawn( "pamixer -d 1" ) end,
  {description="decrease volume", group="media"}),

  awful.key({ }, "XF86AudioMute", function () awful.spawn( "pamixer -t" ) end,
  {description="toggle mute", group="media"}),

  awful.key({ }, "XF86AudioPlay", function () awful.spawn( "playerctl play-pause" ) end,
  {description="toggle play", group="media"}),

  awful.key({ }, "XF86AudioNext", function () awful.spawn( "playerctl next" ) end,
  {description="next media", group="media"}),

  awful.key({ }, "XF86AudioPrev", function () awful.spawn( "playerctl previous" ) end,
  {description="previous media", group="media"}),
})

awful.keyboard.append_client_keybindings({
  awful.key({ modkey, }, "Escape", function (c) c:kill() end,
  {description = "close", group = "client"}),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
  awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx( 1) end,
  {description = "swap with next client by index", group = "client"}),

  awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx( -1) end,
  {description = "swap with previous client by index", group = "client"}),

  awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
  {description = "jump to urgent client", group = "client"}),

  awful.key({ modkey, }, "l", function () awful.tag.incmwfact( 0.05) end,
  {description = "increase master width factor", group = "layout"}),

  awful.key({ modkey, }, "h", function () awful.tag.incmwfact( -0.05) end,
  {description = "decrease master width factor", group = "layout"}),

  awful.key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster( 1, nil, true) end,
  {description = "increase the number of master clients", group = "layout"}),

  awful.key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster( -1, nil, true) end,
  {description = "decrease the number of master clients", group = "layout"}),

  awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1, nil, true) end,
  {description = "increase the number of columns", group = "layout"}),

  awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol( -1, nil, true) end,
  {description = "decrease the number of columns", group = "layout"}),

  awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc( -1) end,
  {description = "select previous", group = "layout"}),
})

awful.keyboard.append_global_keybindings({
  awful.key {
    modifiers   = { modkey },
    keygroup    = "numpad",
    description = "select layout directly",
    group       = "layout",
    on_press    = function (index)
      local t = awful.screen.focused().selected_tag
      if t then
        t.layout = t.layouts[index] or t.layout
      end
  end,
  },
  awful.key {
    modifiers   = { modkey },
    keygroup    = "numrow",
    description = "only view tag",
    group       = "tag",
    on_press    = function (index)
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then
        tag:view_only()
      end
    end,
  },
  awful.key {
    modifiers   = { modkey, "Control" },
    keygroup    = "numrow",
    description = "toggle tag",
    group       = "tag",
    on_press    = function (index)
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end,
  },
  awful.key {
    modifiers = { modkey, "Shift" },
    keygroup    = "numrow",
    description = "move focused client to tag",
    group       = "tag",
    on_press    = function (index)
      if client.focus then  
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end,
  },
})

client.connect_signal("request::default_mousebindings", function()
  awful.mouse.append_client_mousebindings({
    awful.button({ }, 1, function (c)
      c:activate { context = "mouse_click" }
    end),
    awful.button({ modkey }, 1, function (c)
      c:activate { context = "mouse_click", action = "mouse_move"  }
    end),
    awful.button({ modkey }, 3, function (c)
      c:activate { context = "mouse_click", action = "mouse_resize"}
    end),
  })
end)

client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings({
    awful.key({ modkey, }, "f",
      function (c)
          c.fullscreen = not c.fullscreen
          c:raise()
      end,
    {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,
    {description = "toggle floating", group = "client"}),

    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
    {description = "move to master", group = "client"}),

    awful.key({ modkey, }, "o", function (c) c:move_to_screen() end,
    {description = "move to screen", group = "client"}),

    awful.key({ modkey, }, "t", function (c) c.ontop = not c.ontop end,
    {description = "toggle keep on top", group = "client"}),

    awful.key({ modkey, }, "n",
      function (c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
      end ,
    {description = "minimize", group = "client"}),

    awful.key({ modkey, }, "m",
      function (c)
        c.maximized = not c.maximized
        c:raise()
      end ,
    {description = "(un)maximize", group = "client"}),

    awful.key({ modkey, "Control" }, "m",
      function (c)
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
      end ,
    {description = "(un)maximize vertically", group = "client"}),

    awful.key({ modkey, "Shift"   }, "m",
      function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
      end ,
    {description = "(un)maximize horizontally", group = "client"}),
  })
end)

---- Mouse bindings
awful.mouse.append_global_mousebindings({
awful.button({ }, 3, function () mymainmenu:toggle() end),
awful.button({ }, 4, awful.tag.viewprev),
awful.button({ }, 5, awful.tag.viewnext),
})

--
-- Rules
--

-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
  -- All clients will match this rule.
  ruled.client.append_rule {
    id         = "global",
    rule       = { },
    properties = {
      focus     = awful.client.focus.filter,
      raise     = true,
      screen    = awful.screen.preferred,
      placement = awful.placement.no_overlap+awful.placement.no_offscreen
    }
  }
end)

  -- Floating clients.
  ruled.client.append_rule {
    id       = "floating",
    rule_any = {
      instance = { "copyq", "pinentry" },
      class    = {
        "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
        "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
      },
      -- Note that the name property shown in xprop might be set slightly after creation of the client
      -- and the name shown there might not match defined rules here.
      name    = {
        "Event Tester",  -- xev.
      },
      role    = {
        "AlarmWindow",    -- Thunderbird's calendar.
        "ConfigManager",  -- Thunderbird's about:config.
        "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
      }
    },
    properties = { floating = true }
  }

---- Notifications
ruled.notification.connect_signal('request::rules', function()
  -- All notifications will match this rule.
  ruled.notification.append_rule {
    rule       = { },
    properties = {
      screen           = awful.screen.preferred,
      implicit_timeout = 5,
    }
  }
end)

naughty.connect_signal("request::display", function(n)
  naughty.layout.box { notification = n }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  c:activate { context = "mouse_enter", raise = false }
end)