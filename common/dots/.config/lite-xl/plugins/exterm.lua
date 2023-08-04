-- mod-version:3 -- lite-xl 2.1

-----------------------------------------------------------------------
-- NAME       : External Terminal
-- DESCRIPTION: A plugin to open an external terminal
-- AUTHOR     : Shady Goat
-- GOALS      : Open an external terminal in the project directory
-- SHORT NAME : exterm
-----------------------------------------------------------------------

local core = require "core"
local keymap = require "core.keymap"
local config = require "core.config"
local plugins = config.plugins
local os = require "os"
local command = require "core.command"
local common = require "core.common"

plugins.exterm = common.merge({
  executable = "cmd",
  keymap = "ctrl+shift+space"
}, plugins.exterm)

command.add(nil, {
  ["exterm:open-terminal"] = function()
  -- adds the & for background process, idk if it works for windows
  -- also, it opens in the project dir, since the working dir = project dir, and terminals open in the working dir :)
      if PLATFORM == "Windows" then
        os.execute('start "" ' .. plugins.exterm.executable)
      elseif PLATFORM == "Linux" or PLATFORM == "Mac OS X" then
        os.execute(plugins.exterm.executable .. " &")
      else
        core.error("Exterm: Platform not supported")  
      end
  end
})

keymap.add({[plugins.exterm.keymap] = "exterm:open-terminal"})

local settings = nil
if pcall(require, "plugins.settings") then
  settings = require "plugins.settings"
end

if settings then
  settings.add("External Terminal",
  {
    {
      label = "Shortcut",
      description = "The shortcut to run the terminal",
      path = "keymap",
      default = "ctrl+shift+space",
      type = settings.type.STRING
    },
    {
      label = "Executable",
      description = "The command to run to open the terminal",
      path = "executable",
      type = settings.type.STRING,
      default = "cmd"
    },
  },
  "exterm"
)
end

