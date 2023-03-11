local gears = require("gears")
local awful = require("awful")

local keybindings = {}

-- CUSTOM
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
    awful.key {
        modifiers   = { modkey, "Control", "Shift" },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
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
    }
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
        awful.key({ modkey,           }, "f",
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            {description = "toggle fullscreen", group = "client"}),
        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
                {description = "toggle floating", group = "client"}),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
                {description = "move to master", group = "client"}),
        awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
                {description = "move to screen", group = "client"}),
        awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
                {description = "toggle keep on top", group = "client"}),
        awful.key({ modkey,           }, "n",
            function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end ,
            {description = "minimize", group = "client"}),
        awful.key({ modkey,           }, "m",
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

return keybindings