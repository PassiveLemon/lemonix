local awful = require("awful")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Resource monitor
--

local space = h.text({
  text = " ",
})

local cpu_text = h.text({
  text = "CPU",
})
local cpu_use = h.text({
  halign = "left",
})
local cpu_temp = h.text({
  halign = "left",
})
awesome.connect_signal("signal::cpu::data", function(use, temp)
	cpu_use:get_children_by_id("textbox")[1].text = "Usage: " .. use .. "%"
  cpu_temp:get_children_by_id("textbox")[1].text = temp .. "C"
end)

local gpu_text = h.text({
  text = "GPU",
})
local gpu_use = h.text({
  halign = "left",
})
local gpu_temp = h.text({
  halign = "left",
})
local gpu_mem = h.text({
  halign = "left",
})
awesome.connect_signal("signal::gpu::data", function(use, temp, mem)
	gpu_use:get_children_by_id("textbox")[1].text = "Usage: " .. use .. "%"
  gpu_temp:get_children_by_id("textbox")[1].text = temp .. "C"
  gpu_mem:get_children_by_id("textbox")[1].text = "Memory: " .. mem
end)

local mem_text = h.text({
  text = "Memory",
})
local mem_use = h.text({
  halign = "left",
})
local mem_use_perc = h.text({
  halign = "left",
})
local cache_use = h.text({
  halign = "left",
})
local cache_use_perc = h.text({
  halign = "left",
})
awesome.connect_signal("signal::memory::data", function(use, use_perc, cache, cache_perc)
	mem_use:get_children_by_id("textbox")[1].text = "Used: " .. use .. " GB"
  mem_use_perc:get_children_by_id("textbox")[1].text = use_perc .. "%"
  cache_use:get_children_by_id("textbox")[1].text = "Cache: " .. cache .. " GB"
  cache_use_perc:get_children_by_id("textbox")[1].text = cache_perc .. "%"
end)

local strg_text = h.text({
  text = "Storage",
})
local strg_free_nvme0 = h.text({
  halign = "left",
})
awesome.connect_signal("signal::storage::data", function(nvme0)
	strg_free_nvme0:get_children_by_id("textbox")[1].text = "NVME0: " .. nvme0
end)

local network_text = h.text({
  text = "Network",
})
local network_total = h.text({
  halign = "left",
})
awesome.connect_signal("signal::network::data", function(total)
	network_total:get_children_by_id("textbox")[1].text = "Dn/Up: " .. total
end)

local uptime_text = h.text({
  text = "Uptime",
})
local uptime_time = h.text({
  halign = "left",
})
awesome.connect_signal("signal::other::data", function(uptime, headset)
	uptime_time:get_children_by_id("textbox")[1].text = "" .. uptime
end)

local main = awful.popup({
  placement = awful.placement.centered,
  border_width = 3,
  border_color = b.border_color_active,
  ontop = true,
  visible = false,
  type = "dock",
  widget = {
    layout = wibox.layout.align.horizontal,
    {
      widget = wibox.container.margin,
      margins = { top = 4, right = 2, bottom = 3, left = 6 },
      forced_width = 210,
      {
        layout = wibox.layout.fixed.vertical,
        cpu_text,
        {
          layout = wibox.layout.fixed.horizontal,
          cpu_use,
          space,
          cpu_temp,
        },
        space,
        gpu_text,
        {
          layout = wibox.layout.fixed.horizontal,
          gpu_use,
          space,
          gpu_temp,
        },
        gpu_mem,
      },
    },
    {
      widget = wibox.container.margin,
      margins = { top = 4, right = 2, bottom = 3, left = 2 },
      forced_width = 200,
      {
        layout = wibox.layout.fixed.vertical,
        mem_text,
        {
          layout = wibox.layout.fixed.horizontal,
          mem_use,
          space,
          mem_use_perc,
        },
        {
          layout = wibox.layout.fixed.horizontal,
          cache_use,
          space,
          cache_use_perc,
        },
        space,
        strg_text,
        strg_free_nvme0,
        strg_free_nvme1,
        strg_free_sda,
        strg_free_sdb,
      },
    },
    {
      widget = wibox.container.margin,
      margins = { top = 4, right = 6, bottom = 3, left = 2 },
      forced_width = 155,
      {
        layout = wibox.layout.fixed.vertical,
        network_text,
        network_total,
        space,
        uptime_text,
        uptime_time,
      },
    },
  },
})

awesome.connect_signal("ui::resource::toggle", function()
  main.screen = awful.screen.focused()
  main.visible = not main.visible
end)

click_to_hide.popup(main, nil, true)
