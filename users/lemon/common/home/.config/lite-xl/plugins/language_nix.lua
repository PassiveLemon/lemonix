-- mod-version:3
-- https://nixos.wiki/wiki/Overview_of_the_Nix_Language
local syntax = require "core.syntax"

local function merge_tables(a, b)
  for _, v in pairs(b) do
    table.insert(a, v)
  end
end

local default_symbols = {
  ["import"]   = "operator",
  ["with"]     = "keyword",
  ["inherit"]  = "keyword",
  ["assert"]   = "keyword",
  ["let"]      = "keyword",
  ["in"]       = "keyword",
  ["rec"]      = "keyword",
  ["if"]       = "keyword",
  ["else"]     = "keyword",
  ["then"]     = "keyword",
  ["builtins"] = "literal",
  ["true"]     = "literal",
  ["false"]    = "literal",
  ["null"]     = "literal",
}

local default_patterns = { }

local string_interpolation = {
  { pattern = { "%${", "}" }, type = "keyword", syntax = {
    patterns = default_patterns,
    symbols = default_symbols,
  }},
  { pattern = "[%S][%w]*", type = "string" },
}

merge_tables(default_patterns, {
  -- Comments
  { pattern = "#.*",            type = "comment" },
  { pattern = { "/%*", "%*/" }, type = "comment" },

  -- Numeric
  { pattern = "-?%.?%d+",       type = "number" },

  -- Interpolation
  { pattern = { "%${", "}" }, type = "keyword", syntax = {
    patterns = default_patterns,
    symbols = default_symbols,
  }},
  { pattern = { '"', '"', '\\' }, type = "string", syntax = {
    patterns = string_interpolation,
    symbols = { },
  }},
  { pattern = { "''", "''" }, type = "string", syntax = {
    patterns = string_interpolation,
    symbols = { },
  }},

  -- Operators
  { pattern = "[%+%-%?!>%*]", type = "normal" },
  { pattern = "/ ",           type = "normal" },
  { pattern = "< ",           type = "normal" },
  { pattern = "//",           type = "normal" },
  { pattern = "&&",           type = "normal" },
  { pattern = "%->",          type = "normal" },
  { pattern = "||",           type = "normal" },
  { pattern = "==",           type = "normal" },
  { pattern = "!=",           type = "normal" },
  { pattern = ">=",           type = "normal" },
  { pattern = "<=",           type = "normal" },

  -- Paths
  { pattern = "%.?%.?/[^%s%[%]%(%){};,:]+", type = "string" },
  { pattern = "~/[^%s%[%]%(%){};,:]+",      type = "string" },
  { pattern = { "<", ">" },                 type = "string" },

  -- Other patterns
  { -- Match variables/attribute keys
    pattern = "%s*()[%w%-%_%.]*()%s*()=()%s*",
    type = { "normal", "literal", "normal", "normal", "normal" }
  },
  { -- Match inherits with a namespace
    pattern = "inherit()%s*%(()%w+()%)()%s*.-%s*();",
    type = { "keyword", "normal", "keyword2", "normal", "literal", "normal" },
  },
  { -- Match inherits
    pattern = "inherit()%s*.-%s*();",
    type = { "keyword", "literal", "normal" },
  },
  { pattern = "%S+%s*[,:]%s",      type = "normal" },
  -- Everything else
  { pattern = "[%a%-%_][%w%-%_]*", type = "keyword2" },
})

-- Problems:
-- Attribute assignment dots are the same color
-- Quoted strings in an in-line attribute assignment are the same color
-- Multi-line file function arguments are a different color

-- Some way to represent repeated value.value, like ([%w].[%w])+

syntax.add({
  name = "Nix",
  files = { "%.nix$" },
  comment = "#",
  block_comment = { "/*", "*/" },
  patterns = default_patterns,
  symbols = default_symbols,
})

