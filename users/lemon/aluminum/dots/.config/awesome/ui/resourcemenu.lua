local awful = require("awful")
local gears = require("gears")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Resource monitor menu
--

local space = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = " ",
})

local cpu_text = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = "CPU",
})
local cpu_use = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local cpu_temp = h.text({
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

local mem_text = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = "Memory",
})
local mem_use = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local mem_use_perc = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local cache_use = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  halign = "left",
})
local cache_use_perc = h.text({
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

local network_text = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = "Network",
})
local network_total = h.text({
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

local uptime_text = h.text({
  margins = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
  text = "Uptime",
})
local uptime_time = h.text({
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
end)

local main = awful.popup {
  placement = awful.placement.centered,
  border_width = 3,
  border_color = b.border_color_active,
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
