local c = require("completions.common")

local hm_comps = {
  -- `home-manager --help`
  "build",
  "edit",
  "expire-generations",
  "generations",
  "help",
  "init",
  "instantiate",
  "news",
  "option",
  "packages",
  "remove-generations",
  "repl",
  "switch",
  "uninstall",
}

hilbish.completions.add("command.home-manager", function(query, ctx, fields)
  return c.sub_completion(query, ctx, fields, hm_comps)
end)

