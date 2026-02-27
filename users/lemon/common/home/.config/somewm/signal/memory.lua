local awful = require("awful")
local gears = require("gears")

local h = require("helpers")

-- free_mem_table                 | not always present
-- type = { (total) (used) (free) (shared) (buff/cache) (available) }

local function emit(free_mem_table)
  awesome.emit_signal("signal::resource::memory::data", free_mem_table)
end

local function normalize(value)
  return h.round((tonumber(value) / 1000), 1)
end

local function memory()
  local free_mem_table = { }
  awful.spawn.easy_async_with_shell("free -m", function(free_stdout)
    for line in free_stdout:gmatch("[^\n]+") do
      local type = line:match("^(%w+):")
      if type then
        free_mem_table[type] = { }
        for number in (line:gmatch("%d+")) do
          table.insert(free_mem_table[type], normalize(number))
        end
      end
    end
  end)
  awful.spawn.easy_async("sleep 2", function()
    emit(free_mem_table)
  end)
end

memory()

-- luacheck: ignore 211
---@diagnostic disable-next-line: unused-local
local memory_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    memory()
  end,
})

