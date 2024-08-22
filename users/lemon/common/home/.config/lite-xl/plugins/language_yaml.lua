-- mod-version:3
local syntax = require "core.syntax"

local yaml_bracket_list = {
  patterns = {
    -- comments
    { pattern = { "#", "\n"},       type = "comment" },
    -- strings
    { pattern = { '"', '"', '\\' }, type = "string" },
    { pattern = { "'", "'", '\\' }, type = "string" },
    -- keys
    {
      pattern = "[%w%d]+%g+()%s*():()%s",
      type = { "keyword2", "normal", "operator", "normal" }
    },
    -- variables
    { pattern = "%$%a%w+",                     type = "keyword" },
    { pattern = "%$%{%{.-%}%}",                type = "keyword" },
    -- numeric place holders
    { pattern = "%-?%.inf",                    type = "number" },
    { pattern = "%.NaN",                       type = "number" },
    -- numbers
    { pattern = "[%+%-]?0%d+",                 type = "number" },
    { pattern = "[%+%-]?0x%x+",                type = "number" },
    { pattern = "[%+%-]?%d+[,%.eE:%+%d]*%d+",  type = "number" },
    { pattern = "[%+%-]?%d+",                  type = "number" },
    -- others
    { pattern = ",",                           type = "operator" },
    { pattern = "%w+",                         type = "string" },
    {
      pattern = "[_%(%)%*@~`!%%%^&=%+%-\\;%.><%?/%s]+",
      type = "string"
    },
  },
  symbols = { }
}

syntax.add({
  name = "YAML",
  files = { "%.yml$", "%.yaml$" },
  comment = "#",
  space_handling = false,
  patterns = {
  --- Rules that start with spaces first and those taking precedence
    -- Parent and child keys
    {
      pattern = "^[%w%d]+%g+%s*%f[:]",
      type = "keyword2"
    },
    {
      pattern = "^%s+[%w%d]+%g+%s*%f[:]",
      type = "keyword2"
    },
    -- Bracket lists after key declaration
    {
      pattern = { ":%s+%[", "%]" },
      syntax = yaml_bracket_list, type = "operator"
    },
    {
      pattern = { ":%s+{", "}" },
      syntax = yaml_bracket_list, type = "operator"
    },
    -- Child key
    {
      pattern = "^%s+()[%w%d]+%g+()%s*():()%s",
      type = { "normal", "keyword2", "normal", "operator", "normal" }
    },
    -- Child list element
    {
      pattern = "^%s+()%-()%s+()[%w%d]+%g+()%s*():()%s",
      type = { "normal", "normal", "normal", "keyword2", "normal", "normal", "normal" }
    },
    -- Unkeyed bracket lists
    {
      pattern = { "^%s*%[", "%]" },
      syntax = yaml_bracket_list, type = "operator"
    },
    {
      pattern = { "^%s*{", "}" },
      syntax = yaml_bracket_list, type = "operator"
    },
    {
      pattern = { "^%s*%-%s*%[", "%]" },
      syntax = yaml_bracket_list, type = "operator"
    },
    {
      pattern = { "^%s*%-%s*{", "}" },
      syntax = yaml_bracket_list, type = "operator"
    },
    -- Rule to optimize space handling
    { pattern = "%s+",              type = "normal" },
  --- All the other rules
    -- Comments
    { pattern = { "#", "\n"},       type = "comment" },
    -- Strings
    { pattern = { '"', '"', '\\' }, type = "string" },
    { pattern = { "'", "'", '\\' }, type = "string" },
    -- Extra bracket lists rules on explicit type
    {
      pattern = { "!!%w+%s+%[", "%]"},
      syntax = yaml_bracket_list, type = "operator"
    },
    {
      pattern = { "!!%w+%s+{", "}"},
      syntax = yaml_bracket_list, type = "operator"
    },
    -- Numeric place holders
    { pattern = "%-?%.inf", type = "number" },
    { pattern = "%.NaN",    type = "number" },
    -- Parent list element
    {
      pattern = "^%-()%s+()[%w%d]+%g+()%s*():()%s",
      type = { "operator", "normal", "keyword2", "normal", "operator", "normal" }
    },
    -- Key label
    {
      pattern = "%&()%g+",
      type = { "keyword", "literal" }
    },
    -- Key elements expansion
    { pattern = "<<", type = "literal" },
    {
      pattern = "%*()[%w%d_]+",
      type = { "keyword", "literal" }
    },
    -- Explicit data types
    { pattern = "!!%g+", type = "keyword" },
    -- Parent key
    {
      pattern = "^[%w%d]+%g+()%s*():()%s",
      type = { "literal", "normal", "operator", "normal" }
    },
    -- Variables
    { pattern = "%$%a%w+",                    type = "keyword" },
    { pattern = "%$%{%{.-%}%}",               type = "keyword" },
    -- Numbers
    { pattern = "[%+%-]?0%d+",                type = "number" },
    { pattern = "[%+%-]?0x%x+",               type = "number" },
    { pattern = "[%+%-]?%d+[,%.eE:%+%d]*%d+", type = "number" },
    { pattern = "[%+%-]?%d+",                 type = "number" },
    -- Special operators
    { pattern = "[%*%|%!>%%]",                type = "keyword" },
    { pattern = "[%-%$:%?]+",                 type = "normal" },
    -- Everything else as a string
    { pattern = "%d+%.?%d*[^%d%.]",           type = "string" },
    { pattern = "[%d%a_][%g_]*",              type = "string" },
    { pattern = "%p+",                        type = "string" },
  },
  symbols = {
    ["True"]  = "number",
    ["False"] = "number",
    ["true"]  = "number",
    ["false"] = "number",
    ["y"]     = "number",
    ["n"]     = "number",
  },
})

