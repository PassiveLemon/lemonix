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

local function cpu()
  -- We take 100 minus the idle time to get the use
  awful.spawn.easy_async_with_shell("top -bn1 | grep '%Cpu' | awk '{print int(100-$8)}'", function(use_raw)
    local use = use_raw:gsub("\n", "")
    -- We iterate over each hwmon in /sys/class/hwmon and get the first device that matches
    for hwmon in lfs.dir("/sys/class/hwmon/") do
      if hwmon:match("^hwmon%d+$") then
        local hwmon_path = h.join_path("/sys/class/hwmon/", hwmon, "/name")
        local name = h.read_file(hwmon_path)
        if hwmon_names[name] then
          local hwmon_1_path = h.join_path("/sys/class/hwmon/", hwmon, "/temp1_input")
          local temp = h.read_file(hwmon_1_path)
          local to_temp = tonumber(temp)
          if to_temp then
            local temp_norm = h.round((to_temp / 1000), 1)
            emit(use, temp_norm)
            return
          end
        end
      end
    end
  end)
end

cpu()

-- luacheck: ignore 211
---@diagnostic disable-next-line: unused-local
local cpu_timer = gears.timer({
  timeout = 2,
  autostart = true,
  callback = function()
    cpu()
  end,
})

