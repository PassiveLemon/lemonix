require("user")

local core = require("core")
local config = require("core.config")
local keymap = require("core.keymap")
local style = require("core.style")

local lintplus = require("plugins.lintplus")
local lspconfig = require("plugins.lsp.config")

core.reload_module("colors.lemon")

style.font = renderer.font.load(USERDIR .. "/fonts/FiraCodeNerdFont-Retina.ttf", 14 * SCALE)
style.code_font = renderer.font.load(USERDIR .. "/fonts/FiraCodeNerdFontMono-Retina.ttf", 14 * SCALE)

keymap.add({
	["ctrl+shift+r"] = "core:restart",
	["ctrl+shift+c"] = "core:find-command",
	["ctrl+shift+t"] = "terminal:toggle-drawer",
	["ctrl+shift+x"] = "open-file-location:open-file-location",
})

core.status_view:get_item("doc:lines").get_item = function()
  local dv = core.active_view
  return {
    style.text, #dv.doc.lines, " lines",
  }
end

config.ignore_files = {
  "^%.git/", "^%.hg/",
  "^node_modules/", "^%.cache/", "^__pycache__/",
  "^desktop%.ini$", "^%.DS_Store$", "^%.directory$",
}

config.plugins.exterm = {
  executable = "tym",
  keymap_project = "ctrl+shift+p",
  keymap_working = "ctrl+shift+space",
}

config.plugins.treeview = {
  highlight_focused_file = true,
  expand_dirs_to_focused_file = true,
  scroll_to_focused_file = true,
  animate_scroll_to_focused_file = true,
}

config.plugins.evergreen.warnFallbackColors = false

lintplus.load({ "luacheck", "python", "shellcheck" })

lspconfig.bashls.setup()
lspconfig.dockerls.setup()
lspconfig.nillsp.setup()
lspconfig.nimlsp.setup()
lspconfig.pyright.setup()
lspconfig.yamlls.setup()
lspconfig.sumneko_lua.setup({
  name = "lua-language-server",
  language = "lua",
  file_patterns = { "%.lua$" },
  command = { "lua-language-server", "--configpath", "/home/lemon/Documents/GitHub/lemonix/.luarc.json" }
})

-- Open GitHub project dir by default
local default_path = "/home/lemon/Documents/GitHub"
if not core.switched_to_default_dir then
  core.switched_to_default_dir = true
  if core.project_dir ~= default_path then
    core.open_folder_project(default_path)
  end
end

