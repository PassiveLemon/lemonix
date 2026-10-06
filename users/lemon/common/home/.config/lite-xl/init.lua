require("user")

local core = require("core")
local config = require("core.config")
local keymap = require("core.keymap")
local style = require("core.style")
local docview = require("core.docview")

core.reload_module("colors.lemon")

style.font = renderer.font.load(USERDIR .. "/fonts/FiraCodeNerdFont-Retina.ttf", 14 * SCALE)
style.code_font = renderer.font.load(USERDIR .. "/fonts/FiraCodeNerdFontMono-Retina.ttf", 14 * SCALE)

keymap.add({
  ["ctrl+k"] = "doc:delete-lines",
  ["ctrl+shift+r"] = "core:restart",
  ["ctrl+shift+c"] = "core:find-command",
  ["ctrl+shift+x"] = "open-file-location:open-file-location",
  ["ctrl+shift+space"] = "lemon:open-working-in-terminal",
  ["ctrl+shift+o"] = "lemon:open-working-as-project",
  ["ctrl+shift+p"] = "lemon:open-repo-as-project",
  ["ctrl+shift+l"] = "lemon:open-default-as-project",
})

config.ignore_files = {
  "^%.git/", "^%.hg/",
  "^node_modules/", "^%.cache/", "^__pycache__/",
  "^desktop%.ini$", "^%.DS_Store$", "^%.directory$",
}

config.message_timeout = 2

-- Someday these will actually do something...
config.plugins.treeview = {
  highlight_focused_file = true,
  expand_dirs_to_focused_file = true,
  scroll_to_focused_file = true,
  animate_scroll_to_focused_file = true,
}

config.plugins.evergreen = {
  warnFallbackColors = false,
  maxParseTime = 10000
}

-- Disable stonks
core.status_view:get_item("doc:lines").get_item = function()
  local dv = core.active_view
  return { style.text, #dv.doc.lines, " lines" }
end

-- Put the save asterisk before the name
function docview:get_name()
  local post = self.doc:is_dirty() and "*" or ""
  local name = self.doc:get_name()
  return post .. name:match("[^/%\\]*$")
end

