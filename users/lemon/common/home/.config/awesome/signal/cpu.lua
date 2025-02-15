local awful = require("awful")
local gears = require("gears")

local h = require("helpers")
local lfs = require("lfs")

local hwmon_names = {
  -- hwmon names for CPU temperatures
  ["cpu_thermal"] = true,
  ["coretemp"] = true,
  ["fam15h_power"] = true,
  ["k10temp"] = true,
}

local function emit(use, temp)
  awesome.emit_signal("signal::resource::cpu::data", use, temp)
end

local hwmon_list = { }

local function cpu()
  -- We take 100 minus the idle time to get the use
  awful.spawn.easy_async_with_shell("top -bn1 | grep '%Cpu' | awk '{print int(100-$8)}'", function(use_raw)
    local use = use_raw:gsub("\n", "")
    -- We iterate over each hwmon in /sys/class/hwmon, add certain ones to a list, and take the first element
    -- Sometimes hwmons can shift around so this will always at least get one of them, if any exist at all
    for hwmon in lfs.dir("/sys/class/hwmon/") do
      local hwmon_path = h.join_path("/sys/class/hwmon/", hwmon, "/name")
      awful.spawn.easy_async("cat " .. hwmon_path, function(name_stdout)
        local name = name_stdout:gsub("\n", "")
        if hwmon_names[name] then
          table.insert(hwmon_list, hwmon)
        end
      end)
    end
    local hwmon_1_path = h.join_path("/sys/class/hwmon/", hwmon_list[1], "/temp1_input")
    awful.spawn.easy_async("cat " .. hwmon_1_path, function(temp_stdout)
      local temp = temp_stdout:gsub("\n", "")
      local temp_norm = h.round((temp / 1000), 1)
      emit(use, temp_norm)
    end)
    hwmon_list = { }
  end)
end

cpu()

-- luacheck: ignore 211
local cpu_timer = gears.timer({
  timeout = 2,
  autostart = true,
  callback = function()
    cpu()
  end,
})

