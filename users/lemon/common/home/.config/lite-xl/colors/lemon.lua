local style = require("core.style")
local common = require("core.common")

-- Custom color theme
-- Mono
style.bg0      = { common.color("#222222") }
style.bg1      = { common.color("#292929") }
style.bg2      = { common.color("#323232") }
style.bg3      = { common.color("#363636") }

style.fg0      = { common.color("#8c8c8c") }
style.fg1      = { common.color("#aaaaaa") }
style.fg2      = { common.color("#dcdcdc") }
style.fg3      = { common.color("#ffffff") }

-- Color
style.whited   = { common.color("#c6c6c6") }
style.whitel   = { common.color("#e2e2e2") }
style.blackd   = { common.color("#31343a") }
style.blackl   = { common.color("#40454f") }
style.red      = { common.color("#f05d6b") }
style.orange   = { common.color("#f7aa60") }
style.yellow   = { common.color("#eac56f") }
style.green    = { common.color("#93cb6b") }
style.cyan     = { common.color("#53d2e0") }
style.blue     = { common.color("#61b8ff") }
style.magenta  = { common.color("#cd61ec") }

-- UI
style.background  = style.bg0
style.background2 = style.bg1
style.background3 = style.bg2
style.text      = style.fg1
style.caret     = style.fg1
style.accent    = style.link
style.dim       = style.fg1
style.divider   = style.bg1
style.selection = { common.color("#575757b8") }
style.link      = style.blue
style.line_number    = style.fg1
style.line_number2   = style.fg2
style.line_highlight = style.bg2
style.scrollbar       = { common.color("#646464b3") }
style.scrollbar2      = { common.color("#bfbfbf66") }
style.scrollbar_track = { common.color("#00000000") }
style.nagbar      = { common.color("#ff3333") }
style.nagbar_text = style.fg2
style.nagbar_dim  = { common.color("#00000072") }
style.drag_overlay     = { common.color("#ffffff1a") }
style.drag_overlay_tab = style.fg1
style.good     = { common.color("#72b886") }
style.warn     = { common.color("#ffa94d") }
style.error    = { common.color("#ff3333") }
style.modified = { common.color("#1c7c9c") }
style.log = {
  ["INFO"]  = { icon = "i", color = style.text },
  ["WARN"]  = { icon = "!", color = style.warn },
  ["ERROR"] = { icon = "!", color = style.error },
}

-- Languages
style.syntax = {
  -- Standard
  ["normal"]   = style.fg1,
  ["symbol"]   = style.fg1,
  ["comment"]  = style.fg0,
  ["keyword"]  = style.magenta,
  ["keyword2"] = style.red,
  ["number"]   = style.orange,
  ["literal"]  = style.orange,
  ["string"]   = style.green,
  ["operator"] = style.fg1,
  ["function"] = style.blue,

  -- Evergreen
	["boolean"]   = style.orange,
	["character"] = style.blue,
	["comment.documentation"] = style.fg0,
	["comment.error"]   = style.fg0,
	["comment.note"]    = style.fg0,
	["comment.todo"]    = style.fg0,
	["comment.warning"] = style.fg0,
	["conditional"]         = style.magenta,
	["conditional.ternary"] = style.magenta,
	["constant"]            = style.orange,
	["constant.builtin"]    = style.orange,
	["constructor"] = style.fg1,
	["define"]      = style.blue,
	["diff.delta"]  = style.modified,
	["diff.minus"]  = style.error,
	["diff.plus"]   = style.good,
	["error"]       = style.error,
	["exception"]   = style.blue,
	["include"]     = style.blue,
	["field"]       = style.fg1,
	["float"]       = style.blue,
	["function.builtin"]  = style.cyan,
  ["function.call"]     = style.blue,
	["function.macro"]    = style.blue,
	["keyword.coroutine"] = style.magenta,
	["keyword.function"]  = style.magenta,
	["keyword.operator"]  = style.magenta,
	["keyword.return"]    = style.magenta,
	["label"]       = style.blue,
	["method"]      = style.blue,
	["method.call"] = style.blue,
	["namespace"]   = style.blue,
	["parameter"]   = style.fg1,
	["preproc"]     = style.blue,
	["property"]    = style.red,
	["punctuation.bracket"]   = style.fg1,
	["punctuation.delimiter"] = style.fg1,
	["punctuation.special"]   = style.fg1,
	["repeat"]                = style.magenta,
	["storageclass"]          = style.blue,
	["storageclass.lifetime"] = style.blue,
	["string.special.symbol"] = style.red,
	["tag"]              = style.red,
	["tag.delimiter"]    = style.fg1,
	["tag.attribute"]    = style.orange,
	["text.diff.add"]    = style.blue,
	["text.diff.delete"] = style.blue,
	["type"]             = style.red,
	["type.builtin"]     = style.red,
	["type.definition"]  = style.red,
	["variable"]         = style.red,
	["variable.builtin"] = style.yellow,
	["variable.member"]  = style.fg1,
	["variable.parameter"] = style.fg1,
}

-- Lint+
style.lint = { }
style.lint.info = style.modified
style.lint.hint = style.good
style.lint.warning = style.warn
style.lint.error = style.error

-- Gitdiff Highlight
style.gitdiff_addition = style.good
style.gitdiff_deletion = style.error
style.gitdiff_modification = style.modified

-- Bracketmatch
style.bracketmatch_color = style.fg1
style.bracketmatch_char_color = style.fg1
style.bracketmatch_block_color = style.fg1
style.bracketmatch_frame_color = style.fg1

return style

