local style = require "core.style"
local common = require "core.common"

style.background = { common.color "#222222" }
style.background2 = { common.color "#292929" }
style.background3 = { common.color "#333333" }
style.text = { common.color "#aaaaaa" }
style.caret = { common.color "#aaaaaa" }
style.accent = { common.color "#4892cb" }
style.dim = { common.color "#aaaaaa" }
style.divider = { common.color "#292929" }
style.selection = { common.color "#575757b8" }
style.line_number = { common.color "#aaaaaa" }
style.line_number2 = { common.color "#dcdcdc" }
style.line_highlight = { common.color "#ffffff0a" }
style.scrollbar = { common.color "#646464b3" }
style.scrollbar2 = { common.color "#bfbfbf66" }
style.scrollbar_track = { common.color "#00000000" }
style.nagbar = { common.color "#ff3333" }
style.nagbar_text = { common.color "#dcdcdc" }
style.nagbar_dim = { common.color "#00000072" }
style.drag_overlay = { common.color "#ffffff1a" }
style.drag_overlay_tab = { common.color "#93ddfa" }
style.good = { common.color "#72b886" }
style.warn = { common.color "#ffa94d" }
style.error = { common.color "#ff3333" }
style.modified = { common.color "#1c7c9c" }

style.syntax["normal"] = { common.color "#aaaaaa" }
style.syntax["symbol"] = { common.color "#aaaaaa" }
style.syntax["comment"] = { common.color "#8c8c8c" }
style.syntax["keyword"] = { common.color "#cd61ec" }
style.syntax["keyword2"] = { common.color "#F77483" }
style.syntax["number"] = { common.color "#f7aa60" }
style.syntax["literal"] = { common.color "#f7aa60" }
style.syntax["string"] = { common.color "#93cb6b" }
style.syntax["operator"] = { common.color "#53d2e0" }
style.syntax["function"] = { common.color "#61b8ff" }

style.log["INFO"]  = { icon = "i", color = style.text }
style.log["WARN"]  = { icon = "!", color = style.warn }
style.log["ERROR"] = { icon = "!", color = style.error }

return style

