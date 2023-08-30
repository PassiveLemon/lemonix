local awful = require("awful")
local wibox = require("wibox")

local helpers = require("helpers")

--
-- Memory watches
--

memory = { }

memory.use = helpers.simplewtch([[sh -c "free -h | grep 'Mem:' | awk '{gsub(/Gi/,\"\"); print \$3}'"]], 2)
memory.cache_use = helpers.simplewtch([[sh -c "free -h | grep 'Mem:' | awk '{gsub(/Gi/,\"\"); print \$6}'"]], 5)

memory.use_perc = helpers.simplewtch([[sh -c "free -h | awk '/Mem:/{gsub(/Gi/,\"\",\$2); gsub(/Gi/,\"\",\$3); printf \"%.0f\", (\$3/\$2)*100}'"]], 2)
memory.cache_use_perc = helpers.simplewtch([[sh -c "free -h | awk '/Mem:/{gsub(/Gi/,\"\",\$2); gsub(/Gi/,\"\",\$6); printf \"%.0f\", (\$6/\$2)*100}'"]], 5)

return memory
