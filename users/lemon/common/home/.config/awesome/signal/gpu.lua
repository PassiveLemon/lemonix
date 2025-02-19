local awful = require("awful")
local gears = require("gears")

-- nvidia_smi_table
-- (utilization) (temperature) (total_memory) (used_memory)

local function emit(nvidia_smi_table)
  awesome.emit_signal("signal::resource::gpu::data", nvidia_smi_table)
end

local function gpu()
  local nvidia_smi_table = { }
  awful.spawn.easy_async("nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.total,memory.used --format=csv,noheader,nounits", function(nvidia_smi_stdout)
    local nvidia_smi_raw = nvidia_smi_stdout:gsub("\n", "")
    if nvidia_smi_raw:match("Failed") then
      emit("ERR")
      return
    end
    for number in nvidia_smi_raw:gmatch("%d+") do
      table.insert(nvidia_smi_table, tonumber(number))
    end
    emit(nvidia_smi_table)
  end)
end

gpu()

-- luacheck: ignore 211
local gpu_timer = gears.timer({
  timeout = 2,
  autostart = true,
  callback = function()
    gpu()
  end,
})

