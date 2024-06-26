local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")
local wibox = require("wibox")
local hotkeys_popup = require("awful.hotkeys_popup")

local h = require("helpers")

local bling = require("libraries.bling")
local h = require("helpers")

local bling = require("libraries.bling")

--
-- Keybindings
--

local app_launcher = bling.widget.app_launcher({
  terminal = "tym",
  border_color = b.border_color_active,
  background = b.ui_main_bg,

  prompt_height = 30,
  prompt_margins = 0,
  prompt_paddings = {
    top = 8,
    right = 8,
    bottom = 4,
    left = 8,
  },
  prompt_color = b.ui_main_bg,
  prompt_text_halign = "left",
  prompt_text_valign = "center",
  prompt_icon = "",
  prompt_font = b.sysfont(10),
  prompt_text_color = b.ui_main_fg,
  prompt_cursor_color = b.ui_main_fg,

  apps_per_row = 15,
  apps_per_column = 1,
  apps_margin = {
    top = 4,
    right = 8,
    bottom = 8,
    left = 8,
  },
  apps_spacing = 8,

  app_width = 290,
  app_height = 24,
  app_shape = gears.shape.rounded_bar,
  app_normal_color = b.ui_button_bg,
  app_normal_hover_color = b.bg_minimize,
  app_selected_color = b.bg_minimize,
  app_selected_hover_color = b.bg_focus,
  app_content_padding = 1,
  app_content_spacing = 0,
  app_show_icon = true,
  app_icon_halign = "left",
  app_icon_width = 24,
  app_icon_height = 24,
  app_show_name = true,
  app_name_layout = wibox.layout.fixed.horizontal,
  app_name_generic_name_spacing = 0,
  app_name_halign = "left",
  app_name_font = b.sysfont(10),
  app_name_normal_color = b.ui_button_fg,
  app_name_selected_color = b.fg_focus,
  app_show_generic_name = false,
})

super = "Mod4" -- Windows key
local app_launcher = bling.widget.app_launcher({
  terminal = "tym",
  border_color = b.border_color_active,
  background = b.ui_main_bg,

  prompt_height = 30,
  prompt_margins = 0,
  prompt_paddings = {
    top = 8,
    right = 8,
    bottom = 4,
    left = 8,
  },
  prompt_color = b.ui_main_bg,
  prompt_text_halign = "left",
  prompt_text_valign = "center",
  prompt_icon = "",
  prompt_font = b.sysfont(10),
  prompt_text_color = b.ui_main_fg,
  prompt_cursor_color = b.ui_main_fg,

  apps_per_row = 15,
  apps_per_column = 1,
  apps_margin = {
    top = 4,
    right = 8,
    bottom = 8,
    left = 8,
  },
  apps_spacing = 8,

  app_width = 290,
  app_height = 24,
  app_shape = gears.shape.rounded_bar,
  app_normal_color = b.ui_button_bg,
  app_normal_hover_color = b.bg_minimize,
  app_selected_color = b.bg_minimize,
  app_selected_hover_color = b.bg_focus,
  app_content_padding = 1,
  app_content_spacing = 0,
  app_show_icon = true,
  app_icon_halign = "left",
  app_icon_width = 24,
  app_icon_height = 24,
  app_show_name = true,
  app_name_layout = wibox.layout.fixed.horizontal,
  app_name_generic_name_spacing = 0,
  app_name_halign = "left",
  app_name_font = b.sysfont(10),
  app_name_normal_color = b.ui_button_fg,
  app_name_selected_color = b.fg_focus,
  app_show_generic_name = false,
})

super = "Mod4" -- Windows key

