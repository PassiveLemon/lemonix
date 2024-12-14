-- mod-version:3
-- Orginal Author: Jipok
-- Modified by: techie-guy
-- Doesn't work well with scaling mode == "ui"

-- This is an extension/modification of the nonicons plugin, https://github.com/lite-xl/lite-xl-plugins/blob/master/plugins/nonicons.lua

-- Any icon can be searched with nerdfonts.com/cheat-sheet

local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local TreeView = require "plugins.treeview"
local Node = require "core.node"

local nerdfonts_symbols = require "libraries.font_symbols_nerdfont_mono_regular"

-- Config
config.plugins.nerdicons = common.merge({
  use_default_dir_icons = false,
  use_default_chevrons = false,
  draw_treeview_icons = true,
  draw_tab_icons = true,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Nerdicons",
    {
      label = "Use Default Directory Icons",
      description = "When enabled does not use nerdicon directory icons.",
      path = "use_default_dir_icons",
      type = "toggle",
      default = false
    },
    {
      label = "Use Default Chevrons",
      description = "When enabled does not use nerdicon expand/collapse arrow icons.",
      path = "use_default_chevrons",
      type = "toggle",
      default = false
    },
    {
      label = "Draw Treeview Icons",
      description = "Enables file related icons on the treeview.",
      path = "draw_treeview_icons",
      type = "toggle",
      default = true
    },
    {
      label = "Draw Tab Icons",
      description = "Adds file related icons to tabs.",
      path = "draw_tab_icons",
      type = "toggle",
      default = true
    },
  }
}, config.plugins.nerdicons)

local icon_font = renderer.font.load(nerdfonts_symbols.path, 18.5 * SCALE)
local map = nerdfonts_symbols.utf8
local chevron_width = icon_font:get_width(map["oct-chevron_down"])
local previous_scale = SCALE

local extension_icons = {
  [".lua"]         = { "#42a5f5", "seti-lua"                 },
  [".md"]          = { "#42a5f5", "dev-markdown"             },
  [".powershell"]  = { "#519aba", "cod-terminal_powershell"  },
  [".bat"]         = { "#cbcb41", "cod-terminal_cmd"         },
  [".txt"]         = { "#aaaaaa", "fa-file_text"             },
  [".cpp"]         = { "#519aba", "custom-cpp"               },
  [".c"]           = { "#599eff", "custom-c"                 },
  [".h"]           = { "#599eff", "md-hulu"                  },
  [".hpp"]         = { "#599eff", "md-hulu"                  },
  [".py"]          = { "#3776ab", "md-language_python"       },
  [".pyc"]         = { "#3776ab", "md-language_python"       },
  [".pyd"]         = { "#3776ab", "md-language_python"       },
  [".php"]         = { "#a074c4", "md-language_php"          },
  [".cs"]          = { "#596706", "md-language_csharp"       },
  [".conf"]        = { "#6d8086", "seti-config"              },
  [".cfg"]         = { "#6d8086", "seti-config"              },
  [".ini"]         = { "#6d8086", "seti-config"              },
  [".toml"]        = { "#6d8086", "seti-config"              },
  [".env"]         = { "#6d8086", "seti-config"              },
  [".yaml"]        = { "#cc3e44", "seti-yml"                 },
  [".yml"]         = { "#cc3e44", "seti-yml"                 },
  [".json"]        = { "#f7ca39", "seti-json"                },
  [".css"]         = { "#519abc", "dev-css3"                 },
  [".html"]        = { "#e34c26", "dev-html5"                },
  [".js"]          = { "#cbcb41", "dev-javascript_badge"     },
  [".cjs"]         = { "#cbcb41", "dev-javascript_badge"     },
  [".mjs"]         = { "#cbcb41", "dev-javascript_badge"     },
  [".ejs"]         = { "#ffea7f", "seti-ejs"                 },
  [".pug"]         = { "#a86454", "seti-pug"                 },
  [".go"]          = { "#00add8", "md-language_go"           },
  [".mod"]         = { "#ec407a", "md-language_go"           },
  [".sum"]         = { "#ec407a", "md-language_go"           },
  [".jpg"]         = { "#a074c4", "md-image"                 },
  [".png"]         = { "#a074c4", "md-image"                 },
  [".sh"]          = { "#f05032", "dev-terminal"             },
  [".bash"]        = { "#f05032", "dev-terminal"             },
  [".java"]        = { "#cc3e44", "dev-java"                 },
  [".scala"]       = { "#cc3e44", "dev-scala"                },
  [".kt"]          = { "#F88A02", "custom-kotlin"            },
  [".pl"]          = { "#519aba", "dev-perl"                 },
  [".pm"]          = { "#519aba", "dev-perl"                 },
  [".rb"]          = { "#701516", "dev-ruby_rough"           },
  [".rs"]          = { "#c95625", "dev-rust"                 },
  [".rss"]         = { "#cc3e44", "fa-rss_square"            },
  [".sql"]         = { "#dad8d8", "dev-sqllite"              },
  [".swift"]       = { "#e37933", "dev-swift"                },
  [".ts"]          = { "#519aba", "md-language_typescript"   },
  [".diff"]        = { "#f05032", "seti-git"                 },
  [".patch"]       = { "#f05032", "seti-git"                 },
  [".exe"]         = { "#cc3e55", "cod-file_binary"          },
  [".make"]        = { "#d0bf41", "seti-makefile"            },
  [".svg"]         = { "#f7ca39", "md-svg"                   },
  [".ttf"]         = { "#dad8d4", "fa-font"                  },
  [".otf"]         = { "#dad8d4", "fa-font"                  },
  [".vim"]         = { "#8f00ff", "custom-vim"               },
  [".pdf"]         = { "#E53935", "fa-file_pdf_o"            },
  [".jl"]          = { "#4063d8", "seti-julia"               },
  [".mp4"]         = { "#e85e00", "oct-video"                },
  [".jld2"]        = { "#888888", "fa-database"              },
  [".ipynb"]       = { "#F37726", "seti-notebook"            },
  [".nix"]         = { "#7eb7e1", "md-nix"                   },
  [".lock"]        = { "#f7ca39", "fa-lock"                  },
  [".key"]         = { "#f7ca39", "md-key"                   },
  [".pem"]         = { "#f7ca39", "md-key"                   },
  [".nim"]         = { "#ffc200", "seti-nim"                 },
}

