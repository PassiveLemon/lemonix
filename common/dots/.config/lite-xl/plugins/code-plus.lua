-- mod-version:3
local config = require "core.config"
local command = require "core.command"
local keymap = require "core.keymap"
local common = require "core.common"
local DocView = require "core.docview"

config.plugins.code_plus = common.merge({
  enabled = true, --- enabled by default
  config_spec = { --- config specification used by the settings gui
    name = "Code+",
    {
      label = "Enable",
      description = "Toggle to enable this plugin.",
      path = "enabled",
      type = "toggle",
      default = true
    },
    {
      label = "Todo Color",
      description = "Define the color that highlights the todo comments.",
      path = "todo",
      type = "color",
      default = "#5592CF"
    },
    {
      label = "Fixme Color",
      description = "Defines the color that highlights the fixme comments.",
      path = "fixme",
      type = "color",
      default = "#EF6385"
    },
  }
}, config.plugins.code_plus)

--- draw comments highlights
local white = { common.color "#ffffff" }

local function draw_highlight(self, str, line, x, y, s, e, color)
    local x1 = x + self:get_col_x_offset(line, s)
    local x2 = x + self:get_col_x_offset(line, e + 1)
    local oy = self:get_line_text_y_offset()
    renderer.draw_rect(x1, y, x2 - x1, self:get_line_height(), color)
    renderer.draw_text(self:get_font(), str, x1, y + oy, white)
end


local function highlight_comment(self, line, x, y, comment, color)
  local text = self.doc.lines[line]
  local s, e = 0, 0

  while true do
        s, e = text:lower():find(comment .. "%((.-)%)", e + 1)
        if s then  
            local str = text:sub(s, e)
            draw_highlight(self, str, line, x, y, s, e, color)
        end
        
        if not s then
            break
        end
    end
end

local draw_line_text = DocView.draw_line_text

function DocView:draw_line_text(line, x, y)
    local lh = draw_line_text(self, line, x, y)

    if config.plugins.code_plus.enabled then
      highlight_comment(self, line, x, y, "@todo", config.plugins.code_plus.todo)
      highlight_comment(self, line, x, y, "@fixme", config.plugins.code_plus.fixme)
    end
    return lh
end

--- auto complete brackets, parantheses, etc...

local function complete(dv, s, e)
    if dv.doc:has_selection() then
      local text = dv.doc:get_text(dv.doc:get_selection())
      dv.doc:text_input(s .. text .. e)
    else
      local doc = dv.doc
      local idx = dv.doc.last_selection
      local line1, col1 = doc:get_selection_idx(idx)
      doc:insert(line1, col1, s .. e)
      doc:move_to_cursor(idx, idx)
    end
end

command.add("core.docview!", {
  ["code_plus:complete_brackets"] = function(dv)
    complete(dv, "[", "]")
  end,
  ["code_plus:complete_curly_brackets"] = function(dv)
    complete(dv, "{", "}")
  end,
  ["code_plus:complete_parantheses"] = function(dv)
    complete(dv, "(", ")")
  end,
  ["code_plus:complete_quotation_marks"] = function(dv)
    complete(dv, '"', '"')
  end,
  ["code_plus:complete_single_quotation_marks"] = function(dv)
    complete(dv, "'", "'")
  end,
})

keymap.add {
  ["altgr+8"] = "code_plus:complete_brackets",
  ["ctrl+alt+8"] = "code_plus:complete_brackets",
  ["altgr+7"] = "code_plus:complete_curly_brackets",
  ["ctrl+alt+7"] = "code_plus:complete_curly_brackets",
  ["shift+8"] = "code_plus:complete_parantheses",
  ["shift+2"] = "code_plus:complete_quotation_marks",
}

