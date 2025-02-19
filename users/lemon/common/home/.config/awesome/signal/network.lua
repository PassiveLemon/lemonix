local awful = require("awful")
local gears = require("gears")

local lfs = require("lfs")

-- network_stats_dict
--             |read                                                                   |write
-- adapter = { (bytes) (packets) (errs) (drop) (fifo) (frame) (compressed) (multicast) (bytes) (packets) (errs) (drop) (fifo) (colls) (carrier) (compressed) }

local function emit(network_stats_dict)
  awesome.emit_signal("signal::resource::network::data", network_stats_dict)
end

local function adapter_stats_table(adapter_stats)
  local stats_table = { }
  for number in adapter_stats:gmatch("%d+") do
    table.insert(stats_table, tonumber(number))
  end
  return stats_table
end

local function network()
  local network_stats_dict = { }
  -- We iterate over each network adapter in /sys/class/net and filter them by a pattern
  -- Then iterate over the matches, get a table of the adapter stats, and then add that key value pair to a table for use elsewhere
  for adapter in lfs.dir("/sys/class/net") do
    if adapter:match("enp.(d*)s.(d*)") or adapter:match("wlp.(d*)s.(d*)") then
      awful.spawn.easy_async_with_shell("ip -s link show ".. adapter .. " | grep 'state UP'", function(_, _, _, code)
        if code == 0 then
          awful.spawn.easy_async_with_shell("cat /proc/net/dev | grep " .. adapter, function(adapter_stats_stdout)
            local adapter_stats = adapter_stats_stdout:gsub("\n", ""):gsub(adapter .. ":", "")
            network_stats_dict[adapter] = adapter_stats_table(adapter_stats)
          end)
        end
      end)
    end
  end
  awful.spawn.easy_async_with_shell("sleep 5", function()
    emit(network_stats_dict)
  end)
end

network()

-- luacheck: ignore 211
local total_timer = gears.timer({
  timeout = 60,
  autostart = true,
  callback = function()
    network()
  end,
})

