local lunacolors = require('lunacolors')
local bait  = require('bait')
local commander = require 'commander'
local promptua = require('promptua')

hilbish.opts.greeting = false
hilbish.opts.motd = false

promptua.setConfig {
  prompt = {
    icon    = "",
    success = "",
    fail    = "",
  },
}

promptua.setTheme {
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

function get_last_command()
  return hilbish.history.get(hilbish.history.size() - 1)
end

function run_and_return(dir, cmd)
  hilbish.run("cd " .. dir)
  hilbish.run(cmd)
  hilbish.run("cd -")
end

hilbish.alias("ls", "eza -Fl --group-directories-first")
hilbish.alias("cat", "bat --theme=Lemon")
hilbish.alias("tp", "trash put")
hilbish.alias("tr", "trash restore")
hilbish.alias("rm", "trash")
hilbish.alias("nrs", "sudo nixos-rebuild switch")
hilbish.alias("hms", "home-manager switch --flake ~/Documents/GitHub/lemonix#" .. hilbish.user .. "@" .. hilbish.host)

commander.register("nfu", function()
	run_and_return("/etc/nixos/", "nix flake update")
end)

commander.register("fuck", function()
	os.execute("thefuck " .. get_last_command())
end)
