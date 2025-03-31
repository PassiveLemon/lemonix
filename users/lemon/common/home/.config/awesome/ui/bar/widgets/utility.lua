require("signal.caps")
require("signal.volume")

local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Utility (Volume & Caps)
--

local utility = { }

local sep = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = " ",
})

utility.volume_icon = h.button({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = 0,
    left = 0,
  },
  text = "󰖀",
  no_color = true,
  button_press = function()
    awful.spawn.easy_async("pamixer -t", function()
      awesome.emit_signal("signal::peripheral::volume::update")
    end)
  end
})
utility.volume_text = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
awesome.connect_signal("signal::peripheral::volume::value", function(value)
  if value == -1 then
    utility.volume_icon:get_children_by_id("textbox")[1].text = "󰝟"
    utility.volume_icon:get_children_by_id("textbox")[1].font = b.sysfont(dpi(17))
    -- utility.volume_text:get_children_by_id("textbox")[1].text = "Muted"
  elseif value < 33 then
    utility.volume_icon:get_children_by_id("textbox")[1].text = "󰕿"
    utility.volume_icon:get_children_by_id("textbox")[1].font = b.sysfont(dpi(9))
    -- utility.volume_text:get_children_by_id("textbox")[1].text = tostring(value)
  elseif value < 67 then
    utility.volume_icon:get_children_by_id("textbox")[1].text = "󰖀"
    utility.volume_icon:get_children_by_id("textbox")[1].font = b.sysfont(dpi(13))
    -- utility.volume_text:get_children_by_id("textbox")[1].text = tostring(value)
  else
    utility.volume_icon:get_children_by_id("textbox")[1].text = "󰕾"
    utility.volume_icon:get_children_by_id("textbox")[1].font = b.sysfont(dpi(15))
    -- utility.volume_text:get_children_by_id("textbox")[1].text = tostring(value)
  end
end)

utility.caps_icon = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = dpi(3),
  },
  markup = 'A<span underline="single">a</span>',
})
awesome.connect_signal("signal::peripheral::caps::state", function(caps)
  if caps then
    utility.caps_icon:get_children_by_id("textbox")[1].markup = '<span underline="single">A</span>a'
  else
    utility.caps_icon:get_children_by_id("textbox")[1].markup = 'A<span underline="single">a</span>'
  end
end)

utility.pill = h.margin({
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
      utility.volume_icon,
      utility.caps_icon,
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

return utility

