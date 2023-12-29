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


function get_last_command()
  return hilbish.history.get(hilbish.history.size() - 1)
end

function test_file(file, callback)
  if type(file) ~= "string" then
    return false
  end
  return os.rename(file, file) and true or false
end

local shell_check = function()
  if test_file("shell.nix") then
    hilbish.run("nix-shell")
  end
end

function catch_register()
  bait.catch("cd", shell_check)
end

function catch_release()
  bait.release("cd", shell_check)
end

function run_and_return(dir, cmd)
  catch_release() -- Needed to avoid shell checking when running the nix flake update (nfu) command
  hilbish.run("cd " .. dir)
  hilbish.run(cmd)
  hilbish.run("cd -")
  catch_register()
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
	hilbish.run("thefuck " .. get_last_command())
end)

promptua.init()
catch_register()
