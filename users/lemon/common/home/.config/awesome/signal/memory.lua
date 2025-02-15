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
  awful.spawn.easy_async_with_shell("free -m | grep 'Mem:'", function(free_stdout)
    local free = free_stdout:gsub("\n", "")
    for number in free:gmatch("%d+") do
      table.insert(free_mem_table, normalize(number))
    end
    emit(free_mem_table)
  end)
end

memory()

-- luacheck: ignore 211
local memory_timer = gears.timer({
  timeout = 3,
  autostart = true,
  callback = function()
    memory()
  end,
})

