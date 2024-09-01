-- mod-version:3 -- lite-xl 2.1

-----------------------------------------------------------------------
-- NAME       : External Terminal
-- DESCRIPTION: A plugin to open an external terminal
-- AUTHOR     : Shady Goat
-- GOALS      : Open an external terminal in the project directory
-- SHORT NAME : exterm
-----------------------------------------------------------------------

-- MODIFIED   : PassiveLemon
-- Compatibility is only tested on Linux

local core = require "core"
local keymap = require "core.keymap"
local config = require "core.config"
local plugins = config.plugins
local os = require "os"
local command = require "core.command"
local common = require "core.common"

plugins.exterm = common.merge({
  executable = "cmd",
  -- Compatibility
  keymap_project = plugins.exterm.keymap or "ctrl+shift+v",
  keymap_working = "ctrl+shift+space",
}, plugins.exterm)

if plugins.exterm.keymap then
  core.warn("Exterm: 'keymap' is a deprecated option. Please use 'keymap_project' instead.")
end

command.add(nil, {
  ["exterm:open-terminal-in-project"] = function()
    if PLATFORM == "Windows" then
      os.execute('start "" ' .. plugins.exterm.executable)
    elseif PLATFORM == "Linux" or PLATFORM == "Mac OS X" then
      os.execute(plugins.exterm.executable .. " &")
    else
      core.error("Exterm: Platform not supported")  
    end
  end
})

command.add("core.docview!", {
  ["exterm:open-terminal-in-working"] = function(dv)
    local working = common.dirname(dv.doc.filename)
    if PLATFORM == "Windows" then
      os.execute('start "" ' .. plugins.exterm.executable)
    elseif PLATFORM == "Linux" or PLATFORM == "Mac OS X" then
      os.execute("cd " .. working .. "; " .. plugins.exterm.executable .. " &")
    else
      core.error("Exterm: Platform not supported")  
    end
  end
})

keymap.add({
  [ plugins.exterm.keymap_project ] = "exterm:open-terminal-in-project",
  [ plugins.exterm.keymap_working ] = "exterm:open-terminal-in-working",
})

local settings = nil
if pcall(require, "plugins.settings") then
  settings = require("plugins.settings")
end

if settings then
  settings.add("External Terminal", {
    {
      label = "Project Shortcut",
      description = "The shortcut to run the terminal in the project directory",
      path = "keymap_project",
      default = "ctrl+shift+space",
      type = settings.type.STRING,
    },
    {
      label = "Working Shortcut",
      description = "The shortcut to run the terminal in the working directory",
      path = "keymap_working",
      default = "ctrl+shift+alt",
      type = settings.type.STRING,
    },
    {
      label = "Executable",
      description = "The command to run to open the terminal",
      path = "executable",
      type = settings.type.STRING,
      default = "cmd",
    },
  },
  "exterm")
end

