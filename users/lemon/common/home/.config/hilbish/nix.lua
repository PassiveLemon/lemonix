local commander = require("commander")
local fs = require("fs")

--
-- Nix helpers
--

local function find_in_table(table, value)
  for i, v in ipairs(table) do
    if v == value then
      return i
    end
  end
end

hilbish.alias("nos", "nh os switch ~/Documents/GitHub/lemonix")
hilbish.alias("nhs", "nh home switch ~/Documents/GitHub/lemonix")

-- Nix
hilbish.alias("npr", "nixpkgs-review rev --print-result HEAD")
hilbish.alias("cma", "comma")

-- Well it works, but the point of this was to be faster than nh in terms of eval time and it's so much slower.
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

-- Nix build
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

-- Nix develop
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

-- Nix run
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

-- Nix shell
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

-- Nix flake update
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

-- Nix store prefetch
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

