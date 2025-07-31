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

-- Will be deprecated because nh is slower than regular nix cmds, but keeping them here for a bit. Maybe something improves in the future?
hilbish.alias("nos", "nh os switch ~/Documents/GitHub/lemonix")
hilbish.alias("nhs", "nh home switch ~/Documents/GitHub/lemonix")

-- Nix
hilbish.alias("npr", "nixpkgs-review rev --print-result HEAD")
hilbish.alias("cma", "comma")

-- commander.register("nos", function()
--   print("Building NixOS configuration...")
--   local code1 = hilbish.run("sudo -v")
--   -- TODO: Somehow hide the commands outputs
--   if code1 == 0 then
--     local code2 = hilbish.run("sudo nixos-rebuild switch --fast --flake ~/Documents/GitHub/lemonix#" .. hilbish.host .. " --log-format internal-json -v |& nom --json")
--     if code2 == 0 then
--       -- After building, determine the current and previous profile to diff
--       local profiles = fs.readdir("/nix/var/nix/profiles/")
--       local code3, current_path = hilbish.run("realpath /nix/var/nix/profiles/system", false)
--       local current_path_clean = current_path:match("^%s*(.-)%s*$")
--       local current_profile = 0
--       for _, v in ipairs(profiles) do
--         local code4, realpath = hilbish.run("realpath /nix/var/nix/profiles/" .. v)
--         local realpath_clean = realpath:match("^%s*(.-)%s*$")
--         -- These don't fucking match for some god damn reason, even though they look the exact same after trimming whitespace
--         if code4 == 0 and current_path_clean == realpath_clean then
--           print("match")
--           current_profile = v:match("^system%-(%d+)%-link$")
--           break
--         end
--       end
--       local code5, previous_profile = hilbish.run("realpath /nix/var/nix/profiles/system-" .. (current_profile -1) .. "-link" )
--       if code3 == 0 and code5 == 0 then
--         print("test1-" .. previous_profile)
--         print("test2-" .. current_profile)
--         print("Comparing diff...")
--         hilbish.run("dix " .. previous_profile .. " " .. current_profile)
--       else
--         print("Failed to determine current and/or latest profiles.")
--       end
--     end
--   else
--     print("Failed to elevate priviledges.")
--   end
-- end)

-- commander.register("nhs", function()
--   print("Building Home-Manager configuration...")

--   -- Get previous Home-Manager generation path for diff
--   local code, stdout = hilbish.run("realpath /home/" .. hilbish.user .. "/.local/state/nix/profiles/home-manager", false)

--   hilbish.run("home-manager switch --flake ~/Documents/GitHub/lemonix#" .. hilbish.user .. "@" .. hilbish.host .. " --log-format internal-json -v |& nom --json")

--   print("Visualing diff...")
--   hilbish.run("nvd " .. stdout .. " /home/" .. hilbish.user .. "/.local/state/nix/profiles/home-manager")
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

