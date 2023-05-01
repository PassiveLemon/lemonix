local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local click_to_hide = require("config.helpers.click_to_hide")

--
-- Resource monitor menu
--
-- Special thanks to ChatGPT for the bulk of the commands.

local space = wibox.widget {
  widget = wibox.widget.textbox,
  text = " ",
  align = "center",
  valign = "center",
}

local strg_text = wibox.widget {
  widget = wibox.widget.textbox,
  text = "Storage",
  align = "center",
  valign = "center",
}

local strg_free_nvme = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

awful.widget.watch([[sh -c "echo -n 'NVME: ' && df -h /dev/nvme0n1p3 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GB \" int((used[1]/total[1])*100) \"%\"}'"]], 10, function(_, stdout)
  strg_free_nvme.text = stdout:gsub( "\n", "" )
end)

local strg_free_sdb = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

awful.widget.watch([[sh -c "echo -n 'SDB: ' && df -h /dev/sdb1 | awk 'NR==2 {split(\$3, used, \"T\"); split(\$2, total, \"T\"); print used[1] \"/\" total[1] \" TB \" int((used[1]/total[1])*100) \"%\"}'"]], 10, function(_, stdout)
  strg_free_sdb.text = stdout:gsub( "\n", "" )
end)

local strg_free_sda = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

awful.widget.watch([[sh -c "echo -n 'SDA: ' && df -h /dev/sda1 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GB \" int((used[1]/total[1])*100) \"%\"}'"]], 10, function(_, stdout)
  strg_free_sda.text = stdout:gsub( "\n", "" )
end)


local cpu_text = wibox.widget {
  widget = wibox.widget.textbox,
  text = "CPU",
  align = "center",
  valign = "center",
}

local cpu_use = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

awful.widget.watch([[sh -c "echo -n 'CPU Usage: ' && top -bn1 | grep '%Cpu' | awk '{print int(100-$8)}' && echo -n '%'"]], 1, function(_, stdout)
  cpu_use.text = stdout:gsub( "\n", "" )
end)

local cpu_temp = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

awful.widget.watch([[sh -c "cat /sys/class/thermal/thermal_zone*/temp | sed 's/\(.*\)000$/\1/' | tr -d '\n' && echo 'C'"]], 2, function(_, stdout)
  cpu_temp.text = stdout:gsub( "\n", "" )
end)

local mem_text = wibox.widget {
  widget = wibox.widget.textbox,
  text = "Memory",
  align = "center",
  valign = "center",
}

local mem_use = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

awful.widget.watch([[sh -c "echo -n 'Used: ' && free -h | grep 'Mem:' | awk '{gsub(/Gi/,\"\",\$3); gsub(/Gi/,\"\",\$2); print \$3\"/\"\$2}' | tr '\n' ' ' && echo 'GiB'"]], 2, function(_, stdout)
  mem_use.text = stdout:gsub( "\n", "" )
end)

local cache_use = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

awful.widget.watch([[sh -c "echo -n 'Cache: ' && free -h | grep 'Mem:' | awk '{gsub(/Gi/,\"\",\$6); gsub(/Gi/,\"\",\$2); print \$6\"/\"\$2}' | tr '\n' ' ' && echo 'GiB'"]], 5, function(_, stdout)
  cache_use.text = stdout:gsub( "\n", "" )
end)

local gpu_text = wibox.widget {
  widget = wibox.widget.textbox,
  text = "GPU",
  align = "center",
  valign = "center",
}

local gpu_use = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

awful.widget.watch([[sh -c "echo -n 'GPU Usage: ' && nvidia-smi | grep 'Default' | cut -d '|' -f 4 | tr -d 'Default' | tr -d '[:space:]'"]], 1, function(_, stdout)
  gpu_use.text = stdout:gsub( "\n", "" )
end)

local gpu_temp = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

awful.widget.watch([[sh -c "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | tr -d '\n' && echo 'C'"]], 2, function(_, stdout)
  gpu_temp.text = stdout:gsub( "\n", "" )
end)

local gpu_mem = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

awful.widget.watch([[sh -c "echo -n 'GPU Mem: ' && nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk -F',' '{printf \"%.2f/%.2f GiB\n\", \$1/1024, \$2/1024}'"]], 2, function(_, stdout)
  gpu_mem.text = stdout:gsub( "\n", "" )
end)

local network_text = wibox.widget {
  widget = wibox.widget.textbox,
  text = "Network",
  align = "center",
  valign = "center",
}

local network_total = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

awful.widget.watch([[sh -c 'ip -s link show enp9s0 | awk '\''/RX:/{getline; rx=$1} /TX:/{getline; tx=$1} END{printf "Rx/Tx: %sB/%sB\n", convert(rx), convert(tx)} function convert(val) {suffix="BKMGTPE"; for(i=1; val>1024; i++) val/=1024; return int(val+0.5) substr(suffix, i, 1)}'\']], 5, function(_, stdout)
  network_total.text = stdout:gsub( "\n", "" )
end)

local uptime_text = wibox.widget {
  widget = wibox.widget.textbox,
  text = "Uptime",
  align = "center",
  valign = "center",
}

local uptime = wibox.widget {
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
}

awful.widget.watch([[sh -c 'uptime | awk -F"[ ,:]+" '\''{print $6 " days, " $8 " hours"}'\''']], 60, function(_, stdout)
  uptime.text = stdout:gsub( "\n", "" )
end)

local resourcemenu_container = wibox.widget {
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
    forced_width = 175,
    margins = { top = 4, right = 2, bottom = 3, left = 2, },
    widget = wibox.container.margin,
    {
      layout = wibox.layout.fixed.vertical,
      mem_text,
      mem_use,
      cache_use,
      space,
      strg_text,
      strg_free_nvme,
      strg_free_sda,
      strg_free_sdb,
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
}

local resourcemenu_pop = awful.popup {
  widget = resourcemenu_container,
  placement = awful.placement.centered,
  ontop = true,
  border_width = 2,
  border_color = beautiful.border_color_active,
}

resourcemenu_pop.visible = false

local function signal()
  resourcemenu_pop.visible = not resourcemenu_pop.visible
  resourcemenu_pop.screen = awful.screen.focused()
end

click_to_hide.popup(resourcemenu_pop, nil, true)

return { signal = signal }