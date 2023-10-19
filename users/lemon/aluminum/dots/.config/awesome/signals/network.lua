local awful = require("awful")

--
-- Network watches
--

-- Separate down and up

awful.widget.watch("echo", 5, function()
  awful.spawn.easy_async_with_shell([[sh -c 'ip -s link show wlo1 | awk '\''/RX:/{getline; rx=$1} /TX:/{getline; tx=$1} END{printf "%sB/%sB\n", convert(rx), convert(tx)} function convert(val) {suffix="BKMGTPE"; for(i=1; val>1024; i++) val/=1024; return int(val+0.5) substr(suffix, i, 1)}'\']], function(total)
    local total = total:gsub("\n", "")
    awesome.emit_signal("signal::network", total)
  end)
end)
