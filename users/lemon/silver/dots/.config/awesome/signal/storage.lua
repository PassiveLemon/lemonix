local awful = require("awful")
local gears = require("gears")

local function emit(nvme0, nvme1, sda, sdb)
  awesome.emit_signal('signal::storage', nvme0, nvme1, sda, sdb)
end

local function storage()
  awful.spawn.easy_async_with_shell([[sh -c "df -h /dev/nvme0n1p1 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GiB \" int((used[1]/total[1])*100) \"%\"}'"]], function(nvme0)
    local nvme0 = nvme0:gsub("\n", "")
    awful.spawn.easy_async_with_shell([[sh -c "df -h /dev/nvme1n1p1 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GiB \" int((used[1]/total[1])*100) \"%\"}'"]], function(nvme1)
      local nvme1 = nvme1:gsub("\n", "")
      awful.spawn.easy_async_with_shell([[sh -c "df -h /dev/sda1 | awk 'NR==2 {split(\$3, used, \"T\"); split(\$2, total, \"T\"); print used[1] \"/\" total[1] \" TiB \" int((used[1]/total[1])*100) \"%\"}'"]], function(sda)
        local sda = sda:gsub("\n", "")
        awful.spawn.easy_async_with_shell([[sh -c "df -h /dev/sdb1 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GiB \" int((used[1]/total[1])*100) \"%\"}'"]], function(sdb)
          local sdb = sdb:gsub("\n", "")
          emit(nvme0, nvme1, sda, sdb)
        end)
      end)
    end)
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

return { storage = storage, }
