local lunacolors = require('lunacolors')
local bait  = require('bait')
local promptua = require('promptua')

promptua.setConfig {
  prompt = {
    icon    = "",
    success = "",
    fail    = "",
  },
}

promptua.setTheme {
  { 
    separator = "│ ",
    format    = "@style@icon@info",
  },
  {
    provider  = "user.name",
    style     = "yellow",
    format    = "@style@icon@info",
  },
  { 
    separator = "│ ",
    format    = "@style@icon@info",
  },
  {
    provider  = "dir.path",
    style     = "blue",
    format    = "@style@icon@info",
  },
  { 
    separator = "│ ",
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
		style = function(info)
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
}

promptua.init()

hilbish.alias("ls", "exa -F -l --group-directories-first")
hilbish.alias("tp", "trash put")
hilbish.alias("tr", "trash restore")
hilbish.alias("rm", "trash")
hilbish.alias("nrs", "sudo nixos-rebuild switch")
hilbish.alias("hms", "home-manager switch --flake ~/Documents/GitHub/lemonix#$USER@silver")

hilbish.opts.greeting = false
hilbish.opts.motd = false
