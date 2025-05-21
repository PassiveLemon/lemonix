-- mod-version: 3

local languages = {
  "containerfile",
  "diff",
  "env",
  "go",
  "ignore",
  "json",
  "make",
  "nim",
  "nix",
  "rust",
  "sh",
  "yaml",
  "zig"
}

for _, lang in ipairs(languages) do
  require("plugins.languages.language_" .. lang)
end

