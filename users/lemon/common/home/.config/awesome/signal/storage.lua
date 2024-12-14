local awful = require("awful")
local gears = require("gears")

local h = require("helpers")
local lfs = require("lfs")

-- storage_stats_dict
-- device = { (filesystem) (1k-blocks) (used) (available) (use%) (mounted on) }

local function emit(storage_stats_dict)
  awesome.emit_signal("signal::resource::storage::data", storage_stats_dict)
end

local function device_stats_table(device_stats)
  local stats_table = { }
  for number in device_stats:gmatch("%S+") do
    table.insert(stats_table, number)
  end
  return stats_table
end

local function storage()
  local storage_stats_dict = { }
  -- We iterate over each storage device in /sys/block and filter them by a pattern
  -- Then iterate over the matches, get a table of the first partition stats, and then add that key value pair to a table for use elsewhere
  for device in lfs.dir("/sys/block") do
    if device:match("nvme.(d*)n.(d*)") then
      local device_path = h.join_path("/dev/", device)
      awful.spawn.easy_async_with_shell("df " .. device_path .. "p1 | grep '/dev'", function(device_stats, _, _, code)
        if code == 0 then
          local device_stats = device_stats:gsub("\n", "")
          storage_stats_dict[device] = device_stats_table(device_stats)
        end
      end)
    elseif device:match("sd.(l*)") then
      local device_path = h.join_path("/dev/", device)
      awful.spawn.easy_async_with_shell("df ".. device_path .. "1 | grep '/dev'", function(device_stats, _, _, code)
        if code == 0 then
          local device_stats = device_stats:gsub("\n", "")
          storage_stats_dict[device] = device_stats_table(device_stats)
        end
      end)
    end
  end
  awful.spawn.easy_async("sleep 5", function()
    emit(storage_stats_dict)
  end)
end
storage()
local storage_timer = gears.timer({
  timeout = 60,
  autostart = true,
  callback = function()
    storage()
  end,
})

