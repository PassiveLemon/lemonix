local awful = require("awful")
local gears = require("gears")

local function emit(total)
  awesome.emit_signal('signal::network', total)
end

local function total()
  awful.spawn.easy_async_with_shell([[sh -c 'ip -s link show wlo1 | awk '\''/RX:/{getline; rx=$1} /TX:/{getline; tx=$1} END{printf "%sB/%sB\n", convert(rx), convert(tx)} function convert(val) {suffix="BKMGTPE"; for(i=1; val>1024; i++) val/=1024; return int(val+0.5) substr(suffix, i, 1)}'\']], function(total)
    total = total:gsub("\n", "")
    emit(total)
  end)
end

total()

local total_timer = gears.timer {
  timeout = 1,
  autostart = true,
  callback = function()
    total()
  end,
}

return { total = total }
