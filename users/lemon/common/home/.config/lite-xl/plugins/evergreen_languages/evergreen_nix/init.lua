-- mod-version: 3

local evergreen_languages = require 'plugins.evergreen.languages'

local pkg_name = ...
local path = pkg_name:gsub('%.', '/')

evergreen_languages.addDef {
	name = 'nix',
	files = { '%.nix$' },
	path = USERDIR .. '/' .. path,
	soFile = 'parser{SOEXT}',
	queryFiles = {},
}
