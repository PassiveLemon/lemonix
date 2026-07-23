local gears = require("gears")
local naughty = require("naughty")

local h = { }

function h.debug(title, body)
  naughty.notify({ title = tostring(title) or "", text = tostring(body) or "" })
end

function h.table_dump(table)
  if type(table) == "table" then
    local s = "{ "
    for k, v in pairs(table) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. h.table_dump(v) .. ", "
    end
    return s .. "} "
  else
    return tostring(table)
  end
end

function h.table_contains(table, value)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

function h.is_file(file)
  return gears.filesystem.file_readable(file)
end

function h.is_dir(dir)
  return gears.filesystem.is_dir(dir)
end

function h.join_path(...)
  if not ... then return nil end
  local norm_paths = { }
  -- Normalize the input paths to ensure consistent results:
  -- Sanitize inputs
  -- Match and separate paths inside strings ("foo/bar" -> "foo", "bar")
  -- Remove training/leading slashes (keep the leading if it's the first element for root)
  for i = 1, select("#", ...) do
    local path = select(i, ...)
    if type(path) == "string" then
      if i == 1 and (path:match("^/+") or path == "/") then
        table.insert(norm_paths, "")
      end
      for part in path:gmatch("[^/]+") do
        part = part:gsub("^/+", ""):gsub("/+$", "")
        table.insert(norm_paths, part)
      end
    end
  end
  local final_path = table.concat(norm_paths, "/")
  return final_path
end

-- Some test cases
-- -- Plain -> "home/user/documents/file.txt"
-- print(h.join_path("home", "user", "documents", "file.txt"))
-- -- Root leading slash -> "/home/user/documents/file.txt"
-- print(h.join_path("/home", "user", "documents", "file.txt"))
-- -- Trailing/leading slashes -> "home/user/documents/file.txt"
-- print(h.join_path("home", "user/", "/documents", "/file.txt/"))
-- -- Excessive slashes -> "/home/user/documents/file.txt"
-- print(h.join_path("//home////", "user///", "/documents", "file.txt"))
-- -- Spaces -> "home/user/documents/my file.txt"
-- print(h.join_path("home", "user", "documents", "my file.txt"))
-- -- Relatives -> "home/user/pictures/../documents/file.txt"
-- print(h.join_path("home", "user", "pictures", "..", "documents", "file.txt"))
-- -- Bad inputs -> "home/user/documents/file.txt"
-- -- If there's no valid strings, returns empty string
-- print(h.join_path("", "home", true, "user", nil, "documents", 1, "file.txt"))
-- -- No inputs -> nil
-- print(h.join_path())

return h

