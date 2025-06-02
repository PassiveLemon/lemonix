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

--   -- Get previous NixOS generation path for diff
--   local code1, before = hilbish.run("realpath /nix/var/nix/profiles/system", false)
--   print("1" .. before)
--   if code1 then
--     hilbish.run("sudo -v")
--     -- TODO: build and then switch later
--     -- If line starts with $ then remove it
--     local code2 = hilbish.run("sudo nixos-rebuild switch --flake ~/Documents/GitHub/lemonix#" .. hilbish.host .. " --log-format internal-json -v |& nom --json")
--     if code2 then
--       local code3, after = hilbish.run("realpath /nix/var/nix/profiles/system", false)
--       if code3 then
--         print("Comparing diff...")
--         print("2" .. before)
--         print("3" .. after)
--         hilbish.run("nvd diff " .. before .. " " .. after)
--       else
--         print("Failed to compare diff.")
--       end
--     else
--       print("Failed to switch to newly built profile.")
--     end
--   else
--     print("Failed to determine current system generation.")
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

