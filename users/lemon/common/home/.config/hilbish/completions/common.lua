local common = { }

function common.manual_completion(query, _, _, comp_table)
  local matches = { }
  for k, v in pairs(comp_table) do
    if (type(k) == "string") and k:match("^" .. query) then
      table.insert(matches, k)
    elseif (type(v) == "string") and v:match("^" .. query) then
      table.insert(matches, v)
    end
  end
  return matches, query
end

function common.sub_completion(query, ctx, fields, comp_table)
  if #fields <= 3 then
    for k, _ in pairs(comp_table) do
      if fields[2] == k then
        local comps, pfx = common.manual_completion(query, ctx, fields, comp_table[k])
        local compGroup = {
          items = comps,
          type = "grid",
        }
        return { compGroup }, pfx
      end
    end
    local comps, pfx = common.manual_completion(query, ctx, fields, comp_table)
    local compGroup = {
      items = comps,
      type = "grid",
    }
    return { compGroup }, pfx
  else
    local comps, pfx = hilbish.completions.files(query, ctx, fields)
    local compGroup = {
      items = comps,
      type = "grid",
    }
    return { compGroup }, pfx
  end
end

return common

