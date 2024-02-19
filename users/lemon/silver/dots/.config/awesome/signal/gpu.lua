local awful = require("awful")
local gears = require("gears")

local function emit(use, temp, mem)
  awesome.emit_signal("signal::gpu::data", use, temp, mem)
end

local function gpu()
  awful.spawn.easy_async_with_shell("nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits", function(use)
    local use = use:gsub("\n", "")
    awful.spawn.easy_async_with_shell("nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader", function(temp)
      local temp = temp:gsub("\n", "")
      awful.spawn.easy_async_with_shell([[sh -c "nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk -F',' '{printf \"%.2f/%.2f GiB\n\", \$1/1024, \$2/1024}'"]], function(mem)
        local mem = mem:gsub("\n", "")
        emit(use, temp, mem)
      end)
    end)  
  end)
end

gpu()

local gpu_timer = gears.timer({
  timeout = 1,
  autostart = true,
  callback = function()
    gpu()
  end,
})
