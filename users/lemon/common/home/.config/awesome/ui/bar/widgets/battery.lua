--require("signal.battery")
require("signal.power")

local b = require("beautiful")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Battery
--

local battery = { }

local sep = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = " ",
})

battery.icon = h.text({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = dpi(2),
    left = 0,
  },
  text = "󰁹",
  font = b.sysfont(dpi(10)),
})
battery.text = h.text({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = 0,
    left = dpi(3),
  },
  halign = "left",
})
battery.etr = h.text({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = 0,
    left = dpi(3),
  },
  halign = "left",
})
local battery_icons_lookup = {
  [9] = "󰁹",
  [8] = "󰂂",
  [7] = "󰂁",
  [6] = "󰂀",
  [5] = "󰁿",
  [4] = "󰁾",
  [3] = "󰁽",
  [2] = "󰁼",
  [1] = "󰁻",
  [0] = "󰁺",
}
awesome.connect_signal("signal::power", function(ac, perc, time)
  battery.text:get_children_by_id("textbox")[1].text = perc .. "%"
  if not ac then
    battery.icon:get_children_by_id("textbox")[1].text = battery_icons_lookup[math.floor(perc / 10)]
    battery.etr.visible = true
    local _etr = h.round((time / 3600), 1)
    if _etr > 1 then
      battery.etr:get_children_by_id("textbox")[1].text = _etr .. " hours"
    else
      battery.etr:get_children_by_id("textbox")[1].text = _etr .. " minutes"
    end
  else
    battery.icon:get_children_by_id("textbox")[1].text = "󰂄"
    battery.etr.visible = false
  end
end)

battery.pill = h.margin({
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
      battery.icon,
      battery.text,
      battery.etr,
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

return battery

