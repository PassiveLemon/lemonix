local awful = require("awful")
local gears = require("gears")

-- nvidia_smi_table
-- (utilization) (temperature) (total_memory) (used_memory)

local function emit(nvidia_smi_table)
  awesome.emit_signal("signal::resource::gpu::data", nvidia_smi_table)
end

local function gpu()
  local nvidia_smi_table = { }
  awful.spawn.easy_async_with_shell("nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.total,memory.used --format=csv,noheader,nounits", function(nvidia_smi_raw)
    local nvidia_smi_raw = nvidia_smi_raw:gsub("\n", "")
    for number in nvidia_smi_raw:gmatch("%d+") do
      table.insert(nvidia_smi_table, number)
    end
    emit(nvidia_smi_table)
  end)
end
gpu()
local gpu_timer = gears.timer({
  timeout = 2,
  autostart = true,
  callback = function()
    gpu()
  end,
})
