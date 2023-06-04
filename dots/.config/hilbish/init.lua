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
    provider  = "user.name",
    style     = "greyBg white",
    separator = "@",
    format    = "@style @icon@info ",
  },
  {
    provider  = "user.hostname",
    style     = "greyBg white",
    separator = "|",
    format    = "@style @icon@info ",
  },
  {
    provider  = "dir.path",
    style     = "greyBg white",
    separator = "",
    format    = "@style @icon@info ",
  },
  { separator = "\n" },
  {
		provider = 'prompt.failSuccess',
		style = function(info)
			if hilbish.exitCode ~= 0 then
				return 'bold red'
			else
				return 'bold green'
			end
		end
	},
  { separator = ">= " },
}

promptua.init()

hilbish.alias("ls", "exa -F -l --group-directories-first")
hilbish.alias("rm", "trash")

hilbish.opts.greeting = false
hilbish.opts.motd = false