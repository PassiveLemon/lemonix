require("signal.cpu")

local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")


local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- CPU
--

local cpu = { }

local sep = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = " ",
})

cpu.icon = h.text({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = dpi(2),
    left = 0,
  },
  text = "",
  font = b.sysfont(dpi(15)),
})
cpu.text = h.text({
  margins = {
    left = dpi(3),
  },
  halign = "left",
})
awesome.connect_signal("signal::resource::cpu::data", function(use, _)
  cpu.text:get_children_by_id("textbox")[1].text = use .. "%"
end)

cpu.pill = h.margin({
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
      cpu.icon,
      cpu.text,
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

return cpu

