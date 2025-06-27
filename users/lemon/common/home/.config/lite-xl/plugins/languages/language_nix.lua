-- mod-version:3
-- https://nixos.wiki/wiki/Overview_of_the_Nix_Language

-- Personally modified to match the syntax highlighting of https://github.com/nix-community/vscode-nix-ide

local syntax = require("core.syntax")

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
  { pattern = { "%${", "}" }, type = "keyword", syntax = {
    patterns = default_patterns,
    symbols = default_symbols,
  }},
  -- Recolor the escapement
  { pattern = "%s*()''%$(){.*}",
    type = { "normal", "keyword", "string" },
  },
  { pattern = "[%S][%w]*", type = "string" },
}

-- local brace_interpolation = {
--   { regex = "[\\w\\-_]+[\\s\\S],", type = "normal" },
--   { regex = ",[\\s\\S][\\w\\-_]+", type = "normal" },
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
  -- Works on inline arguments but not multi-line
  -- { regex = { "\\{[\\s\\S]*(?=[\\s\\S]*\\}:)", "}:" }, type = "normal", syntax = {
  --   patterns = brace_interpolation,
  --   symbols = { },
  -- }},

  -- Operators
  { pattern = "[%+%-%*/]", type = "normal" },
  { pattern = "! ",        type = "normal" },
  { pattern = "> ",        type = "normal" },
  { pattern = "< ",        type = "normal" },
  { pattern = "//",        type = "normal" },
  { pattern = "&&",        type = "normal" },
  { pattern = "%->",       type = "normal" },
  { pattern = "||",        type = "normal" },
  { pattern = "==",        type = "normal" },
  { pattern = "!=",        type = "normal" },
  { pattern = ">=",        type = "normal" },
  { pattern = "<=",        type = "normal" },

  -- Paths
  { pattern = "%.?%.?/[^%s%[%]%(%){};,:]+", type = "string" },
  { pattern = "~/[^%s%[%]%(%){};,:]+",      type = "string" },
  { pattern = { "<", ">" },                 type = "string" },

  -- Functions
  { pattern = "[%w%-%_']+%s*:", type = "normal" },

  -- Module arguments
  -- { regex = "[\\w\\-_']+[\\s\\S]\\?(?=.+,)", type = "normal" },
  -- { regex = "(?<!\\?)[\\w\\-_']+[\\s\\S],",  type = "normal" },
  { pattern = "[%w%-%_']+%s*,", type = "normal" },
  { pattern = ",%s*[%w%-%_']+", type = "normal" },

  -- Attribute assignments
  { regex = "[\\w\\-_']+()\\.*(?=[^{}]*=)",
    type = { "literal", "normal" },
  },

  -- Inherits
  { -- Namespace inherits
    pattern = "inherit()%s*%(()[%w%-%_']+()%)()%s*.-%s*();",
    type = { "keyword", "normal", "keyword2", "normal", "literal", "normal" },
  },
  { -- General inherits
    pattern = "inherit()%s*.-%s*();",
    type = { "keyword", "literal", "normal" },
  },

  -- Everything else
  { pattern = "[%a%-%_][%w%-%_]*", type = "keyword2" },
})

-- Current issues:
-- Any module arg that does not have a comma before/after will not be colored

syntax.add({
  name = "Nix",
  files = { "%.nix$" },
  comment = "#",
  block_comment = { "/*", "*/" },
  patterns = default_patterns,
  symbols = default_symbols,
})

