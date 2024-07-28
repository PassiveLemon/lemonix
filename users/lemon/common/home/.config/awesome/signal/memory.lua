local awful = require("awful")
local gears = require("gears")

local h = require("helpers")

-- free_mem_table
-- (total) (used) (free) (shared) (buff/cache) (available)

local function emit(free_mem_table)
  awesome.emit_signal("signal::resource::memory::data", free_mem_table)
end

local function normalize(value)
  return h.round((tonumber(value) / 1000), 1)
end

local function memory()
  local free_mem_table = { }
  awful.spawn.easy_async_with_shell("free -m | grep 'Mem:'", function(free_raw)
    local free_raw = free_raw:gsub("\n", "")
    for number in free_raw:gmatch("%d+") do
      table.insert(free_mem_table, normalize(number))
    end
    emit(free_mem_table)
  end)
end
memory()
local memory_timer = gears.timer({
  timeout = 3,
  autostart = true,
  callback = function()
    memory()
  end,
})
