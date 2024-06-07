local awful = require("awful")
local gears = require("gears")

local function emit(nvme0)
  awesome.emit_signal("signal::storage::data", nvme0)
end

local function storage()
  awful.spawn.easy_async_with_shell([[sh -c "df -h /dev/nvme0n1p1 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GiB \" int((used[1]/total[1])*100) \"%\"}'"]], function(nvme0)
    local nvme0 = nvme0:gsub("\n", "")
    emit(nvme0)
  end)
end
storage()
local storage_timer = gears.timer({
  timeout = 60,
  autostart = true,
  callback = function()
    storage()
  end,
})