local known_filenames_icons = {
  [".gitignore"]           = { "#f05032", "seti-git"             },
  [".gitmodules"]          = { "#f05032", "seti-git"             },
  [".gitattributes"]       = { "#f05032", "seti-git"             },
  [".mailmap"]             = { "#f05032", "seti-git"             },
  [".editorconfig"]        = { "#fefefe", "seti-editorconfig"    },
  [".luacheckrc"]          = { "#42a5f5", "seti-lua"             },
  ["README.md"]            = { "#42a5f5", "md-information"       },
  ["LICENSE"]              = { "#f05032", "md-certificate"       },
  ["COPYING"]              = { "#f05032", "md-certificate"       },
  ["PKGBUILD"]             = { "#6d8ccc", "md-package"           },
  ["makefile"]             = { "#f7ca39", "seti-makefile"        },
  ["cmakelists.txt"]       = { "#cc3e55", "md-triangle_outline"  },
  ["MANIFEST.in"]          = { "#3572A5", "md-language_python"   },
  ["Dockerfile"]           = { "#2496ef", "linux-docker"         },
  ["docker-compose.yml"]   = { "#2496ef", "linux-docker"         },
  ["docker-compose.yaml"]  = { "#2496ef", "linux-docker"         },
}

-- Preparing colors
for _, v in pairs(extension_icons) do
  v[1] = { common.color(v[1]) }
end
for _, v in pairs(known_filenames_icons) do
  v[1] = { common.color(v[1]) }
end

-- Override function to change default icons for dirs, special extensions and names
local TreeView_get_item_icon = TreeView.get_item_icon
function TreeView:get_item_icon(item, active, hovered)
  local icon, font, color = TreeView_get_item_icon(self, item, active, hovered)
  if previous_scale ~= SCALE then
    icon_font:set_size(
      icon_font:get_size() * (SCALE / previous_scale)
    )
    chevron_width = icon_font:get_width(map["oct-chevron_down"])
    previous_scale = SCALE
  end
  if not config.plugins.nerdicons.use_default_dir_icons then
    icon = map["cod-file"] -- hex ea7b
    font = icon_font
    color = style.text
    if item.type == "dir" then
      icon = item.expanded and map["fa-folder_open"] or map["fa-folder"] -- hex f07c and f07b
    end
  end
  if config.plugins.nerdicons.draw_treeview_icons then
    local custom_icon = known_filenames_icons[item.name:lower()]
    if custom_icon == nil then
      custom_icon = extension_icons[item.name:match("^.+(%..+)$")]
    end
    if custom_icon ~= nil then
      color = custom_icon[1]
      icon = map[custom_icon[2]]
      font = icon_font
    end
    if active or hovered then
      color = style.accent
    end
  end
  return icon, font, color
end

-- Override function to draw chevrons if setting is disabled
local TreeView_draw_item_chevron = TreeView.draw_item_chevron
function TreeView:draw_item_chevron(item, active, hovered, x, y, w, h)
  if not config.plugins.nerdicons.use_default_chevrons then
    if item.type == "dir" then
      local chevron_icon = item.expanded and "oct-chevron_down" or "oct-chevron_right"
      local chevron_color = hovered and style.accent or style.text
      common.draw_text(icon_font, chevron_color, map[chevron_icon], nil, x+8, y, 0, h) -- added 8 to x to draw the chevron closer to the icon
    end
    return chevron_width + style.padding.x
  end
  return TreeView_draw_item_chevron(self, item, active, hovered, x, y, w, h)
end

-- Override function to draw icons in tabs titles if setting is enabled
local Node_draw_tab_title = Node.draw_tab_title
function Node:draw_tab_title(view, font, is_active, is_hovered, x, y, w, h)
  if config.plugins.nerdicons.draw_tab_icons then
    local padx = chevron_width + style.padding.x/2
    local tx = x + padx/16 -- Space for icon
    w = w + padx
    Node_draw_tab_title(self, view, font, is_active, is_hovered, tx, y, w, h)
    if (view == nil) or (view.doc == nil) then return end
    local item = { type = "file", name = view.doc:get_name() }
    TreeView:draw_item_icon(item, false, is_hovered, x, y, w, h)
  else
    Node_draw_tab_title(self, view, font, is_active, is_hovered, x, y, w, h)
  end
end

