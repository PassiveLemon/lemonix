local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("helpers")
local click_to_hide = require("modules.click_to_hide")

--
-- Resource monitor menu
--
-- Special thanks to ChatGPT for the bulk of the commands.

local space = helpers.simpletxt(nil, nil, " ", beautiful.font, "center")

local cpu_text = helpers.simpletxt(nil, nil, "CPU", beautiful.font, "center")

local cpu_use = helpers.simplewtch([[sh -c "echo -n 'CPU Usage: ' && top -bn1 | grep '%Cpu' | awk '{print int(100-$8)}' && echo -n '%'"]], 1)

local cpu_temp = helpers.simplewtch([[sh -c "cat /sys/class/thermal/thermal_zone*/temp | sed 's/\(.*\)000$/\1/' | tr -d '\n' && echo 'C'"]], 2)

local mem_text = helpers.simpletxt(nil, nil, "Memory", beautiful.font, "center")

local mem_use = helpers.simplewtch([[sh -c "echo -n 'Used: ' && free -h | grep 'Mem:' | awk '{gsub(/Gi/,\"\",\$3); gsub(/Gi/,\"\",\$2); print \$3\"/\"\$2}' | tr '\n' ' ' && echo 'GiB'"]], 2)
local mem_use_perc = helpers.simplewtch([[sh -c "echo -n '' && free -h | awk '/Mem:/{gsub(/Gi/,\"\",\$2); gsub(/Gi/,\"\",\$3); printf \"%.0f%%\", (\$3/\$2)*100}'"]], 2)

local cache_use = helpers.simplewtch([[sh -c "echo -n 'Cache: ' && free -h | grep 'Mem:' | awk '{gsub(/Gi/,\"\",\$6); gsub(/Gi/,\"\",\$2); print \$6\"/\"\$2}' | tr '\n' ' ' && echo 'GiB'"]], 5)
local cache_use_perc = helpers.simplewtch([[sh -c "echo -n '' && free -h | awk '/Mem:/{gsub(/Gi/,\"\",\$2); gsub(/Gi/,\"\",\$6); printf \"%.0f%%\", (\$6/\$2)*100}'"]], 5)

local network_text = helpers.simpletxt(nil, nil, "Network", beautiful.font, "center")

local network_total = helpers.simplewtch([[sh -c 'ip -s link show enp7s0 | awk '\''/RX:/{getline; rx=$1} /TX:/{getline; tx=$1} END{printf "Dn/Up: %sB/%sB\n", convert(rx), convert(tx)} function convert(val) {suffix="BKMGTPE"; for(i=1; val>1024; i++) val/=1024; return int(val+0.5) substr(suffix, i, 1)}'\']], 5)

local gpu_text = helpers.simpletxt(nil, nil, "GPU", beautiful.font, "center")

local gpu_use = helpers.simplewtch([[sh -c "echo -n 'GPU Usage: ' && nvidia-smi | grep 'Default' | cut -d '|' -f 4 | tr -d 'Default' | tr -d '[:space:]'"]], 1)

local gpu_temp = helpers.simplewtch([[sh -c "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | tr -d '\n' && echo 'C'"]], 2)

local gpu_mem = helpers.simplewtch([[sh -c "echo -n 'GPU Mem: ' && nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk -F',' '{printf \"%.2f/%.2f GiB\n\", \$1/1024, \$2/1024}'"]], 2)

local strg_text = helpers.simpletxt(nil, nil, "Storage", beautiful.font, "center")

local strg_free_nvme0 = helpers.simplewtch([[sh -c "echo -n 'NVME0: ' && df -h /dev/nvme0n1p2 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GB \" int((used[1]/total[1])*100) \"%\"}'"]], 60)

local strg_free_nvme1 = helpers.simplewtch([[sh -c "echo -n 'NVME1: ' && df -h /dev/nvme1n1p1 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GB \" int((used[1]/total[1])*100) \"%\"}'"]], 60)

local strg_free_sda1 = helpers.simplewtch([[sh -c "echo -n 'SDA1: ' && df -h /dev/sda1 | awk 'NR==2 {split(\$3, used, \"T\"); split(\$2, total, \"T\"); print used[1] \"/\" total[1] \" TB \" int((used[1]/total[1])*100) \"%\"}'"]], 60)

local strg_free_sdb1 = helpers.simplewtch([[sh -c "echo -n 'SDB1: ' && df -h /dev/sdb1 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GB \" int((used[1]/total[1])*100) \"%\"}'"]], 60)

local uptime_text = helpers.simpletxt(nil, nil, "Uptime", beautiful.font, "center")

local uptime = helpers.simplewtch([[sh -c "uptime | awk -F'( |,|:)+' '{if (\$6 >= 1) {print \$6, \"days\", \$8, \"hours\"} else {print \$8, \"hours\"}}'"]], 60)

local resourcemenu_pop = awful.popup {
  placement = awful.placement.centered,
  border_width = 3,
  border_color = beautiful.border_color_active,
  ontop = true,
  visible = false,
  widget = {
    layout = wibox.layout.align.horizontal,
    {
      forced_width = 210,
      margins = { top = 4, right = 2, bottom = 3, left = 6, },
      widget = wibox.container.margin,
      {
        layout = wibox.layout.fixed.vertical,
        cpu_text,
        {
          layout = wibox.layout.fixed.horizontal,
          cpu_use,
          space,
          cpu_temp,
        },
        space,
        gpu_text,
        {
          layout = wibox.layout.fixed.horizontal,
          gpu_use,
          space,
          gpu_temp,
        },
        gpu_mem,
      },
    },
    {
      forced_width = 185,
      margins = { top = 4, right = 2, bottom = 3, left = 2, },
      widget = wibox.container.margin,
      {
        layout = wibox.layout.fixed.vertical,
        mem_text,
        {
          layout = wibox.layout.fixed.horizontal,
          mem_use,
          space,
          mem_use_perc,
        },
        {
          layout = wibox.layout.fixed.horizontal,
          cache_use,
          space,
          cache_use_perc,
        },
        space,
        strg_text,
        strg_free_nvme0,
        strg_free_nvme1,
        strg_free_sda1,
        strg_free_sdb1,
      },
    },
    {
      forced_width = 155,
      margins = { top = 4, right = 6, bottom = 3, left = 2, },
      widget = wibox.container.margin,
      {
        layout = wibox.layout.fixed.vertical,
        network_text,
        network_total,
        space,
        uptime_text,
        uptime,
      },
    },
  },
}

local function signal()
  resourcemenu_pop.visible = not resourcemenu_pop.visible
  resourcemenu_pop.screen = awful.screen.focused()
  helpers.unfocus()
end

click_to_hide.popup(resourcemenu_pop, nil, true)

return { signal = signal }
