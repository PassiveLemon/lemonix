-- mod-version:3

-- Just some simple functions for myself

local core = require("core")
local config = require("core.config")
local command = require("core.command")
local common = require("core.common")
local os = require("os")
local system = require("system")
local view = require "plugins.treeview"

config.plugins.lemon = common.merge({
  default_open = true,
  default_path = os.getenv("HOME") .. "/Documents/GitHub",
}, config.plugins.lemon)

-- Open default path on start
if config.plugins.lemon.default_open and not core.switched_to_default_dir then
  local path = config.plugins.lemon.default_path
  core.switched_to_default_dir = true
  if core.project_dir ~= path then
    core.open_folder_project(path)
  end
end

local function check_path(path)
  path = path:gsub("\n", "")
  local info = system.get_file_info(path)
  if (not info) or (not info.type) then
    core.error("[lemon] Invalid path '%s'", path)
    return nil
  end
  if info.type ~= "dir" then
    path = common.dirname(path)
  end
  return path
end

local function open_terminal(path)
  path = check_path(path)
  if path then
    core.log("[lemon] Opened terminal in '%s'", path)
    os.execute("tym --cwd " .. path .. " &")
  end
end

local function change_project(path)
  path = check_path(path)
  if path then
    if path == core.project_dir then
      core.log("[lemon] Already in '%s'", path)
      return
    end
    core.set_project_dir(path)
    core.add_project_directory(path)
    -- Update the relative filenames after changing project dir
    local prefix = core.project_dir
    for _, doc in ipairs(core.docs) do
      -- Only if it starts with the project dir prefix
      if doc.abs_filename:sub(1, #prefix) == prefix then
        doc.filename = doc.abs_filename:sub(#prefix + 2)
      else
        doc.filename = doc.abs_filename
      end
    end
    core.log("[lemon] Opened project '%s'", path)
    command.perform("lsp:restart-servers")
  end
end

command.add("core.docview!", {
  ["lemon:open-working-in-terminal"] = function(dv)
    local working = common.dirname(dv.doc.abs_filename)
    open_terminal(working)
  end,
  ["lemon:open-working-as-project"] = function(dv)
    local working = dv.doc.abs_filename
    change_project(working)
  end,
  ["lemon:open-repo-as-project"] = function(dv)
    local working = common.dirname(dv.doc.abs_filename)
    local git_args = { "git", "-C", working, "rev-parse", "--show-toplevel" }
    local proc = process.start(git_args)
    if proc then
      -- Ensure that the process exited properly
      local code
      while true do
        code = proc:wait(100)
        if type(code) == "number" then break end
      end
      local repo = proc:read_stdout()
      if code == 0 then
        change_project(repo)
      else
        core.warn("[lemon] Not in Git repository")
      end
    else
      core.error("[lemon] Failed to execute '%s'", table.concat(git_args))
    end
  end,
})

---@diagnostic disable-next-line: param-type-mismatch
command.add(nil, {
  ["lemon:open-default-in-terminal"] = function()
    open_terminal(core.project_dir)
  end,
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

local function open_in_terminal()
  local hovered = view.hovered_item.abs_filename
  open_terminal(hovered)
end

local function open_as_project()
  local hovered = view.hovered_item.abs_filename
  change_project(hovered)
end

command.add(hovering, {
  ["lemon:open-in-terminal"] = open_in_terminal,
  ["lemon:open-as-project"] = open_as_project,
})

menu:register(hovering, {
  { text = "Open in terminal", command = "lemon:open-in-terminal" },
  { text = "Open as project", command = "lemon:open-as-project" },
})

return view

