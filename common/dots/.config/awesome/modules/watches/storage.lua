local awful = require("awful")
local wibox = require("wibox")

local helpers = require("helpers")

--
-- Storage watches
--

storage = { }

storage.free_nvme0 = helpers.simplewtch([[sh -c "echo -n 'NVME0: ' && df -h /dev/nvme0n1p2 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GB \" int((used[1]/total[1])*100) \"%\"}'"]], 60)
storage.free_nvme1 = helpers.simplewtch([[sh -c "echo -n 'NVME1: ' && df -h /dev/nvme1n1p1 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GB \" int((used[1]/total[1])*100) \"%\"}'"]], 60)
storage.free_sda1 = helpers.simplewtch([[sh -c "echo -n 'SDA1: ' && df -h /dev/sda1 | awk 'NR==2 {split(\$3, used, \"T\"); split(\$2, total, \"T\"); print used[1] \"/\" total[1] \" TB \" int((used[1]/total[1])*100) \"%\"}'"]], 60)
storage.free_sdb1 = helpers.simplewtch([[sh -c "echo -n 'SDB1: ' && df -h /dev/sdb1 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GB \" int((used[1]/total[1])*100) \"%\"}'"]], 60)

return storage
