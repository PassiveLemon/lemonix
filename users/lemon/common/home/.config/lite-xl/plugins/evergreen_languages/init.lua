-- mod-version: 3

local languages = {
  "html",
  "html_tags",
  "lua",
  "nim",
  -- "nix", -- Very unstable
  "python"
}

for _, lang in ipairs(languages) do
  require("plugins.evergreen_languages.evergreen_" .. lang)
end

