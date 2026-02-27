require("signal.memory")

local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")

local dpi = b.xresources.apply_dpi

--
-- Memory
--

local memory = { }

local sep = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = " ",
})

memory.icon = h.text({
  margins = {
    top = 0,
    right = dpi(3),
    bottom = dpi(2),
    left = 0,
  },
  text = "",
  font = b.sysfont(dpi(15)),
})
memory.text = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = dpi(3),
  },
  halign = "left",
})
awesome.connect_signal("signal::resource::memory::data", function(free_mem_table)
  memory.text:get_children_by_id("textbox")[1].text = h.round(((free_mem_table[2] / free_mem_table[1]) * 100), 0) .. "%"
end)

memory.pill = h.margin({
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
      memory.icon,
      memory.text,
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

return memory

