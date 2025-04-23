local style = require("core.style")
local common = require("core.common")

-- Mono
style.bg0      = "#222222"
style.bg1      = "#292929"
style.bg2      = "#323232"
style.bg3      = "#363636"

style.fg0      = "#8c8c8c"
style.fg1      = "#aaaaaa"
style.fg2      = "#dcdcdc"
style.fg3      = "#ffffff"

-- Color
style.whited   = "#c6c6c6"
style.whitel   = "#e2e2e2"
style.blackd   = "#31343a"
style.blackl   = "#40454f"
style.red      = "#f05d6b"
style.orange   = "#f7aa60"
style.yellow   = "#eac56f"
style.green    = "#93cb6b"
style.cyan     = "#53d2e0"
style.blue     = "#61b8ff"
style.magenta  = "#cd61ec"

-- Color of name in file tree
style.link     = "#61b8ff"

style.background  = { common.color(style.bg0) }
style.background2 = { common.color(style.bg1) }
style.background3 = { common.color(style.bg2) }
style.text      = { common.color(style.fg1) }
style.caret     = { common.color(style.fg1) }
style.accent    = { common.color(style.link) }
style.dim       = { common.color(style.fg1) }
style.divider   = { common.color(style.bg1) }
style.selection = { common.color("#575757b8") }
style.line_number    = { common.color(style.fg1) }
style.line_number2   = { common.color(style.fg2) }
style.line_highlight = { common.color(style.bg2) }
style.scrollbar       = { common.color("#646464b3") }
style.scrollbar2      = { common.color("#bfbfbf66") }
style.scrollbar_track = { common.color("#00000000") }
style.nagbar      = { common.color("#ff3333") }
style.nagbar_text = { common.color(style.fg2) }
style.nagbar_dim  = { common.color("#00000072") }
style.drag_overlay     = { common.color("#ffffff1a") }
style.drag_overlay_tab = { common.color(style.fg1) }
style.good     = { common.color("#72b886") }
style.warn     = { common.color("#ffa94d") }
style.error    = { common.color("#ff3333") }
style.modified = { common.color("#1c7c9c") }
style.log = {
  ["INFO"]  = { icon = "i", color = style.text },
  ["WARN"]  = { icon = "!", color = style.warn },
  ["ERROR"] = { icon = "!", color = style.error },
}

style.syntax = {
  normal = { common.color(style.fg1) },
  symbol = { common.color(style.fg1) },
  keyword = { common.color(style.magenta) },
  keyword2 = { common.color(style.red) },
  literal = { common.color(style.orange) },

  -- Anything that I didn't style is cyand
  attribute = { common.color(style.cyan) },
	boolean   = { common.color(style.orange) },
	character = { common.color(style.blue) },
	comment   = { common.color(style.fg0) },
	["comment.documentation"] = { common.color(style.fg0) },
	conditional               = { common.color(style.magenta) },
	["conditional.ternary"]   = { common.color(style.magenta) },
	constant                  = { common.color(style.orange) },
	["constant.builtin"]      = { common.color(style.orange) },
	constructor = { common.color(style.blue) },
	define      = { common.color(style.blue) },
	error       = { common.color(style.blue) },
	exception   = { common.color(style.blue) },
	include     = { common.color(style.blue) },
	field       = { common.color(style.fg1) },
	float       = { common.color(style.blue) },
	["function"]          = { common.color(style.blue) },
	["function.builtin"]  = { common.color(style.blue) },
  ["function.call"]     = { common.color(style.blue) },
	["function.macro"]    = { common.color(style.blue) },
	["keyword.coroutine"] = { common.color(style.magenta) },
	["keyword.function"]  = { common.color(style.magenta) },
	["keyword.operator"]  = { common.color(style.magenta) },
	["keyword.return"]    = { common.color(style.magenta) },
	label           = { common.color(style.blue) },
	method          = { common.color(style.blue) },
	["method.call"] = { common.color(style.blue) },
	namespace       = { common.color(style.blue) },
	number          = { common.color(style.orange) },
	operator        = { common.color(style.fg1) },
	parameter       = { common.color(style.fg1) },
	preproc         = { common.color(style.blue) },
	property        = { common.color(style.blue) },
	["punctuation.bracket"]   = { common.color(style.fg1) },
	["punctuation.delimiter"] = { common.color(style.fg1) },
	["punctuation.special"]   = { common.color(style.fg1) },
	["repeat"]                = { common.color(style.magenta) },
	storageclass              = { common.color(style.blue) },
	["storageclass.lifetime"] = { common.color(style.blue) },
	string               = { common.color(style.green) },
	["string.escape"]    = { common.color(style.cyan) },
	tag                  = { common.color(style.cyan) },
	["tag.delimiter"]    = { common.color(style.cyan) },
	["tag.attribute"]    = { common.color(style.cyan) },
	["text.diff.add"]    = { common.color(style.blue) },
	["text.diff.delete"] = { common.color(style.blue) },
	type                 = { common.color(style.blue) },
	["type.builtin"]     = { common.color(style.blue) },
	["type.definition"]  = { common.color(style.blue) },
	["type.qualifier"]   = { common.color(style.blue) },
	variable = { common.color(style.red) },
	["variable.builtin"] = { common.color(style.yellow) },
}

return style

