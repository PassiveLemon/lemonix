require("signal.brightness")

local awful = require("awful")
local b = require("beautiful")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Brightness
--

local brightness = { }

local sep = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = " ",
})

brightness.icon = h.button({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = 0,
    left = 0,
  },
  text = "󰌵",
  no_color = true,
  button_press = function()
    awesome.emit_signal("signal::peripheral::brightness::update")
    awful.spawn.easy_async("systemctl is-active --quiet --user clight", function(_, _, _, code)
      if code == 0 then
        awful.spawn("systemctl --user stop clight")
      else
        awful.spawn("systemctl --user restart clight")
      end
    end)
  end,
})
brightness.text = h.text({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = 0,
    left = dpi(3),
  },
  halign = "left",
})
awesome.connect_signal("signal::peripheral::brightness::value", function(cur, max)
  brightness.text:get_children_by_id("textbox")[1].text = h.round(((cur / max) * 100), 0) .. "%"
  awful.spawn.easy_async("systemctl is-active --quiet --user clight", function(_, _, _, code)
    if code == 0 then
      brightness.icon:get_children_by_id("textbox")[1].text = "󰌵"
    else
      brightness.icon:get_children_by_id("textbox")[1].text = "󱠂"
    end
  end)
end)

brightness.pill = h.margin({
  widget = wibox.container.place,
  valign = "center",
  halign = "center",
  forced_height = dpi(24),
  {
    widget = wibox.container.background,
    bg = b.bg_secondary,
    shape = gears.shape.rounded_bar,
    forced_height = dpi(24),
    {
      layout = wibox.layout.fixed.horizontal,
      sep,
      brightness.icon,
      brightness.text,
      sep,
    },
  },
},
{
  margins = {
    top = 0,
    right = dpi(2),
    bottom = 0,
    left = dpi(2),
  },
})

return brightness

