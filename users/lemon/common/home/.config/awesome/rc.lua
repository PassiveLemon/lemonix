local b = require("beautiful")
b.init(os.getenv("HOME") .. "/.config/awesome/config/theme.lua")

terminal = "tym"
browser = "firefox"
editor = os.getenv("EDITOR") or "nano"
visual_editor = "code"
editor_cmd = terminal .. " -e " .. editor

require("config")
require("signal")
require("ui")
