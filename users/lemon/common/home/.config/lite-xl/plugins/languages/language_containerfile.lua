-- mod-version:3
local syntax = require "core.syntax"

local function merge_tables(a, b)
  for _, v in pairs(b) do
    table.insert(a, v)
  end
end

local default_symbols = {
  ["FROM"]    = "keyword",
  ["AS"]      = "keyword",
  ["ARG"]     = "keyword",
  ["ENV"]     = "keyword",
  ["RUN"]     = "keyword",
  ["ADD"]     = "keyword",
  ["COPY"]    = "keyword",
  ["WORKDIR"] = "keyword",
  ["USER"]    = "keyword",
  ["LABEL"]   = "keyword",
  ["EXPOSE"]  = "keyword",
  ["VOLUME"]      = "keyword",
  ["ONBUILD"]     = "keyword",
  ["STOPSIGNAL"]  = "keyword",
  ["HEALTHCHECK"] = "keyword",
  ["SHELL"]       = "keyword",
  ["ENTRYPOINT"]  = "keyword",
  ["CMD"]         = "keyword",
}

local default_patterns = { }

local string_interpolation = {
  { pattern = { "%${", "}" }, type = "keyword2", syntax = {
    patterns = default_patterns,
    symbols = default_symbols,
  }},
  { pattern = "[%S][%w]*", type = "string" },
}

merge_tables(default_patterns, {
  { pattern = "#.*", type = "comment" },

  -- Interpolation
  { pattern = { "%${", "}" }, type = "keyword2", syntax = {
    patterns = default_patterns,
    symbols = default_symbols,
  }},
  { pattern = { '"', '"', "\\" }, type = "string", syntax = {
    patterns = string_interpolation,
    symbols = { },
  }},
  { pattern = { "'", "'" }, type = "string", syntax = {
    patterns = string_interpolation,
    symbols = { },
  }},

  -- Symbols
  { pattern = "=",  type = "normal" },
  { pattern = "\\", type = "function" },

  -- Other patterns
  { -- Match FROM with a platform
    pattern = "FROM%s*()--platform()=()[%S][%w]*()%s*.-%s*():",
    type = { "keyword", "keyword2", "normal", "keyword2", "literal", "normal" },
  },
  { -- Match FROM
    pattern = "FROM()%s*.-%s*():",
    type = { "keyword", "literal", "normal" },
  },
  -- Everything else
  { pattern = "[%S][%w]*", type = "keyword2" },
})

syntax.add({
  name = "Containerfile",
  files = { "Containerfile", "Dockerfile", "^Containerfile$", "^Dockerfile$", "%.[cC]ontainerfile$", "%.[dD]ockerfile$" },
  comment = "#",
  patterns = default_patterns,
  symbols = default_symbols,
})

