local awful = require("awful")
local wibox = require("wibox")

local helpers = require("helpers")

--
-- GPU watches
--

gpu = { }

gpu.use = helpers.simplewtch([[sh -c "echo -n 'GPU Usage: ' && nvidia-smi | grep 'Default' | cut -d '|' -f 4 | tr -d 'Default' | tr -d '[:space:]'"]], 1)
gpu.temp = helpers.simplewtch([[sh -c "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | tr -d '\n' && echo 'C'"]], 2)
gpu.mem = helpers.simplewtch([[sh -c "echo -n 'GPU Mem: ' && nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk -F',' '{printf \"%.2f/%.2f GiB\n\", \$1/1024, \$2/1024}'"]], 2)

return gpu
