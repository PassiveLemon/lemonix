local c = require("completions.common")

local trash_comps = {
  -- `trash --help`
  "list",
  "put",
  "empty",
  "restore",
  "help",
}

hilbish.completions.add("command.trash", function(query, ctx, fields)
  return c.sub_completion(query, ctx, fields, trash_comps)
end)

