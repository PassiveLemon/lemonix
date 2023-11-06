local awful = require("awful")
local gears = require("gears")

local function emit(use, use_perc, cache, cache_perc)
  awesome.emit_signal('signal::memory', use, use_perc, cache, cache_perc)
end

local function memory()
  awful.spawn.easy_async_with_shell([[sh -c "free -m | grep 'Mem:' | awk '{printf \"%0.1f/%0.0f\", (\$3/1000), (\$2/1000)}'"]], function(use)
    local use = use:gsub("\n", "")
    awful.spawn.easy_async_with_shell([[sh -c "free -m | grep 'Mem:' | awk '{printf \"%0.0f\", ((\$3/\$2)*100)}'"]], function(use_perc)
      local use_perc = use_perc:gsub("\n", "")
      awful.spawn.easy_async_with_shell([[sh -c "free -m | grep 'Mem:' | awk '{printf \"%0.1f/%0.0f\", (\$6/1000), (\$2/1000)}'"]], function(cache)
        local cache = cache:gsub("\n", "")
        awful.spawn.easy_async_with_shell([[sh -c "free -m | grep 'Mem:' | awk '{printf \"%0.0f\", ((\$6/\$2)*100)}'"]], function(cache_perc)
          local cache_perc = cache_perc:gsub("\n", "")
          emit(use, use_perc, cache, cache_perc)
        end)
      end)
    end)
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

return { memory = memory }
