local awful = require("awful")
local gears = require("gears")

local function emit(use)
  awesome.emit_signal("signal::cpu::data", use)
end

local function cpu()
  awful.spawn.easy_async_with_shell("top -bn1 | grep '%Cpu' | awk '{print int(100-$8)}'", function(use)
    local use = use:gsub("\n", "")
    emit(use)
  end)
end
cpu()
local cpu_timer = gears.timer({
  timeout = 3,
  autostart = true,
  callback = function()
    cpu()
  end,
})
