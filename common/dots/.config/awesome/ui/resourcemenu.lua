local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("helpers")

local click_to_hide = require("modules.click_to_hide")

require("modules.watches.cpu")
require("modules.watches.gpu")
require("modules.watches.memory")
require("modules.watches.storage")
require("modules.watches.network")
require("modules.watches.other")

--
-- Resource monitor menu
--

local space = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = " ",
})

local cpu_text = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = "CPU",
})
local cpu_use = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local cpu_temp = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
awesome.connect_signal("signal::cpu", function(use, temp)
	cpu_use:get_children_by_id("textbox")[1].text = "Usage: " .. use .. "%"
  cpu_temp:get_children_by_id("textbox")[1].text = temp .. "C"
end)

local gpu_text = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = "GPU",
})
local gpu_use = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local gpu_temp = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local gpu_mem = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
awesome.connect_signal("signal::gpu", function(use, temp, mem)
	gpu_use:get_children_by_id("textbox")[1].text = "Usage: " .. use .. "%"
  gpu_temp:get_children_by_id("textbox")[1].text = temp .. "C"
  gpu_mem:get_children_by_id("textbox")[1].text = "Memory: " .. mem
end)

local mem_text = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = "Memory",
})
local mem_use = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local mem_use_perc = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local cache_use = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local cache_use_perc = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
awesome.connect_signal("signal::memory", function(use, use_perc, cache, cache_perc)
	mem_use:get_children_by_id("textbox")[1].text = "Used: " .. use .. " GiB"
  mem_use_perc:get_children_by_id("textbox")[1].text = use_perc .. "%"
  cache_use:get_children_by_id("textbox")[1].text = "Cache: " .. cache .. " GiB"
  cache_use_perc:get_children_by_id("textbox")[1].text = cache_perc .. "%"
end)

local strg_text = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = "Storage",
})
local strg_free_nvme0 = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local strg_free_nvme1 = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local strg_free_sda = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local strg_free_sdb = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
awesome.connect_signal("signal::storage", function(nvme0, nvme1, sda, sdb)
	strg_free_nvme0:get_children_by_id("textbox")[1].text = "NVME0: " .. nvme0
  strg_free_nvme1:get_children_by_id("textbox")[1].text = "NVME1: " .. nvme1
  strg_free_sda:get_children_by_id("textbox")[1].text = "SDA: " .. sda
  strg_free_sdb:get_children_by_id("textbox")[1].text = "SDB: " .. sdb
end)

local network_text = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = "Network",
})
local network_total = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
awesome.connect_signal("signal::network", function(total)
	network_total:get_children_by_id("textbox")[1].text = "Dn/Up: " .. total
end)

local uptime_text = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = "Uptime",
})
local uptime_time = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local devices_text = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = "Devices",
})
local headset_bat = helpers.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
awesome.connect_signal("signal::other", function(uptime, headset)
	uptime_time:get_children_by_id("textbox")[1].text = uptime .. " "
  headset_bat:get_children_by_id("textbox")[1].text = "HS BAT: " .. headset
end)

local main = awful.popup {
  placement = awful.placement.centered,
  border_width = 3,
  border_color = beautiful.border_color_active,
  ontop = true,
  visible = false,
  widget = {
    layout = wibox.layout.align.horizontal,
    {
      forced_width = 210,
      margins = { top = 4, right = 2, bottom = 3, left = 6, },
      widget = wibox.container.margin,
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
      forced_width = 200,
      margins = { top = 4, right = 2, bottom = 3, left = 2, },
      widget = wibox.container.margin,
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
      forced_width = 155,
      margins = { top = 4, right = 6, bottom = 3, left = 2, },
      widget = wibox.container.margin,
      {
        layout = wibox.layout.fixed.vertical,
        network_text,
        network_total,
        space,
        uptime_text,
        uptime_time,
        space,
        devices_text,
        headset_bat,
      },
    },
  },
}

local function signal()
  main.visible = not main.visible
  main.screen = awful.screen.focused()
end

click_to_hide.popup(main, nil, true)

return { signal = signal }