awful.keyboard.append_global_keybindings({
  awful.key({ super, "Control" }, "r", awesome.restart,
  { description = "|| reload awesome", group = "awesome" }),

  -- Launcher
  awful.key({ super }, "Return", function() awful.spawn(terminal) end,
  { description = "|| open a terminal", group = "launcher" }),

  awful.key({ super }, "space", function() app_launcher:toggle() end,
  { description = "|| run app launcher", group = "launcher" }),

  awful.key({ super }, "c", function() awesome.emit_signal("ui::media::toggle") end,
  { description = "|| run media player", group = "launcher" }),

  awful.key({ super }, "v", function() awesome.emit_signal("ui::power::toggle") end,
  { description = "|| run powermenu", group = "launcher" }),

  -- Control
  awful.key({ }, "XF86MonBrightnessUp", function()
    awful.spawn.easy_async("brightnessctl set 3%+", function()
      awesome.emit_signal("signal::brightness::update")
    end)
  end,
  { description = "|| increase brightness", group = "control" }),

  awful.key({ }, "XF86MonBrightnessDown", function()
    awful.spawn.easy_async("brightnessctl set 3%-", function()
      awesome.emit_signal("signal::brightness::update")
    end)
  end,
  { description = "|| decrease brightness", group = "control" }),

  awful.key({ }, "XF86AudioMute", function()
    awful.spawn.easy_async("pamixer -t", function()
      awesome.emit_signal("signal::volume::update")
    end)
  end,
  { description = "|| toggle mute", group = "control" }),

  awful.key({ }, "XF86AudioLowerVolume", function()
    awful.spawn.easy_async("pamixer -d 1", function()
      awesome.emit_signal("signal::volume::update")
    end)
  end,
  { description = "|| decrease volume", group = "control" }),

  awful.key({ }, "XF86AudioRaiseVolume", function()
    awful.spawn.easy_async("pamixer -i 1", function()
      awesome.emit_signal("signal::volume::update")
    end)
  end,
  { description = "|| increase volume", group = "control" }),

  awful.key({ }, "XF86AudioPrev", function() awesome.emit_signal("signal::playerctl::previous") end,
  { description = "|| previous media", group = "control" }),

  awful.key({ }, "XF86AudioPlay", function() awesome.emit_signal("signal::playerctl::toggle") end,
  { description = "|| toggle play", group = "control" }),

  awful.key({ }, "XF86AudioNext", function() awesome.emit_signal("signal::playerctl::next") end,
  { description = "|| next media", group = "control" }),

  -- Utility
  awful.key({ super }, "s", hotkeys_popup.show_help,
  { description = "|| show help", group = "utility" }),

  awful.key({ }, "Print", function() awful.spawn("flameshot gui") end,
  { description = "|| flameshot", group = "utility" }),

  awful.key({
    modifiers   = { super, "Mod1" },
    keygroup    = "numrow",
    description = "|| enable crosshair",
    group       = "utility",
    on_press    = function(index)
      awesome.emit_signal("ui::crosshair::toggle", index)
    end,
  }),

  -- Tag
  awful.key({
    modifiers   = { super },
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
  }),

  awful.key({
    modifiers   = { super, "Control" },
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
  }),

  awful.key({
    modifiers = { super, "Shift" },
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
  }),

  -- Misc
  awful.key({ }, "Caps_Lock", function() awesome.emit_signal("signal::caps::update") end,
  { description = "|| caps lock", group = "misc" }),

  -- Client
  awful.keyboard.append_client_keybindings({
    awful.key({ super }, "Escape", function(c) c:kill() end,
    { description = "|| close", group = "client" }),

    awful.key({ super }, "Tab",  function() h.unfocus() end,
    { description = "|| unfocus", group = "client" }),

    awful.key({ super }, "f",  awful.client.floating.toggle,
    { description = "|| toggle floating", group = "client" }),

    awful.key({ super }, "n", function(c) c.minimized = true end,
    { description = "|| minimize", group = "client" }),

    awful.key({ super }, "m",
      function(c)
          c.fullscreen = not c.fullscreen
          c:raise()
      end,
    { description = "|| toggle fullscreen", group = "client" }),

    awful.key({ super, "Control" }, "m",
      function (c)
        c.maximized = not c.maximized
        c:raise()
      end,
    { description = "|| toggle maximized", group = "client"}),
  }),
})

--
-- Mouse keybinds
--

client.connect_signal( "request::default_mousebindings", function()
  awful.mouse.append_client_mousebindings({
    awful.button({ }, 1, function(c)
      c:activate({ context = "mouse_click" })
    end),
    awful.button({ super }, 1, function(c)
      c:activate({ context = "mouse_click", action = "mouse_move" })
    end),
    awful.button({ super }, 3, function(c)
      c:activate({ context = "mouse_click", action = "mouse_resize" })
    end),
  })
end)

--
-- Other
--

-- These are just for information. They have no binding.
awful.keyboard.append_client_keybindings({
  awful.key({ }, "sudo nixos-rebuild switch", function() end,
  { description = "|| rebuild nixos", group = "other" }),

  awful.key({ }, "home-manager switch --flake ~/Documents/GitHub/lemonix/#lemon@silver", function() end,
  { description = "|| rebuild home-manager", group = "other" }),
})
