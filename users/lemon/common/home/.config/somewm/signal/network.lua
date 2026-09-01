local awful = require("awful")
local gears = require("gears")

local networkmanager = require("lgi").NM

-- network_stats_table
--               |read                                                                   |write
-- interface = { (bytes) (packets) (errs) (drop) (fifo) (frame) (compressed) (multicast) (bytes) (packets) (errs) (drop) (fifo) (colls) (carrier) (compressed) }

local function emit(network_stats_table)
  awesome.emit_signal("signal::resource::network::data", network_stats_table)
end

local client = networkmanager.Client.new()
local devices = client:get_devices()

local function update_devices()
  devices = client:get_devices()
end

local function interface_stats_table(interface_stats)
  local stats_table = { }
  for number in interface_stats:gmatch("%d+") do
    table.insert(stats_table, tonumber(number))
  end
  return stats_table
end

local adapter_pattern_lookup = {
  "^enp%d+s%d+$",
  "^wlp%d+s%d+$",
}

local function network()
  update_devices()
  local network_stats_table = { }
  for _, device in ipairs(devices) do
    for _, pattern in ipairs(adapter_pattern_lookup) do
      local interface = device:get_iface()
      if interface:match(pattern) and (device:get_state() == "ACTIVATED") then
        awful.spawn.easy_async_with_shell("cat /proc/net/dev | grep " .. interface, function(interface_stats_stdout)
          local interface_stats = interface_stats_stdout:gsub("\n", ""):gsub(interface .. ":", "")
          network_stats_table[interface] = interface_stats_table(interface_stats)
        end)
        break
      end
    end
  end
  awful.spawn.easy_async("sleep 2", function()
    emit(network_stats_table)
  end)
end

network()

-- luacheck: ignore 211
---@diagnostic disable-next-line: unused-local
local total_timer = gears.timer({
  timeout = 60,
  autostart = true,
  callback = function()
    network()
  end,
})

