local commander = require("commander")
local fs = require("fs")

--
-- Nix helpers
--

-- General helper functions
local function find_in_table(table, value)
  for i, v in ipairs(table) do
    if v == value then
      return i
    end
  end
end

local function concat_string(str, new)
  str = str .. new
end

-- Nix command helper functions
local function help_check(args, subcommand)
  local arg1 = tostring(args[1] or "")
  if (arg1 == "--help") or (arg1 == "-h") then
    hilbish.run("nix " .. subcommand .. " --help")
    return 0
  end
end

local function build_args(args)
  local args_str = ""
  for k, _ in pairs(args) do
    local arg = tostring(args[k] or "")
    if string.find(arg, "#") then
      concat_string(args_str, arg)
    else
      concat_string(args_str, " .#" .. arg)
    end
    concat_string(args_str, " ")
  end
  return args_str
end

local function simple_arg(args, subcommand)
  if (#args > 1) and subcommand then
    hilbish.run("echo 'Too many arguments: " .. subcommand .. "'")
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

-- Well it works, but the point of this was to be faster than nh in terms of eval time but it's so much slower.
-- commander.register("nos", function()
--   print("Building NixOS configuration...")
--   local code1 = hilbish.run("sudo -v")
--   -- TODO: Somehow hide the debug outputs
--   if code1 == 0 then
--     local code2 = hilbish.run("sudo nixos-rebuild switch --flake ~/Documents/GitHub/lemonix#" .. hilbish.host .. " --log-format internal-json -v |& grep -v '^debug: nixos_rebuild' |& nom --json")
--     if code2 == 0 then
--       -- After building, determine the current and new profile to diff
--       local profiles = fs.readdir("/nix/var/nix/profiles/")
--       local code3, new_path = hilbish.run("realpath /nix/var/nix/profiles/system", false)
--       local new_path_clean = new_path:match("%s*(%S+)%s*")
--       local current_path, current_profile
--       for _, profile in ipairs(profiles) do
--         -- Find the new system-xxx-link path
--         if profile:find("%d+") then
--           local code4, test_path = hilbish.run("realpath /nix/var/nix/profiles/" .. profile, false)
--           local test_path_clean = test_path:match("%s*(%S+)%s*")
--           if code4 == 0 and test_path_clean == new_path_clean then
--             current_path = test_path_clean
--             current_profile = profile:match("%s*system%-(%S+)%-link%s*")
--             break
--           end
--         end
--       end
--       -- Diff the old profile with the new profile
--       local code5, previous_profile = hilbish.run("realpath /nix/var/nix/profiles/system-" .. (tonumber(current_profile) - 1) .. "-link", false)
--       local previous_profile_clean = previous_profile:match("%s*(%S+)%s*")
--       if code3 == 0 and code5 == 0 then
--         print("Comparing diff...")
--         hilbish.run("dix " .. previous_profile_clean .. " " .. current_path)
--       else
--         print("Failed to determine current and/or latest profiles.")
--       end
--     end
--   else
--     print("Failed to elevate priviledges.")
--   end
-- end)

