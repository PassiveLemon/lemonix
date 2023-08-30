local awful = require("awful")
local wibox = require("wibox")

local helpers = require("helpers")

--
-- Network watches
--

network = { }

network.down = helpers.simplewtch([[sh -c 'ip -s link show enp7s0 | awk '\''/RX:/{getline; rx=$1} END{printf "%sB\n", convert(rx)} function convert(val) {suffix="BKMGTPE"; for(i=1; val>1024; i++) val/=1024; return int(val+0.5) substr(suffix, i, 1)}'\']], 5)
network.up = helpers.simplewtch([[sh -c 'ip -s link show enp7s0 | awk '\''/TX:/{getline; tx=$1} END{printf "%sB\n", convert(tx)} function convert(val) {suffix="BKMGTPE"; for(i=1; val>1024; i++) val/=1024; return int(val+0.5) substr(suffix, i, 1)}'\']], 5)

return network
