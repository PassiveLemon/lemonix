local core = require("core")
local keymap = require("core.keymap")
local config = require("core.config")
local style = require("core.style")

local lintplus = require("plugins.lintplus")

core.reload_module("colors.lemon")

style.font = renderer.font.load(USERDIR .. "/fonts/FiraCodeNerdFont-Retina.ttf", 14 * SCALE)
style.code_font = renderer.font.load(USERDIR .. "/fonts/FiraCodeNerdFontMono-Retina.ttf", 14 * SCALE)

keymap.add_direct {
	["ctrl+shift+r"] = "core:restart",
	["ctrl+shift+space"] = "exterm:open-terminal",
	["ctrl+shift+x"] = "open-file-location:open-file-location",
}

config.fps = 144
config.animation_rate = 1.0
config.mouse_wheel_scroll = 70 * SCALE
config.ignore_files = {
  "^%.git/",   "^%.hg/",
  "^node_modules/", "^%.cache/", "^__pycache__/",
  "^desktop%.ini$", "^%.DS_Store$", "^%.directory$",
}

config.plugins.exterm = {
  executable = "tym",
  keymap = nil,
}

config.plugins.treeview = {
  highlight_focused_file = true,
  expand_dirs_to_focused_file = true,
  scroll_to_focused_file = true,
  animate_scroll_to_focused_file = true,
}

lintplus.load({"luacheck", "python", "shellcheck"})

-- Open documents by default
local default_path = "/home/lemon/Documents/GitHub"
if not core.switched_to_default_dir then
  core.switched_to_default_dir = true
  if core.project_dir ~= default_path then
    core.open_folder_project(default_path)
  end
end

