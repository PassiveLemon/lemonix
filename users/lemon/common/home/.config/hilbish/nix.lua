local commander = require("commander")
local fs = require("fs")

--
-- Nix helpers
--

-- TODO: Make a program for these

-- General helper functions
local function find_in_table(table, value)
  for i, v in ipairs(table) do
    if v == value then
      return i
    end
  end
end

-- Nix command helper functions
local function help_check(args, subcmd)
  local arg1 = tostring(args[1] or "")
  if (arg1 == "--help") or (arg1 == "-h") then
    hilbish.run("nix " .. subcmd .. " --help")
    return 0
  end
end

local function build_args(args)
  local args_str = ""
  for k, _ in pairs(args) do
    local arg = tostring(args[k] or "")
    if string.find(arg, "#") then
      args_str = args_str .. arg
    else
      args_str = args_str .. " .#" .. arg
    end
    args_str = args_str .. " "
  end
  return args_str
end

local function simple_arg(args, subcmd)
  if (#args > 1) and subcmd then
    hilbish.run("echo 'Too many arguments: " .. subcmd .. "'")
    return 1
  end
  local arg1 = tostring(args[1] or "")
  local args_str = ".#" .. arg1
  if string.find(arg1, "#") then
    args_str = arg1
  end
  return args_str
end

-- Nix related aliases
hilbish.alias("nos", "nh os switch ~/Documents/GitHub/lemonix")
hilbish.alias("nhs", "nh home switch ~/Documents/GitHub/lemonix")
hilbish.alias("npr", "nixpkgs-review rev --print-result HEAD")
hilbish.alias("cma", "comma")

-- Nix build
commander.register("nb", function(args)
  help_check(args, "build")

  local args_str = build_args(args)

  hilbish.run("nix build " .. args_str)
end)

-- Nix develop
commander.register("nd", function(args)
  help_check(args, "develop")

  local args_str = simple_arg(args, "nd (installable)")

  hilbish.run("nix develop " .. args_str)
end)

-- Nix run
commander.register("nr", function(args)
  help_check(args, "run")

  local arg_struct = {
    simple_arg(args),
    "--",
    table.concat(args, " ", 2),
  }
  local args_str = table.concat(arg_struct, " ")

  hilbish.run("nix run " .. args_str)
end)

-- Nix shell
commander.register("ns", function(args)
  help_check(args, "shell")

  local args_str = build_args(args)

  hilbish.run("nix shell " .. args_str)
end)

-- Nix flake update
commander.register("nfu", function(args)
  help_check(args, "flake update")

  local args_str = table.concat(args, " ")

  hilbish.run("nix flake update " .. args_str)
end)

-- Nix store prefetch
commander.register("nsp", function(args)
  help_check(args, "store prefetch-file")

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

