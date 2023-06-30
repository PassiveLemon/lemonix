local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")

local mediamenu = require("ui.mediamenu")
local powermenu = require("ui.powermenu")
local resourcemenu = require("ui.resourcemenu")

--
-- Keybindings
--

modkey = "Mod4"

awful.keyboard.append_global_keybindings {
  awful.key({ modkey, "Control", }, "r", awesome.restart,
  { description = "reload awesome", group = "awesome", }),

  awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
  { description = "open a terminal", group = "launcher", }),

  awful.key({ modkey, }, "space", function() awful.spawn("rofi -show drun -theme /home/lemon/.config/rofi/lemon.rasi -show-icons") end,
  { description = "run rofi", group = "launcher", }),

  awful.key({ modkey, }, "x", function() resourcemenu.signal() end,
  { description = "run resourcemenu", group = "launcher", }),

  awful.key({ modkey, }, "v", function() powermenu.signal() end,
  { description = "run powermenu", group = "launcher", }),

  awful.key({ modkey, }, "c", function() mediamenu.signal() end,
  { description = "run mediamenu", group = "launcher", }),

  awful.key({ modkey, }, "s", hotkeys_popup.show_help,
  { description = "show help", group = "utility", }),

  awful.key({ }, "Print", function() awful.spawn("flameshot gui") end,
  { description = "flameshot", group = "utility", }),

  awful.key({ }, "XF86AudioRaiseVolume", function() awful.spawn("pamixer -i 1") end,
  { description = "increase volume", group = "media", }),

  awful.key({ }, "XF86AudioLowerVolume", function() awful.spawn("pamixer -d 1") end,
  { description = "decrease volume", group = "media", }),

  awful.key({ }, "XF86AudioMute", function() awful.spawn("pamixer -t") end,
  { description = "toggle mute", group = "media", }),

  awful.key({ }, "XF86AudioPrev", function()
    awful.spawn("playerctl previous")
    mediamenu.metadataupdater()
    mediamenu.loopupdater()
    mediamenu.positionupdater()
  end,
  { description = "previous media", group = "media", }),

  awful.key({ }, "XF86AudioPlay", function()
    awful.spawn("playerctl play-pause")
    mediamenu.metadataupdater()
    mediamenu.loopupdater()
    mediamenu.positionupdater()
  end,
  { description = "toggle play", group = "media", }),

  awful.key({ }, "XF86AudioNext", function()
    awful.spawn("playerctl next")
    mediamenu.metadataupdater()
    mediamenu.loopupdater()
    mediamenu.positionupdater()
  end,
  { description = "next media", group = "media", }),

  awful.key {
    modifiers   = { modkey, },
    keygroup    = "numpad",
    description = "select workspace",
    group       = "tag",
    on_press    = function(index)
      local t = awful.screen.focused().selected_tag
      if t then
        t.layout = t.layouts[index] or t.layout
      end
  end,
  },

  awful.key {
    modifiers   = { modkey, },
    keygroup    = "numrow",
    description = "switch to tag",
    group       = "tag",
    on_press    = function(index)
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then
        tag:view_only()
      end
    end,
  },

  awful.key {
    modifiers   = { modkey, "Control", },
    keygroup    = "numrow",
    description = "toggle tag",
    group       = "tag",
    on_press    = function(index)
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end,
  },

  awful.key {
    modifiers = { modkey, "Shift", },
    keygroup    = "numrow",
    description = "move focused client to tag",
    group       = "tag",
    on_press    = function(index)
      if client.focus then  
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end,
  },

  awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
  { description = "jump to urgent client", group = "client", }),
}

awful.keyboard.append_client_keybindings {
  awful.key({ modkey, }, "Escape", function(c) c:kill() end,
  { description = "close", group = "client", }),

  awful.key({ modkey, }, "m",
    function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end,
  { description = "toggle fullscreen", group = "client", }),

  awful.key({ modkey, }, "f",  awful.client.floating.toggle,
  { description = "toggle floating", group = "client", }),

  awful.key({ modkey, }, "n", function(c) c.minimized = true end,
  { description = "minimize", group = "client", }),
}

--
-- Mouse keybinds
--

client.connect_signal( "request::default_mousebindings", function()
  awful.mouse.append_client_mousebindings {
    awful.button({ }, 1, function(c)
      c:activate { context = "mouse_click", }
    end),
    awful.button({ modkey }, 1, function(c)
      c:activate { context = "mouse_click", action = "mouse_move", }
    end),
    awful.button({ modkey }, 3, function(c)
      c:activate { context = "mouse_click", action = "mouse_resize", }
    end),
  }
end)

--
-- Other
--

awful.keyboard.append_client_keybindings {
  awful.key({}, "sudo nixos-rebuild switch", function() end,
  { description = "Rebuild nixos", group = "other", }),
  awful.key({}, "home-manager switch --flake ~/Documents/GitHub/lemonix/#lemon@silver", function() end,
  { description = "Rebuild home-manager", group = "other", }),
}
