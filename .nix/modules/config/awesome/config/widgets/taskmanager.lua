local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

beautiful.init("/home/lemon/.config/awesome/config/theme.lua")

local taskman_pop_vis = false

local space = wibox.widget {
  widget = wibox.widget.textbox,
  text = " ",
  align = "center",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

local strg_text = wibox.widget {
  widget = wibox.widget.textbox,
  text = "Storage",
  align = "center",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

local strg_free_nvme = wibox.widget {
  widget = wibox.widget.textbox,
  text = "NVME: ",
  align = "left",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

awful.widget.watch( [[sh -c "echo -n 'NVME: ' && df -h /dev/nvme0n1p3 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GB \" int((used[1]/total[1])*100) \"%\"}'"]], 5, function(_, stdout)
  strg_free_nvme.text = stdout:gsub( "\n", "" )
end)

local function update_gpu_usage()
  awful.spawn.easy_async( [[sh -c "echo -n 'NVME: ' && df -h /dev/nvme0n1p3 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GB \" int((used[1]/total[1])*100) \"%\"}'"]], function(stdout)
    strg_free_nvme.text = stdout:gsub( "\n", "" )
  end)
end

local strg_free_sdb = wibox.widget {
  widget = wibox.widget.textbox,
  text = "SDB: ",
  align = "left",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

awful.widget.watch( [[sh -c "echo -n 'SDB: ' && df -h /dev/sdb1 | awk 'NR==2 {split(\$3, used, \"T\"); split(\$2, total, \"T\"); print used[1] \"/\" total[1] \" TB \" int((used[1]/total[1])*100) \"%\"}'"]], 5, function(_, stdout)
  strg_free_sdb.text = stdout:gsub( "\n", "" )
end)

local function update_gpu_usage()
  awful.spawn.easy_async( [[sh -c "echo -n 'SDB: ' && df -h /dev/sdb1 | awk 'NR==2 {split(\$3, used, \"T\"); split(\$2, total, \"T\"); print used[1] \"/\" total[1] \" TB \" int((used[1]/total[1])*100) \"%\"}'"]], function(stdout)
    strg_free_sdb.text = stdout:gsub( "\n", "" )
  end)
end

local strg_free_sda = wibox.widget {
  widget = wibox.widget.textbox,
  text = "SDA: ",
  align = "left",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

awful.widget.watch( [[sh -c "echo -n 'SDA: ' && df -h /dev/sda1 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GB \" int((used[1]/total[1])*100) \"%\"}'"]], 5, function(_, stdout)
  strg_free_sda.text = stdout:gsub( "\n", "" )
end)

local function update_gpu_usage()
  awful.spawn.easy_async( [[sh -c "echo -n 'SDA: ' && df -h /dev/sda1 | awk 'NR==2 {split(\$3, used, \"G\"); split(\$2, total, \"G\"); print used[1] \"/\" total[1] \" GB \" int((used[1]/total[1])*100) \"%\"}'"]], function(stdout)
    strg_free_sda.text = stdout:gsub( "\n", "" )
  end)
end


local cpu_text = wibox.widget {
  widget = wibox.widget.textbox,
  text = "CPU",
  align = "center",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

local cpu_use = wibox.widget {
  widget = wibox.widget.textbox,
  text = "CPU Usage: N/A%",
  align = "left",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

awful.widget.watch( [[sh -c "echo -n 'CPU Usage: ' && top -bn1 | grep '%Cpu' | awk '{print int(100-$8)}' && echo -n '%'"]], 1, function(_, stdout)
  cpu_use.text = stdout:gsub( "\n", "" )
end)

local function update_gpu_usage()
  awful.spawn.easy_async( [[sh -c "echo -n 'CPU Usage: ' && top -bn1 | grep '%Cpu' | awk '{print int(100-$8)}' && echo -n '%'"]], function(stdout)
    cpu_use.text = stdout:gsub( "\n", "" )
  end)
end

local mem_text = wibox.widget {
  widget = wibox.widget.textbox,
  text = "Memory",
  align = "center",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

local mem_use = wibox.widget {
  widget = wibox.widget.textbox,
  text = "RAM Usage: N/A%",
  align = "left",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

awful.widget.watch( [[sh -c "echo -n 'RAM Usage: ' && free -h | grep 'Mem:' | awk '{gsub(/Gi/,\"\",\$3); gsub(/Gi/,\"\",\$2); print \$3\"/\"\$2}' | tr '\n' ' ' && echo 'GiB'"]], 1, function(_, stdout)
  mem_use.text = stdout:gsub( "\n", "" )
end)

local function update_gpu_usage()
  awful.spawn.easy_async( [[sh -c "echo -n 'RAM Usage: ' && free -h | grep 'Mem:' | awk '{gsub(/Gi/,\"\",\$3); gsub(/Gi/,\"\",\$2); print \$3\"/\"\$2}' | tr '\n' ' ' && echo 'GiB'"]], function(stdout)
    mem_use.text = stdout:gsub( "\n", "" )
  end)
end

local gpu_text = wibox.widget {
  widget = wibox.widget.textbox,
  text = "GPU",
  align = "center",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

local gpu_use = wibox.widget {
  widget = wibox.widget.textbox,
  text = "GPU Usage: N/A%",
  align = "left",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

awful.widget.watch( [[sh -c "echo -n 'GPU Usage: ' && nvidia-smi | grep 'Default' | cut -d '|' -f 4 | tr -d 'Default' | tr -d '[:space:]'"]], 1, function(_, stdout)
  gpu_use.text = stdout:gsub( "\n", "" )
end)

local function update_gpu_usage()
  awful.spawn.easy_async( [[sh -c "echo -n 'GPU Usage: ' && nvidia-smi | grep 'Default' | cut -d '|' -f 4 | tr -d 'Default' | tr -d '[:space:]'"]], function(stdout)
    gpu_use.text = stdout:gsub( "\n", "" )
  end)
end

local gpu_mem = wibox.widget {
  widget = wibox.widget.textbox,
  text = "GPU Mem: N/A%",
  align = "left",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

awful.widget.watch( [[sh -c "echo -n 'GPU Mem: ' && nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk -F',' '{printf \"%.2f/%.2f GiB\n\", \$1/1024, \$2/1024}'"]], 1, function(_, stdout)
  gpu_mem.text = stdout:gsub( "\n", "" )
end)

local function update_gpu_usage()
  awful.spawn.easy_async( [[sh -c "echo -n 'GPU Mem: ' && nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk -F',' '{printf \"%.2f/%.2f GiB\n\", \$1/1024, \$2/1024}'"]], function(stdout)
    gpu_mem.text = stdout:gsub( "\n", "" )
  end)
end

local audio_text = wibox.widget {
  widget = wibox.widget.textbox,
  text = "Audio",
  align = "center",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

local audio_vol = wibox.widget {
  widget = wibox.widget.textbox,
  text = "Volume: N/A%",
  align = "left",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

awful.widget.watch( [[sh -c "echo -n 'Volume: ' && pamixer --get-volume-human"]], 0.25, function(_, stdout)
  audio_vol.text = stdout:gsub( "\n", "" )
end)

local function update_vol_usage()
  awful.spawn.easy_async( [[sh -c "echo -n 'Volume: ' && pamixer --get-volume-human"]], function(stdout)
    audio_vol.text = stdout:gsub( "\n", "" )
  end)
end

local network_text = wibox.widget {
  widget = wibox.widget.textbox,
  text = "Network",
  align = "center",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

local network_total = wibox.widget {
  widget = wibox.widget.textbox,
  text = "Total: N/A%",
  align = "left",
  valign = "center",
  bg = beautiful.bg_normal,
  fg = "#ffffff",
}

awful.widget.watch( [[sh -c 'ip -s link show enp9s0 | awk '\''/RX:/{getline; rx=$1} /TX:/{getline; tx=$1} END{printf "Rx/Tx: %sB/%sB\n", convert(rx), convert(tx)} function convert(val) {suffix="B KMGTPE"; for(i=1; val>1024; i++) val/=1024; return int(val+0.5) substr(suffix, i, 1)}'\']], 3, function(_, stdout)
  network_total.text = stdout:gsub( "\n", "" )
end)

local function update_vol_usage()
  awful.spawn.easy_async( [[sh -c 'ip -s link show enp9s0 | awk '\''/RX:/{getline; rx=$1} /TX:/{getline; tx=$1} END{printf "Rx/Tx: %sB/%sB\n", convert(rx), convert(tx)} function convert(val) {suffix="B KMGTPE"; for(i=1; val>1024; i++) val/=1024; return int(val+0.5) substr(suffix, i, 1)}'\']], function(stdout)
    network_total.text = stdout:gsub( "\n", "" )
  end)
end

local taskman_container = wibox.widget {
  layout = wibox.layout.align.horizontal,
  {
    forced_width = 210,
    margins = {
      top = 2,
      right = 2,
      down = 3,
      left = 4
    },
    widget = wibox.container.margin
    {
      layout = wibox.layout.fixed.vertical,
      cpu_text,
      cpu_use,
      space,
      gpu_text,
      gpu_use,
      gpu_mem
    },
  },
  {
    forced_width = 175 ,
    margins = {
      top = 2,
      right = 2,
      down = 3,
      left = 2
    },
    widget = wibox.container.margin
    {
      layout = wibox.layout.fixed.vertical,
      mem_text,
      mem_use,
      space,
      strg_text,
      strg_free_nvme,
      strg_free_sdb,
      strg_free_sda
    },
  },
  {
    forced_width = 155,
    margins = {
      top = 2,
      right = 4,
      down = 3,
      left = 2
    },
    widget = wibox.container.margin
    {
      layout = wibox.layout.fixed.vertical,
      network_text,
      network_total
      --net_speed
    },
  },
}

local taskman_pop = awful.popup {
  widget = taskman_container,
  placement = awful.placement.centered,
  ontop = true,
  visible = taskman_pop_vis,
  border_width = 2,
  border_color = beautiful.border_color_active,
}

awesome.connect_signal("signal::taskman", function()
  taskman_pop_vis = not taskman_pop_vis
  taskman_pop.visible = taskman_pop_vis
  taskman_pop.screen = awful.screen.focused()
end)