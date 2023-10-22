local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")

local media = require("ui.media")
local power = require("ui.power")
local resource = require("ui.resource")
local crosshair = require("ui.crosshair")
local volume = require("signal.volume")

--
-- Keybindings
--

modkey = "Mod4"

awful.keyboard.append_global_keybindings {
  awful.key({ modkey, "Control", }, "r", awesome.restart,
  { description = "|| reload awesome", group = "awesome", }),

  -- Launcher
  awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
  { description = "|| open a terminal", group = "launcher", }),

  awful.key({ modkey, }, "space", function() awful.spawn("rofi -show drun -theme " .. os.getenv("HOME") .. "/.config/rofi/lemon.rasi -show-icons") end,
  { description = "|| run rofi", group = "launcher", }),

  awful.key({ modkey, }, "t", function() launcher.signal() end,
  { description = "|| run launcher", group = "launcher", }),

  awful.key({ modkey, }, "c", function() media.signal() end,
  { description = "|| run media player", group = "launcher", }),

  awful.key({ modkey, }, "v", function() power.signal() end,
  { description = "|| run powermenu", group = "launcher", }),

  awful.key({ modkey, }, "x", function() resource.signal() end,
  { description = "|| run resource monitor", group = "launcher", }),

  -- Control
  awful.key({ }, "XF86AudioRaiseVolume", function()
    awful.spawn.easy_async("pamixer -i 1", function()
      volume.volume()
    end)
  end,
  { description = "|| increase volume", group = "control", }),

  awful.key({ }, "XF86AudioLowerVolume", function()
    awful.spawn.easy_async("pamixer -d 1", function()
      volume.volume()
    end)
  end,
  { description = "|| decrease volume", group = "control", }),

  awful.key({ }, "XF86AudioMute", function()
    awful.spawn.easy_async("pamixer -t", function()
      volume.volume()
    end)
  end,
  { description = "|| toggle mute", group = "control", }),

  awful.key({ }, "XF86AudioNext", function()
    media.nexter()
  end,
  { description = "|| next media", group = "control", }),

  awful.key({ }, "XF86AudioPrev", function()
    media.previouser()
  end,
  { description = "|| previous media", group = "control", }),

  awful.key({ }, "XF86AudioPlay", function()
    media.toggler()
  end,
  { description = "|| toggle play", group = "control", }),

  -- Utility
  awful.key({ modkey, }, "s", hotkeys_popup.show_help,
  { description = "|| show help", group = "utility", }),

  awful.key({ }, "Print", function() awful.spawn("flameshot gui") end,
  { description = "|| flameshot", group = "utility", }),

  awful.key {
    modifiers   = { modkey, "Mod1" },
    keygroup    = "numrow",
    description = "|| enable crosshair",
    group       = "utility",
    on_press    = function(index)
      crosshair.signal(index)
    end,
  },

  -- Tag
  awful.key {
    modifiers   = { modkey, },
    keygroup    = "numrow",
    description = "|| switch to tag",
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
    description = "|| toggle tag",
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
    description = "|| move focused client to tag",
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

  -- Client
  awful.keyboard.append_client_keybindings {
    awful.key({ modkey, }, "Escape", function(c) c:kill() end,
    { description = "|| close", group = "client", }),

    awful.key({ modkey, }, "f",  awful.client.floating.toggle,
    { description = "|| toggle floating", group = "client", }),

    awful.key({ modkey, }, "n", function(c) c.minimized = true end,
    { description = "|| minimize", group = "client", }),
  
    awful.key({ modkey, }, "m",
      function(c)
          c.fullscreen = not c.fullscreen
          c:raise()
      end,
    { description = "|| toggle fullscreen", group = "client", }),
  },
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

-- These are just for information. They have no binding.
awful.keyboard.append_client_keybindings {
  awful.key({ }, "sudo nixos-rebuild switch", function() end,
  { description = "|| rebuild nixos", group = "other", }),

  awful.key({ }, "home-manager switch --flake ~/Documents/GitHub/lemonix/#lemon@silver", function() end,
  { description = "|| rebuild home-manager", group = "other", }),
}
