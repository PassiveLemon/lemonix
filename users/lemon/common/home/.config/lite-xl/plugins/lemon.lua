-- mod-version:3

-- Just some simple functions for myself

local core = require("core")
local config = require("core.config")
local keymap = require("core.keymap")
local command = require("core.command")
local common = require("core.common")
local os = require("os")
local system = require("system")
local view = require "plugins.treeview"

config.plugins.lemon = common.merge({
  default_open = true,
  default_path = os.getenv("HOME") .. "/Documents/GitHub",
}, config.plugins.lemon)

-- Open default path
if config.plugins.lemon.default_open and not core.switched_to_default_dir then
  local path = config.plugins.lemon.default_path
  core.switched_to_default_dir = true
  if core.project_dir ~= path then
    core.open_folder_project(path)
  end
end

-- Commands
keymap.add({
  ["ctrl+shift+space"] = "lemon:open-terminal-in-working",
  ["ctrl+shift+p"] = "lemon:open-working-as-project",
  ["ctrl+shift+l"] = "lemon:open-default-as-project",
})

local function change_project(path)
  if not path then
    core.error("[lemon] Change project called with nil path")
    return
  end
  if path == core.project_dir then
    core.log("[lemon] Already in '%s'", path)
    return
  end
  local info = system.get_file_info(path)
  if (not info) or (not info.type) then
    core.error("[lemon] Invalid path '%s'", path)
    return
  end
  if info.type ~= "dir" then
    path = common.dirname(path)
  end
  -- Given a file structure like /x/y/z and lite-xl opened at /x, if you open /x/y/z in a doc (saving ./y/z) then change project to /x/y, it still tries to save to ./y/z instead of ./z
  -- So, whatever child directory we change to, we need to remove that additional path from the start of the saving path
  -- Similar happens in the reverse case going up parent directories
  local diff = path:match(core.project_dir .. "/(.+)") or core.project_dir:match(path .. "/(.+)")
  -- If there is no diff, the paths are not related and so should be skipped
  if not diff then return end
  for _, doc in ipairs(core.docs) do
    local new_path = doc.filename:match(diff .. "/(.+)") or (diff .. "/" .. doc.filename)
    -- Check for malformed paths
    if new_path:match("//") then
      core.error("[lemon] Malformed path '%s'", new_path)
      return
    end
    doc.filename = new_path
  end
  core.log("[lemon] Opened project '%s'", path)
  core.set_project_dir(path)
  core.add_project_directory(path)
  core.on_enter_project(path)
end

command.add("core.docview!", {
  ["lemon:open-terminal-in-working"] = function(dv)
    local working = common.dirname(dv.doc.abs_filename)
    if not working then return end
    core.log("[lemon] Opened terminal in '%s'", working)
    os.execute("cd " .. working .. "; tym &")
  end,
  ["lemon:open-working-as-project"] = function(dv)
    local working = dv.doc.filename
    change_project(working)
  end,
  ["lemon:open-repo-as-project"] = function()
    local proc = process.start({ "git", "rev-parse", "--show-toplevel" })
    if proc then
      -- Ensure that the process exited properly
      local code
      while true do
        local exit = proc:wait(100)
        if type(exit) == "number" then
          code = exit
          break
        end
      end
      local repo = proc:read_stdout()
      if code == 0 then
        change_project(repo)
      else
        core.warn("[lemon] Not in Git repository")
      end
    else
      core.error("[lemon] Failed to execute 'git rev-parse --show-toplevel'")
    end
  end,

  -- ["lemon:push-project"] = function()
  --   change_project(path)
  -- end,
  -- ["lemon:pop-project"] = function()
  --   change_project(path)
  -- end,
})

---@diagnostic disable-next-line: param-type-mismatch
command.add(nil, {
  ["lemon:open-default-as-project"] = function()
    local default = config.plugins.lemon.default_path
    change_project(default)
  end
})

-- Context menu
local menu = view.contextmenu

local function hovering()
  return view.hovered_item ~= nil
end

local function open_as_project()
  local hovered = view.hovered_item.abs_filename
  change_project(hovered)
end

command.add(hovering, {
  ["lemon:open-as-project"] = open_as_project
})

menu:register(hovering, {
  { text = "Open as project", command = "lemon:open-as-project" }
})

return view

