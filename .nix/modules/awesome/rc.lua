pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local dpi = beautiful.xresources.apply_dpi

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

---- Tag layout
tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts({
    awful.layout.suit.spiral.dwindle,
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
  s.lemonlayoutbox = awful.widget.layoutbox {
    screen  = s,
  }

  -- Create a taglist widget
  s.lemontaglist = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    style = {
      shape = gears.shape.circle,
    },
    buttons = {
      awful.button({ }, 1, function(t) t:view_only() end),
      awful.button({ }, 3, awful.tag.viewtoggle),
      awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
      awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end),
    }
  }

  beautiful.tasklist_disable_task_name = false
  beautiful.tasklist_plain_task_name = true

  s.lemonbar = wibox.widget{
    markup = '|',
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
  }

  s.lemonsep = wibox.widget{
    markup = ' ',
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

  -- Create a tasklist widget
  s.lemontasklist = awful.widget.tasklist {
    screen  = s,
    filter  = awful.widget.tasklist.filter.currenttags,
    buttons = {
      awful.button({ }, 1, function (c)
        c:activate { context = "tasklist", action = "toggle_minimization" }
      end),
      awful.button({ }, 4, function() awful.client.focus.byidx( 1) end),
      awful.button({ }, 5, function() awful.client.focus.byidx(-1) end),
    }
  }

  -- Create the wibox
  s.lemonwibar = awful.wibar({
    position = "top",
    screen   = s,
    height   = 23
  })

  s.lemonwibar:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left
      layout = wibox.layout.fixed.horizontal,
      s.lemontaglist,
      s.lemonbar,
      s.lemonsep,
      cpu_widget({
        width = 20,
        color = "#ffff00",
      }),
      s.lemonsep,
      s.lemonbar,
      ram_widget({
        color_used = "#f35252",
        color_buf = "#f3d052",
      }),
      s.lemonbar,
    },
    s.lemontasklist, -- Center
    { -- Right
      layout = wibox.layout.fixed.horizontal,
      wibox.widget.systray,
      s.lemonbar,
      mytextclock,
      s.lemonlayoutbox,
    },
  }
end)

--
-- Keybindings
--
modkey = "Mod4"

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

  awful.key({ }, "Print", function () awful.spawn( "flameshot gui" ) end,
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
  })
end)

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
      "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
    }
  },
  properties = { floating = true }
}

naughty.connect_signal("request::display", function(n)
  naughty.layout.box { notification = n }
end)

naughty.config.defaults.padding = 2
naughty.config.defaults.ontop = true
naughty.config.defaults.timeout = 3
naughty.config.defaults.icon_size = dpi(32)
naughty.config.defaults.screen = awful.screen.focused()
naughty.config.defaults.border_width = dpi(2)
naughty.config.defaults.border_color = "#535d6c"
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.margin = dpi(5)

---- Notifications
ruled.notification.connect_signal('request::rules', function()
  ruled.notification.append_rule {
    rule       = { urgency = "critical" },
    properties = { bg = "#f3d052", fg = "#abb2bf", implicit_timeout = 0, timeout = 0 }
  }
  ruled.notification.append_rule {
    rule       = { urgency = "normal" },
    properties = { bg = "#282c34", fg = "#abb2bf", implicit_timeout = 3, timeout = 3 }
  }
  ruled.notification.append_rule {
    rule       = { urgency = "low" },
    properties = { bg = "#282c34", fg = "#abb2bf", implicit_timeout = 3, timeout = 3 }
  }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  c:activate { context = "mouse_enter", raise = false }
end)