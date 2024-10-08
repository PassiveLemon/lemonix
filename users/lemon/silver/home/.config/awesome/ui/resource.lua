local awful = require("awful")
local b = require("beautiful")
local wibox = require("wibox")

local h = require("helpers")
local click_to_hide = require("modules.click_to_hide")

local dpi = b.xresources.apply_dpi

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
awesome.connect_signal("signal::resource::cpu::data", function(use, temp)
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
awesome.connect_signal("signal::resource::gpu::data", function(nvidia_smi_table)
	gpu_use:get_children_by_id("textbox")[1].text = "Usage: " .. nvidia_smi_table[1] .. "%"
  gpu_temp:get_children_by_id("textbox")[1].text = nvidia_smi_table[2] .. "C"
  gpu_mem:get_children_by_id("textbox")[1].text = "Memory: " .. h.round((nvidia_smi_table[4] / 1024), 1) .. "/" .. h.round((nvidia_smi_table[3] / 1024), 1) .. " GiB " .. h.round(((nvidia_smi_table[4] / nvidia_smi_table[3]) * 100), 0) .. "%"
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
awesome.connect_signal("signal::resource::memory::data", function(free_mem_table)
	mem_use:get_children_by_id("textbox")[1].text = "Used: " .. free_mem_table[2] .. "/" .. free_mem_table[1] .. " GB"
  mem_use_perc:get_children_by_id("textbox")[1].text = h.round(((free_mem_table[2] / free_mem_table[1]) * 100), 0) .. "%"
  cache_use:get_children_by_id("textbox")[1].text = "Cache: " .. free_mem_table[6] .. "/" .. free_mem_table[1] .. " GB"
  cache_use_perc:get_children_by_id("textbox")[1].text = h.round(((free_mem_table[6] / free_mem_table[1]) * 100), 0) .. "%"
end)

local strg_text = h.text({
  text = "Storage",
})
local strg_drives = h.text({
  halign = "left",
})

local function normalize_data(value, place)
  return h.round((value / 10^place), 0)
end
local function sort_table(t)
  local a = { }
  for k in pairs(t) do
    table.insert(a, k)
  end
  table.sort(a)
  return a
end
awesome.connect_signal("signal::resource::storage::data", function(storage_stats_dict)
  local lined_text = ""
  local sorted = sort_table(storage_stats_dict)
  for _, v in pairs(sorted) do
    lined_text = lined_text .. v .. ": " .. normalize_data(storage_stats_dict[v][3], 6) .. "/"
    .. normalize_data(storage_stats_dict[v][2], 6) .. " GB " .. storage_stats_dict[v][5] .. "\n"
  end
  strg_drives:get_children_by_id("textbox")[1].text = lined_text:gsub("\n%C*$", "")
end)

local network_text = h.text({
  text = "Network",
})
local network_adapters = h.text({
  halign = "left",
})
awesome.connect_signal("signal::resource::network::data", function(network_stats_dict)
  local lined_text = ""
  local sorted = sort_table(network_stats_dict)
  for _, v in pairs(sorted) do
    lined_text = lined_text .. v .. ": " .. normalize_data(network_stats_dict[v][1], 9) .. "/"
    .. normalize_data(network_stats_dict[v][9], 9) .. " GB\n"
  end
  network_adapters:get_children_by_id("textbox")[1].text = lined_text:gsub("\n%C*$", "")
end)

local uptime_text = h.text({
  text = "Uptime",
})
local uptime_time = h.text({
  halign = "left",
})
local function uptime(uptime_days, uptime_hours)
  if (uptime_days > 0) and (uptime_hours > 1) then
    return uptime_days .. " days " .. uptime_hours .. " hours"
  elseif (uptime_days > 0) and (uptime_hours < 1) then
    return uptime_days .. " days"
  else
    return uptime_hours .. " hours"
  end
end
awesome.connect_signal("signal::miscellaneous::uptime", function(uptime_days, uptime_hours)
	uptime_time:get_children_by_id("textbox")[1].text = uptime(uptime_days, uptime_hours)
end)

local devices_text = h.text({
  text = "Devices",
})
local headset_bat = h.text({
  halign = "left",
})
awesome.connect_signal("signal::peripheral::headset", function(headset)
  if headset == -2 then
    headset_bat:get_children_by_id("textbox")[1].text = "HS BAT: Not found"
  elseif headset == -1 then
    headset_bat:get_children_by_id("textbox")[1].text = "HS BAT: Charging"
  else
    headset_bat:get_children_by_id("textbox")[1].text = "HS BAT: " .. headset .. "%"
  end
end)

local main = awful.popup({
  placement = awful.placement.centered,
  border_width = dpi(3),
  border_color = b.border_color_active,
  ontop = true,
  visible = false,
  type = "popup_menu",
  widget = {
    layout = wibox.layout.align.horizontal,
    {
      widget = wibox.container.margin,
      margins = { top = dpi(4), right = dpi(2), bottom = dpi(3), left = dpi(6) },
      forced_width = dpi(210),
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
      margins = { top = dpi(4), right = dpi(2), bottom = dpi(3), left = dpi(2) },
      forced_width = dpi(200),
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
        strg_drives,
      },
    },
    {
      widget = wibox.container.margin,
      margins = { top = dpi(4), right = dpi(6), bottom = dpi(3), left = dpi(2) },
      forced_width = dpi(155),
      {
        layout = wibox.layout.fixed.vertical,
        network_text,
        network_adapters,
        space,
        uptime_text,
        uptime_time,
        space,
        devices_text,
        headset_bat,
      },
    },
  },
})

awesome.connect_signal("ui::resource::toggle", function()
  main.screen = awful.screen.focused()
  main.visible = not main.visible
end)

click_to_hide.popup(main, nil, true)

