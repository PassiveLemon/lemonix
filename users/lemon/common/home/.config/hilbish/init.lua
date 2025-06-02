require("nix")

local promptua = require("promptua")
local commander = require("commander")


hilbish.opts.greeting = false
hilbish.opts.motd = false
hilbish.opts.tips = false

promptua.setConfig({
  prompt = {
    icon    = "",
    success = "",
    fail    = "",
  },
})

promptua.setTheme({
  {
    separator = "┃ ",
    format    = "@style@icon@info",
  },
  {
    provider  = "user.name",
    style     = "yellow",
    format    = "@style@icon@info",
  },
  {
    separator = "┃ ",
    format    = "@style@icon@info",
  },
  {
    provider  = "dir.path",
    style     = "blue",
    format    = "@style@icon@info",
  },
  {
    separator = "┃ ",
    format    = "@style@icon@info",
  },
  {
		provider = "command.execTime",
		style    = "magenta",
	},
	{
    provider = "command.execTimeBool",
    separator = "┃ ",
    format    = "@style@icon@info",
  },
	{
    provider  = "git.branch",
    style     = "red",
    format    = "@style@icon@info",
  },
  { separator = "\n" },
  {
		provider = 'prompt.failSuccess',
		style = function()
			if hilbish.exitCode == 0 then
				return 'bold green'
			else
				return 'bold red'
			end
		end
	},
  {
    separator = ">= ",
    format    = "@style@icon@info",
  },
})

local function get_last_command()
  return hilbish.history.get(hilbish.history.size() - 1)
end

-- Core
hilbish.alias("ls", "eza -lgF --group-directories-first")
hilbish.alias("cat", "bat --theme=Lemon")
hilbish.alias("cdr", "cd $(git rev-parse --show-toplevel)")
hilbish.alias("rmx", "trash")

-- Docker
hilbish.alias("dc", "docker compose")

-- Fuck
commander.register("fuck", function(args)
  if #args == 0 then
    hilbish.run("thefuck " .. get_last_command())
  else
    hilbish.run("thefuck " .. args[1])
  end
end)

promptua.init()

