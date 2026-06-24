--
-- Completions
--

local function manual_completion(query, _, _, comp_table)
  local matches = { }
  for _, v in ipairs(comp_table) do
    if v:match("^" .. query) then
      table.insert(matches, v)
    end
  end
  return matches, query
end

-- Nix
local nix_comps = {
  -- `nix --help`
  -- Help
  "help",
  "help-stores",
  -- Main
  "build",
  "develop",
  "flake",
  "profile",
  "run",
  "search",
  "repl",
  -- Infrequent
  "bundle",
  "copy",
  "edit",
  "eval",
  "fmt",
  "formatter",
  "log",
  "path-info",
  "registry",
  "why-depends",
  -- Utility/scripting
  "config",
  "daemon",
  "derivation",
  "env",
  "hash",
  "key",
  "nar",
  "print-dev-env",
  "realisation",
  "store",
  "upgrade-nix",
}
hilbish.completions.add('command.nix', function(query, ctx, fields)
  if #fields <= 2 then
    local comps, pfx = manual_completion(query, ctx, fields, nix_comps)
    local compGroup = {
      items = comps,
      type = 'grid'
    }
    return { compGroup }, pfx
  else
    local comps, pfx = hilbish.completions.files(query, ctx, fields)
    local compGroup = {
      items = comps,
      type = 'grid'
    }
    return { compGroup }, pfx
  end
end)

-- Docker
-- Could probably deduplicate the normal and compose commands
local docker_comps = {
  -- `docker --help`
  -- Common
  "run",
  "exec",
  "ps",
  "build",
  "bake",
  "pull",
  "push",
  "images",
  "login",
  "logout",
  "search",
  "version",
  "info",
  -- Management
  "builder",
  "buildx",
  "compose",
  "container",
  "context",
  "image",
  "manifest",
  "network",
  "plugin",
  "system",
  "volume",
  -- Swarm
  "swarm",
  -- Main
  "attach",
  "commit",
  "cp",
  "create",
  "diff",
  "events",
  "export",
  "history",
  "import",
  "inspect",
  "kill",
  "load",
  "logs",
  "pause",
  "port",
  "rename",
  "restart",
  "rm",
  "rmi",
  "save",
  "start",
  "stats",
  "stop",
  "tag",
  "top",
  "unpause",
  "update",
  "wait",
}
local docker_comps_buildx = {
  -- `docker buildx --help`
  -- Management
  "history",
  "imagetools",
  "policy",
  -- Main
  "bake",
  "build",
  "create",
  "dial-stdio",
  "du",
  "inspect",
  "ls",
  "prune",
  "rm",
  "stop",
  "use",
  "version",
}
local docker_comps_compose = {
  -- `docker compose --help`
  -- Management
  "bridge",
  -- Main
  "attach",
  "build",
  "commit",
  "config",
  "cp",
  "create",
  "down",
  "events",
  "exec",
  "export",
  "images",
  "wait",
  "kill",
  "logs",
  "ls",
  "pause",
  "port",
  "ps",
  "publish",
  "pull",
  "push",
  "restart",
  "rm",
  "run",
  "scale",
  "start",
  "stats",
  "stop",
  "top",
  "unpause",
  "up",
  "version",
  "volumes",
  "wait",
  "watch",
}
hilbish.completions.add('command.docker', function(query, ctx, fields)
  if #fields <= 3 then
    if fields[2] == "buildx" then
      local comps, pfx = manual_completion(query, ctx, fields, docker_comps_buildx)
      local compGroup = {
        items = comps,
        type = 'grid'
      }
      return { compGroup }, pfx
    elseif fields[2] == "compose" then
      local comps, pfx = manual_completion(query, ctx, fields, docker_comps_compose)
      local compGroup = {
        items = comps,
        type = 'grid'
      }
      return { compGroup }, pfx
    else
      local comps, pfx = manual_completion(query, ctx, fields, docker_comps)
      local compGroup = {
        items = comps,
        type = 'grid'
      }
      return { compGroup }, pfx
    end
  else
    local comps, pfx = hilbish.completions.files(query, ctx, fields)
    local compGroup = {
      items = comps,
      type = 'grid'
    }
    return { compGroup }, pfx
  end
end)

-- Trash
local trash_comps = {
  -- `trash --help`
  "list",
  "put",
  "empty",
  "restore",
  "help",
}
hilbish.completions.add('command.trash', function(query, ctx, fields)
  if #fields <= 2 then
    local comps, pfx = manual_completion(query, ctx, fields, trash_comps)
    local compGroup = {
      items = comps,
      type = 'grid'
    }
    return { compGroup }, pfx
  else
    local comps, pfx = hilbish.completions.files(query, ctx, fields)
    local compGroup = {
      items = comps,
      type = 'grid'
    }
    return { compGroup }, pfx
  end
end)

