local awful = require("awful")
local gears = require("gears")

local ac_cache
local use_cache
local now_cache
local full_cache

local function emit(ac, use, now, full)
  if ac == nil then
    ac = ac_cache
  end
  if use == nil then
    use = use_cache
  end
  if now == nil then
    now = now_cache
  end
  if full == nil then
    full = full_cache
  end
  awesome.emit_signal('signal::power', ac, use, now, full)
end

local function ac()
  awful.spawn.easy_async("cat /sys/class/power_supply/AC0/online", function(ac)
    local use = use:gsub("\n", "")
    ac_cache = ac
    emit(ac, nil, nil, nil)
  end)
end

local function battery()
  awful.spawn.easy_async("cat /sys/class/power_supply/BAT0/power_now", function(use)
    local use = use:gsub("\n", "")
    awful.spawn.easy_async("cat /sys/class/power_supply/BAT0/energy_now", function(now)
      local now = now:gsub("\n", "")
      awful.spawn.easy_async("cat /sys/class/power_supply/BAT0/energy_full", function(full)
        local full = full:gsub("\n", "")
        use_cache = use
        now_cache = now
        full_cache = cache
        emit(nil, use, now, full)
      end)
    end)
  end)
end

ac()
battery()

local power_timer = gears.timer {
  timeout = 5,
  autostart = true,
  callback = function()
    ac()
    battery()
  end,
}

return {
  ac = ac,
  battery = battery,
}
