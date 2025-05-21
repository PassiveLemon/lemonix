-- mod-version: 3

local evergreen_languages = require 'plugins.evergreen.languages'

local pkg_name = ...
local path = pkg_name:gsub('%.', '/')

evergreen_languages.addDef {
	name = 'html',
	files = { '%.html?$' },
	path = USERDIR .. '/' .. path,
	soFile = 'parser{SOEXT}',
	queryFiles = {},
}
