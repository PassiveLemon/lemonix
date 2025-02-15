local commander = require("commander")
local promptua = require("promptua")

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

hilbish.alias("ls", "eza -lgF --group-directories-first")
hilbish.alias("cat", "bat --theme=Lemon")
hilbish.alias("rmx", "trash")
hilbish.alias("nrs", "sudo nixos-rebuild switch")
hilbish.alias("nos", "nh os switch ~/Documents/GitHub/lemonix")
hilbish.alias("hms", "home-manager switch --flake ~/Documents/GitHub/lemonix#" .. hilbish.user .. "@" .. hilbish.host)
hilbish.alias("nhs", "nh home switch ~/Documents/GitHub/lemonix")
hilbish.alias("npr", "nixpkgs-review rev --print-result HEAD")
hilbish.alias("cma", "comma")
hilbish.alias("dc", "docker compose")

commander.register("nb", function(args)
  if (args[1] == "--help") or (args[1] == "-h") then
    hilbish.run("nix build --help")
    return 0
  end

  local args_str = ""
  for k, _ in pairs(args) do
    if string.find(tostring(args[k]), "#") then
      args_str = args_str .. tostring(args[k])
    else
      args_str = args_str .. " .#" .. tostring((args[k] or ""))
    end
  end

  hilbish.run("nix build " .. args_str)
end)

commander.register("nd", function(args)
  if #args > 1 then
    hilbish.run("echo 'Too many arguments: nd (installable)'")
    return 1
  end
  if (args[1] == "--help") or (args[1] == "-h") then
    hilbish.run("nix develop --help")
    return 0
  end

  local args_str = ""
  if string.find(tostring(args[1]), "#") then
    args_str = tostring(args[1])
  else
    args_str = ".#" .. tostring((args[1] or ""))
  end

  hilbish.run("nix develop " .. args_str)
end)

commander.register("nfu", function(args)
  if (args[1] == "--help") or (args[1] == "-h") then
    hilbish.run("nix flake update --help")
    return 0
  end

  local args_str = ""
  for k, _ in pairs(args) do
    args_str = args_str .. " " .. tostring(args[k])
  end

  hilbish.run("nix flake update" .. args_str)
end)

commander.register("nr", function(args)
  if (args[1] == "--help") or (args[1] == "-h") then
    hilbish.run("nix run --help")
    return 0
  end

  local args_str = ""
  if string.find(tostring(args[1]), "#") then
    args_str = tostring(args[1])
  else
    args_str = ".#" .. tostring((args[1] or ""))
  end
  args_str = args_str .. " --"
  for k, _ in pairs(args) do
    if k > 1 then
      args_str = args_str .. " " .. tostring(args[k])
    end
  end

  hilbish.run("nix run " .. args_str)
end)

commander.register("ns", function(args)
  if (args[1] == "--help") or (args[1] == "-h") then
    hilbish.run("nix shell --help")
    return 0
  end

  local args_str = ""
  for k, _ in pairs(args) do
    if string.find(tostring(args[k]), "#") then
      args_str = args_str .. tostring(args[k])
    else
      args_str = args_str .. " nixpkgs#" .. tostring((args[k] or ""))
    end
  end

  hilbish.run("nix shell" .. args_str)
end)

commander.register("nsp", function(args)
  local types = { "md5", "sha1", "sha256", "sha512" }

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

commander.register("fuck", function(args)
  if #args == 0 then
    hilbish.run("thefuck " .. get_last_command())
  else
    hilbish.run("thefuck " .. args[1])
  end
end)

promptua.init()

