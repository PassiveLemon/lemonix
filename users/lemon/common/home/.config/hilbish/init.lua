local lunacolors = require('lunacolors')
local bait  = require('bait')
local commander = require 'commander'
local promptua = require('promptua')

hilbish.opts.greeting = false
hilbish.opts.motd = false

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
})

local function find_in_table(table, value)
  for i, v in ipairs(table) do
    if v == value then
      return i
    end
  end
end

local function get_last_command()
  return hilbish.history.get(hilbish.history.size() - 1)
end

local function test_file(file, callback)
  if type(file) ~= "string" then
    return false
  end
  return os.rename(file, file) and true or false
end

local function shell_check()
  if test_file("shell.nix") then
    hilbish.run("nix-shell")
  end
end

local function catch_register()
  bait.catch("cd", shell_check)
end

local function catch_release()
  bait.release("cd", shell_check)
end

local function run_and_return(dir, cmd)
  catch_release() -- Needed to avoid shell checking when running the nix flake update (nfu) command
  hilbish.run("cd " .. dir)
  hilbish.run(cmd)
  hilbish.run("cd -")
  catch_register()
end

hilbish.alias("ls", "eza -lg --group-directories-first") -- -F is current broken
hilbish.alias("cat", "bat --theme=Lemon")
hilbish.alias("pc", 'python -ic "from __future__ import division; from math import *"')
hilbish.alias("tp", "trash put")
hilbish.alias("tr", "trash restore")
hilbish.alias("rm", "trash")
hilbish.alias("nrs", "sudo nixos-rebuild switch")
hilbish.alias("hms", "home-manager switch --flake ~/Documents/GitHub/lemonix#" .. hilbish.user .. "@" .. hilbish.host)

commander.register("nfu", function()
	run_and_return("/etc/nixos/", "nix flake update")
end)

commander.register("fuck", function(args)
  if #args == 0 then
    hilbish.run("thefuck " .. get_last_command())
  else
    hilbish.run("thefuck " .. args[1])
  end
end)

commander.register("nsp", function(args)
  types = { "md5", "sha1", "sha256", "sha512" }

  local type = args[1]
  local url = args[2]

  if #args < 2 then
    hilbish.run("echo 'Not enough arguments: nsp (hash-type) (url)'")
    return 1
  elseif #args > 2 then
    hilbish.run("echo 'Too many arguments: nsp (hash-type) (url)'")
    return 1
  end
  if find_in_table(types, type) then
    hilbish.run("nix store prefetch-file --hash-type " .. type .. " " .. url)
    return 0
  else
    hilbish.run("echo 'Unrecognized hash-type: '" .. type)
    return 1
  end
end)

promptua.init()
catch_register()
