-- mod-version:3
-- https://nixos.wiki/wiki/Overview_of_the_Nix_Language
local syntax = require "core.syntax"

local function merge_tables(a, b)
  for _, v in pairs(b) do
    table.insert(a, v)
  end
end

local default_symbols = {
  ["import"]   = "keyword",
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
  -- Escapement
  { pattern = { "''%${", "}" }, type = "keyword", syntax = {
    patterns = default_patterns,
    symbols = default_symbols,
  }},

  { pattern = { "%${", "}" }, type = "keyword", syntax = {
    patterns = default_patterns,
    symbols = default_symbols,
  }},

  { pattern = "[%S][%w]*", type = "string" },
}

-- local brace_interpolation = {
--   { pattern = "%S+%s*,%s", type = "normal" },
--   { pattern = ",%s*%S+",   type = "normal" },
--   { pattern = "%s*%S+%s*%?",   type = "normal" },
-- }

-- local list_interpolation = {
--   { pattern = "%s*%S+%s*%?",   type = "normal" },
-- }

merge_tables(default_patterns, {
  -- Comments
  { pattern = "#.*",            type = "comment" },
  { pattern = { "/%*", "%*/" }, type = "comment" },

  -- Numeric
  { pattern = "-?%.?%d+", type = "number" },

  -- Interpolation
  { pattern = { "%${", "}" }, type = "keyword", syntax = {
    patterns = default_patterns,
    symbols = default_symbols,
  }},
  { pattern = { '"', '"', '\\' }, type = "string", syntax = {
    patterns = string_interpolation,
    symbols = { },
  }},
  --                      v We need this to handle escapements, but in return, it grabs our semi-colon
  { pattern = { "''", "''[^%$]" }, type = "string", syntax = {
    patterns = string_interpolation,
    symbols = { },
  }},
  -- Some ideas to handle module attributes. Need some heavy refinement
  -- { pattern = { "{", "}:%S" }, type = "normal", syntax = {
  --   patterns = brace_interpolation,
  --   symbols = default_symbols,
  -- }},
  -- { pattern = { "%s", ",%s" }, type = "normal", syntax = {
  --   patterns = list_interpolation,
  --   symbols = default_symbols,
  -- }},

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

  -- Functions
  { pattern = "%S+%s*:%s", type = "normal" },

  -- Module attributes
  { pattern = "%S+%s*,%s", type = "normal" },
  { pattern = ",%s*%S+",   type = "normal" },

  -- Other patterns
  -- Variables/attributes with a strings
  {
    pattern = '%s*()".*"()[%w%-%_%.]*()".*"()%s*()=()%s*',
    type = { "normal", "string", "literal", "string", "normal", "normal" },
  },
  {
    pattern = '%s*()[%w%-%_%.]*()".*"()[%w%-%_%.]*()%s*()=()%s*',
    type = { "normal", "literal", "string", "literal", "normal", "normal" },
  },
  {
    pattern = '%s*()[%w%-%_%.]*()".*"()%s*()=()%s*',
    type = { "normal", "literal", "string", "normal", "normal" },
  },
  {
    pattern = '%s*()".*"()[%w%-%_%.]*()%s*()=()%s*',
    type = { "normal", "string", "literal", "normal", "normal" },
  },

  -- Variables/attributes
  {
    pattern = "%s*()[%w%-%_%.]*()%s*()=()%s*",
    type = { "normal", "literal", "normal", "normal", "normal" },
  },

  -- Inherits
  {
    pattern = "inherit()%s*%(()%w+()%)()%s*.-%s*();",
    type = { "keyword", "normal", "keyword2", "normal", "literal", "normal" },
  },
  {
    pattern = "inherit()%s*.-%s*();",
    type = { "keyword", "literal", "normal" },
  },

  -- Everything else
  { pattern = "[%a%-%_][%w%-%_]*", type = "keyword2" },
})

-- Current issues:
-- Attribute dots are the same color. Not a big deal. Ex: programs.firefox.profiles.etc
--                                 Should be gray, but are orange ^       ^        ^
-- Escaped nix expressions in strings result in the following semi-colon turning green.
-- A variety of issues regarding module attributes.

syntax.add({
  name = "Nix",
  files = { "%.nix$" },
  comment = "#",
  block_comment = { "/*", "*/" },
  patterns = default_patterns,
  symbols = default_symbols,
})

