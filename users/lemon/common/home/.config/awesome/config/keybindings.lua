local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")
local hotkeys_popup = require("awful.hotkeys_popup")

local user = require("config.user")
local bling = require("libraries.bling")

local dpi = b.xresources.apply_dpi

--
-- Keybindings
--

local super = user.super

-- TODO: Probably should move this out of keybindings.lua
local app_launcher = bling.widget.app_launcher({
  terminal = user.terminal,
  type = "popup",
  border_color = b.border_color_active,
  background = b.bg_primary,

  prompt_height = dpi(30),
  prompt_margins = dpi(0),
  prompt_paddings = {
    top = dpi(8),
    right = dpi(8),
    bottom = b.margins,
    left = dpi(8),
  },
  prompt_color = b.bg_primary,
  prompt_text_halign = "left",
  prompt_text_valign = "center",
  prompt_icon = "",
  prompt_font = b.sysfont(dpi(10)),
  prompt_text_color = b.fg_primary,
  prompt_cursor_color = b.fg_primary,

  apps_per_row = 15,
  apps_per_column = 1,
  apps_margin = {
    top = b.margins,
    right = dpi(8),
    bottom = dpi(8),
    left = dpi(8),
  },
  apps_spacing = dpi(8),

  app_width = dpi(290),
  app_height = dpi(24),
  app_shape = gears.shape.rounded_bar,
  app_normal_color = b.bg_secondary,
  app_normal_hover_color = b.bg_minimize,
  app_selected_color = b.bg_minimize,
  app_selected_hover_color = b.bg_focus,
  app_content_padding = dpi(2),
  app_content_spacing = dpi(4),
  app_show_icon = true,
  app_icon_halign = "left",
  app_icon_width = dpi(24),
  app_icon_height = dpi(24),
  app_show_name = true,
  app_name_layout = wibox.layout.fixed.horizontal,
  app_name_generic_name_spacing = dpi(0),
  app_name_halign = "left",
  app_name_font = b.sysfont(dpi(10)),
  app_name_normal_color = b.fg_primary,
  app_name_selected_color = b.fg_focus,
  app_show_generic_name = false,
})

awful.keyboard.append_global_keybindings({
  awful.key({ super, "Control" }, "r", awesome.restart,
  { description = "|| reload awesome", group = "awesome" }),

  -- Launcher
  awful.key({ super }, "Return", function() awful.spawn(user.terminal) end,
  { description = "|| open a terminal", group = "launcher" }),

  awful.key({ super }, "space", function() app_launcher:toggle() end,
  { description = "|| run app launcher", group = "launcher" }),

  awful.key({ super }, "c", function() awesome.emit_signal("ui::control::toggle") end,
  { description = "|| run control panel", group = "launcher" }),

  awful.key({ super }, "x", function() awesome.emit_signal("ui::control::clear") end,
  { description = "|| clear control panel", group = "launcher" }),

  awful.key({ super }, "z", function() awesome.emit_signal("ui::resource::toggle") end,
  { description = "|| run resource monitor", group = "launcher" }),

  awful.key({ super }, "l", function() awesome.emit_signal('ui::lock::toggle') end,
  { description = "|| lock display", group = "launcher" }),

  -- Control
  awful.key({ }, "XF86MonBrightnessUp", function() awesome.emit_signal("signal::peripheral::brightness::increase") end,
  { description = "|| increase brightness", group = "control" }),

  awful.key({ }, "XF86MonBrightnessDown", function() awesome.emit_signal("signal::peripheral::brightness::decrease") end,
  { description = "|| decrease brightness", group = "control" }),

  awful.key({ }, "XF86AudioMute", function() awesome.emit_signal("signal::peripheral::volume::mute") end,
  { description = "|| toggle mute", group = "control" }),

  awful.key({ }, "XF86AudioRaiseVolume", function() awesome.emit_signal("signal::peripheral::volume::increase") end,
  { description = "|| increase volume", group = "control" }),

  awful.key({ }, "XF86AudioLowerVolume", function() awesome.emit_signal("signal::peripheral::volume::decrease") end,
  { description = "|| decrease volume", group = "control" }),

  awful.key({ }, "XF86AudioPrev", function() awesome.emit_signal("signal::mpris::previous") end,
  { description = "|| previous media", group = "control" }),

  awful.key({ }, "XF86AudioPlay", function() awesome.emit_signal("signal::mpris::toggle") end,
  { description = "|| toggle play", group = "control" }),

  awful.key({ }, "XF86AudioNext", function() awesome.emit_signal("signal::mpris::next") end,
  { description = "|| next media", group = "control" }),

  -- Utility
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

  -- Misc
  awful.key({ }, "Caps_Lock", function() awesome.emit_signal("signal::peripheral::caps::update") end,
  { description = "|| caps lock", group = "misc" }),

  -- Client
  awful.keyboard.append_client_keybindings({
    awful.key({ super }, "Escape", function(c) c:kill() end,
    { description = "|| close", group = "client" }),

    awful.key({ super }, "Tab",  function() client.focus = nil end,
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

client.connect_signal("request::default_mousebindings", function()
  awful.mouse.append_client_mousebindings({
    awful.button({ }, 1, function(c)
      c:activate({ context = "mouse_click" })
    end),
    awful.button({ super }, 1, function(c)
      c:activate({ context = "mouse_click", action = "mouse_move" })
    end),
    awful.button({ super }, 3, function(c)
      if c.floating then
        c:activate({ context = "mouse_click", action = "mouse_resize" })
      end
    end)
  })
end)

