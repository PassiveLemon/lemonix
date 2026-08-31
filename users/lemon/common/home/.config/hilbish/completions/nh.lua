local c = require("completions.common")

local nh_comps = {
  -- `nh --help`
  ["clean"] = {
    "all",
    "profile",
    "user",
  },
  ["darwin"] = {
    "build",
    "repl",
    "switch",
  },
  ["home"] = {
    "build",
    "repl",
    "switch",
  },
  ["os"] = {
    "boot",
    "build",
    "build-image",
    "build-vm",
    "info",
    "repl",
    "rollback",
    "switch",
    "test",
  },
  ["search"] = {
    "issues",
    "offline",
    "options",
    "packages",
    "prs",
  },
}

hilbish.completions.add("command.nh", function(query, ctx, fields)
  return c.sub_completion(query, ctx, fields, nh_comps)
end)

