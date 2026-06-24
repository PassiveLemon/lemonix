require("completions")
require("nix")

local promptua = require("promptua")

hilbish.opts.greeting = false
hilbish.opts.motd = false

hilbish.runner.setCurrent = "hybridRev"

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
    provider  = "git.dirty",
    icon      = "*",
    style     = "red",
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

-- Core
hilbish.alias("ls", "eza -lgF --group-directories-first")
hilbish.alias("cat", "bat --theme=Lemon")
hilbish.alias("cdr", "cd $(git rev-parse --show-toplevel)")
hilbish.alias("rmx", "trash")

-- Nix
hilbish.alias("nos", "nh os switch ~/Documents/GitHub/lemonix")
hilbish.alias("nhs", "nh home switch ~/Documents/GitHub/lemonix")
hilbish.alias("npr", "nixpkgs-review rev --print-result HEAD")
hilbish.alias("cma", "comma")

-- Docker
hilbish.alias("dc", "docker compose")

promptua.init()

