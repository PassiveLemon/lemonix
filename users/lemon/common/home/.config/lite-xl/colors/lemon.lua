local style = require("core.style")
local common = require("core.common")

style.bg0      = "#222222"
style.bg1      = "#272727"
style.bg2      = "#303030"
style.bg3      = "#343434"
style.bg4      = "#383838"

style.fg0      = "#aaaaaa"
style.fg1      = "#dcdcdc"
style.fg2      = "#8c8c8c"
style.fg3      = "#ffffff"
style.fg4      = "#ffffff"

-- Color
style.bg       = style.bg0
style.fg       = style.fg0
style.blackd   = "#31343a"
style.blackl   = "#40454f"
style.redd     = "#f05d6b"
style.redl     = style.redd
style.greend   = "#93cb6b"
style.greenl   = style.greend
style.yellowd  = "#eac56f"
style.yellowl  = style.yellowd
style.blued    = "#61b8ff"
style.bluel    = style.blued
style.magentad = "#cd61ec"
style.magental = style.magentad
style.cyand    = "#53d2e0"
style.cyanl    = style.cyand
style.whited   = "#c6c6c6"
style.whitel   = "#e2e2e2"

style.number   = "#f7aa60"
style.link     = "#4892cb"

style.background  = { common.color(style.bg0) }
style.background2 = { common.color(style.bg1) }
style.background3 = { common.color(style.bg2) }
style.text      = { common.color(style.fg0) }
style.caret     = { common.color(style.fg0) }
style.accent    = { common.color(style.link) }
style.dim       = { common.color(style.fg0) }
style.divider   = { common.color(style.bg1) }
style.selection = { common.color("#575757b8") }
style.line_number    = { common.color(style.fg0) }
style.line_number2   = { common.color(style.fg1) }
style.line_highlight = { common.color(style.bg2) }
style.scrollbar       = { common.color("#646464b3") }
style.scrollbar2      = { common.color("#bfbfbf66") }
style.scrollbar_track = { common.color("#00000000") }
style.nagbar      = { common.color("#ff3333") }
style.nagbar_text = { common.color(style.fg1) }
style.nagbar_dim  = { common.color("#00000072") }
style.drag_overlay     = { common.color("#ffffff1a") }
style.drag_overlay_tab = { common.color(style.fg0) }
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
  normal = { common.color(style.fg0) },
  symbol = { common.color(style.fg0) },
  keyword = { common.color(style.magentad) },
  keyword2 = { common.color(style.redd) },
  literal = { common.color(style.number) },

  -- Anything that I didn't style is cyand
  attribute = { common.color(style.cyand) },
	boolean   = { common.color(style.number) },
	character = { common.color(style.blued) },
	comment   = { common.color(style.fg2) },
	["comment.documentation"] = { common.color(style.fg2) },
	conditional               = { common.color(style.magentad) },
	["conditional.ternary"]   = { common.color(style.magentad) },
	constant                  = { common.color(style.number) },
	["constant.builtin"]      = { common.color(style.number) },
	constructor = { common.color(style.blued) },
	define      = { common.color(style.blued) },
	error       = { common.color(style.blued) },
	exception   = { common.color(style.blued) },
	include     = { common.color(style.blued) },
	field       = { common.color(style.fg0) },
	float       = { common.color(style.blued) },
	["function"]          = { common.color(style.blued) },
	["function.builtin"]  = { common.color(style.blued) },
  ["function.call"]     = { common.color(style.blued) },
	["function.macro"]    = { common.color(style.blued) },
	["keyword.coroutine"] = { common.color(style.magentad) },
	["keyword.function"]  = { common.color(style.magentad) },
	["keyword.operator"]  = { common.color(style.magentad) },
	["keyword.return"]    = { common.color(style.magentad) },
	label           = { common.color(style.blued) },
	method          = { common.color(style.blued) },
	["method.call"] = { common.color(style.blued) },
	namespace       = { common.color(style.blued) },
	number          = { common.color(style.number) },
	operator        = { common.color(style.fg0) },
	parameter       = { common.color(style.fg0) },
	preproc         = { common.color(style.blued) },
	property        = { common.color(style.blued) },
	["punctuation.bracket"]   = { common.color(style.fg0) },
	["punctuation.delimiter"] = { common.color(style.fg0) },
	["punctuation.special"]   = { common.color(style.fg0) },
	["repeat"]                = { common.color(style.magentad) },
	storageclass              = { common.color(style.blued) },
	["storageclass.lifetime"] = { common.color(style.blued) },
	string               = { common.color(style.greend) },
	["string.escape"]    = { common.color(style.cyand) },
	tag                  = { common.color(style.cyand) },
	["tag.delimiter"]    = { common.color(style.cyand) },
	["tag.attribute"]    = { common.color(style.cyand) },
	["text.diff.add"]    = { common.color(style.blued) },
	["text.diff.delete"] = { common.color(style.blued) },
	type                 = { common.color(style.blued) },
	["type.builtin"]     = { common.color(style.blued) },
	["type.definition"]  = { common.color(style.blued) },
	["type.qualifier"]   = { common.color(style.blued) },
	variable = { common.color(style.redd) },
	["variable.builtin"] = { common.color(style.yellowd) },
}

return style

