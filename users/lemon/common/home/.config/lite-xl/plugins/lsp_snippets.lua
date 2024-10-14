-- mod-version:3

-- LSP style snippet parser
-- shamelessly 'inspired by' (stolen from) LuaSnip
-- https://github.com/L3MON4D3/LuaSnip/blob/master/lua/luasnip/util/parser/neovim_parser.lua

local core     = require 'core'
local common   = require 'core.common'
local Doc      = require 'core.doc'
local system   = require 'system'
local regex    = require 'regex'
local snippets = require 'plugins.snippets'

local json do
	local ok, j 
	for _, p in ipairs {
		'plugins.json', 'plugins.lsp.json', 'plugins.lintplus.json',
		'libraries.json'
	} do
		ok, j = pcall(require, p)
		if ok then json = j; break end
	end
end


local B = snippets.builder

local LAST_CONVERTED_ID = { }
local THREAD_KEY = { }


-- node factories

local function doc_syntax(doc, k)
	return doc.syntax and doc.syntax[k]
end

local variables = {
	-- LSP
	TM_SELECTED_TEXT         = function(ctx) return ctx.selection end,
	TM_CURRENT_LINE          = function(ctx) return ctx.doc.lines[ctx.line] end,
	TM_CURRENT_WORD          = function(ctx) return ctx.partial end,
	TM_LINE_INDEX            = function(ctx) return ctx.line - 1 end,
	TM_LINE_NUMBER           = function(ctx) return ctx.line end,
	TM_FILENAME              = function(ctx) return ctx.doc.filename:match('[^/%\\]*$') or '' end,
	TM_FILENAME_BASE         = function(ctx) return ctx.doc.filename:match('([^/%\\]*)%.%w*$') or ctx.doc.filename end,
	TM_DIRECTORY             = function(ctx) return ctx.doc.filename:match('([^/%\\]*)[/%\\].*$') or '' end,
	TM_FILEPATH              = function(ctx) return common.dirname(ctx.doc.abs_filename) or '' end,
	-- VSCode
	RELATIVE_FILEPATH        = function(ctx) return core.normalize_to_project_dir(ctx.doc.filename) end,
	CLIPBOARD                = function()    return system.get_clipboard() end,
	-- https://github.com/lite-xl/lite-xl/pull/1455
	WORKSPACE_NAME           = function(ctx) return end,
	WORKSPACE_FOLDER         = function(ctx) return end,
	CURSOR_INDEX             = function(ctx) return ctx.col - 1 end,
	CURSOR_NUMBER            = function(ctx) return ctx.col end,
	CURRENT_YEAR             = function()    return os.date('%G') end,
	CURRENT_YEAR_SHORT       = function()    return os.date('%g') end,
	CURRENT_MONTH            = function()    return os.date('%m') end,
	CURRENT_MONTH_NAME       = function()    return os.date('%B') end,
	CURRENT_MONTH_NAME_SHORT = function()    return os.date('%b') end,
	CURRENT_DATE             = function()    return os.date('%d') end,
	CURRENT_DAY_NAME         = function()    return os.date('%A') end,
	CURRENT_DAY_NAME_SHORT   = function()    return os.date('%a') end,
	CURRENT_HOUR             = function()    return os.date('%H') end,
	CURRENT_MINUTE           = function()    return os.date('%M') end,
	CURRENT_SECOND           = function()    return os.date('%S') end,
	CURRENT_SECONDS_UNIX     = function()    return os.time() end,
	RANDOM                   = function()    return string.format('%06d', math.random(999999)) end,
	RANDOM_HEX               = function()    return string.format('%06x', math.random(0xFFFFFF)) end,
	BLOCK_COMMENT_START      = function(ctx) return (doc_syntax(ctx.doc, 'block_comment') or { })[1] end,
	BLOCK_COMMENT_END        = function(ctx) return (doc_syntax(ctx.doc, 'block_comment') or { })[2] end,
	LINE_COMMENT             = function(ctx) return doc_syntax(ctx.doc, 'comment') end
	-- https://code.visualstudio.com/docs/editor/userdefinedsnippets#_variables
	-- UUID
}

local formatters; formatters = {
	downcase   = string.lower,
	upcase     = string.upper,
	capitalize = function(str)
		return str:sub(1, 1):upper() .. str:sub(2)
	end,
	pascalcase = function(str)
		local t = { }
		for s in str:gmatch('%w+') do
			table.insert(t, formatters.capitalize(s))
		end
		return table.concat(t)
	end,
	camelcase  = function(str)
		str = formatters.pascalcase(str)
		return str:sub(1, 1):lower() .. str:sub(2)
	end
}

local function to_text(v, _s)
	return v.esc
end

local function format_fn(v, _s)
	local id = tonumber(v[2])

	-- $1 | ${1}
	if #v < 4 then
		return function(captures)
			return captures[id] or ''
		end
	end

	-- ${1:...}
	local t = v[3][2][1] -- token after the ':' | (else when no token)
	local i = v[3][2][2] -- formatter | if | (else when no if)
	local e = v[3][2][4] -- (else when if)

	if t == '/' then
		local f = formatters[i]
		return function(captures)
			local c = captures[id]
			return c and f(c) or ''
		end
	elseif t == '+' then
		return function(captures)
			return captures[id] and i or ''
		end
	elseif t == '?' then
		return function(captures)
			return captures[id] and i or e
		end
	elseif t == '-' then
		return function(captures)
			return captures[id] or i
		end
	else
		return function(captures)
			return captures[id] or t
		end
	end
end

local function transform_fn(v, _s)
	local reg = regex.compile(v[2], v[#v])
	local fmt = v[4]

	if type(fmt) ~= 'table' then
		return function(str)
			return reg:gsub(str, '')
		end
	end

	local t = { }
	for _, f in ipairs(fmt) do
		if type(f) == 'string' then
			table.insert(t, f)
		else
			break
		end
	end

	if #t == #fmt then
		t = table.concat(t)
		return function(str)
			return reg:gsub(str, t)
		end
	end

	return function(str)
		local captures = { reg:match(str) }
		for k, v in ipairs(captures) do
			if type(v) ~= 'string' then
				captures[k] = nil
			end
		end
		local t = { }
		for _, f in ipairs(fmt) do
			if type(f) == 'string' then
				table.insert(t, f)
			else
				table.insert(t, f(captures))
			end
		end
		return table.concat(t)
	end
end

local function text_node(v, _s)
	return B.static(v.esc)
end

local function variable_node(v, _s)
	local name = v[2]
	local var = variables[name]

	local id
	if not var then
		if not _s._converted_variables then
			id = os.time()
			_s._converted_variables = { [name] = id, [LAST_CONVERTED_ID] = id }
		else
			id = _s._converted_variables[name]
			if not id then
				id = _s._converted_variables[LAST_CONVERTED_ID] + 1
				_s._converted_variables[name] = id
				_s._converted_variables[LAST_CONVERTED_ID] = id
			end
		end
	end

	if #v ~= 4 then
		return var and B.static(var) or B.user(id, name)
	end

	if type(v[3]) == 'table' then
		-- vscode accepts empty default -> var name
		return var and B.static(var) or B.user(id, v[3][2] or name)
	end

	if not var then
		return B.user(id, nil, v[3])
	end

	return type(var) ~= 'function' and B.static(var) or B.static(function(ctx)
		return v[3](var(ctx))
	end)
end

local function tabstop_node(v, _s)
	local t = v[3] and v[3] ~= '}' and v[3] or nil
	return B.user(tonumber(v[2]), nil, t)
end

local function choice_node(v, _s)
	local id = tonumber(v[2])
	local c = { [v[4]] = true }
	if #v == 6 then
		for _, _c in ipairs(v[5]) do
			c[_c[2]] = true
		end
	end
	_s:choice(id, c)
	return B.user(id)
end

local function placeholder_node(v, _s)
	local id = tonumber(v[2])
	_s:default(id, v[4])
	return B.user(id)
end

local function build_snippet(v, _s)
	for _, n in ipairs(v) do _s:add(n) end
	return _s:ok()
end


-- parser metatable

local P do
	local mt = {
		__call = function(mt, parser, converter)
			return setmetatable({ parser = parser, converter = converter }, mt)
		end,
		-- allows 'lazy arguments'
		-- i.e can use a yet to be defined rule in a previous rule
		__index = function(t, k)
			return function(...) return t[k](...) end
		end
	}

	P = setmetatable({
		__call = function(t, str, at, _s)
			local r = t.parser(str, at, _s)
			if r.ok and t.converter then
				r.value = t.converter(r.value, _s)
			end
			return r
		end
	}, mt)
end


-- utils

local function toset(t)
	local r = { }
	for _, v in pairs(t or { }) do
		r[v] = true
	end
	return r
end

local function fail(at)
	return { at = at }
end

local function ok(at, v)
	return { ok = true, at = at, value = v }
end


-- base + combinators

local function token(t)
	return function(str, at)
		local to = at + #t
		return t == str:sub(at, to - 1) and ok(to, t) or fail(at)
	end
end

local function consume(stops, escapes)
	stops, escapes = toset(stops), toset(escapes)
	return function(str, at)
		local to = at
		local raw, esc = { }, { }
		local c = str:sub(to, to)
		while to <= #str and not stops[c] do
			if c == '\\' then
				table.insert(raw, c)
				to = to + 1
				c = str:sub(to, to)
				if not stops[c] and not escapes[c] then
					table.insert(esc, '\\')
				end
			end
			table.insert(raw, c)
			table.insert(esc, c)
			to = to + 1
			c = str:sub(to, to)
		end
		return to ~= at
			and ok(to, { raw = table.concat(raw), esc = table.concat(esc) })
			or fail(at)
	end
end

local function pattern(p)
	return function(str, at)
		local r = str:match('^' .. p, at)
		return r and ok(at + #r, r) or fail(at)
	end
end

local function maybe(p)
	return function(str, at, ...)
		local r = p(str, at, ...)
		return ok(r.at, r.value)
	end
end

local function rep(p)
	return function(str, at, ...)
		local v, to, r = { }, at, ok(at)
		while to <= #str and r.ok do
			table.insert(v, r.value)
			to = r.at
			r = p(str, to, ...)
		end
		return #v > 0 and ok(to, v) or fail(at)
	end
end

local function any(...)
	local t = { ... }
	return function(str, at, ...)
		for _, p in ipairs(t) do
			local r = p(str, at, ...)
			if r.ok then return r end
		end
		return fail(at)
	end
end

local function seq(...)
	local t = { ... }
	return function(str, at, ...)
		local v, to = { }, at
		for _, p in ipairs(t) do
			local r = p(str, to, ...)
			if r.ok then
				table.insert(v, r.value)
				to = r.at
			else
				return fail(at)
			end
		end
		return ok(to, v)
	end
end


-- grammar rules

-- token cache
local t = setmetatable({ },
	{
		__index = function(t, k)
			local fn = token(k)
			rawset(t, k, fn)
			return fn
		end
	}
)

P.int = pattern('%d+')

P.var = pattern('[%a_][%w_]*')

-- '}' needs to be escaped in normal text (i.e #0)
local __text0 = consume({ '$' },      { '\\', '}' })
local __text1 = consume({ '}' },      { '\\' })
local __text2 = consume({ ':' },      { '\\' })
local __text3 = consume({ '/' },      { '\\' })
local __text4 = consume({ '$', '}' }, { '\\' })
local __text5 = consume({ ',', '|' }, { '\\' })
local __text6 = consume({ "$", "/" }, { "\\" })

P._if1  = P(__text1, to_text)
P._if2  = P(__text2, to_text)
P._else = P(__text1, to_text)

P.options = pattern('%l*')

P.regex = P(__text3, to_text)

P.format = P(any(
	seq(t['$'],  P.int),
	seq(t['${'], P.int, maybe(seq(t[':'], any(
		seq(t['/'], any(t['upcase'], t['downcase'], t['capitalize'], t['pascalcase'], t['camelcase'])),
		seq(t['+'], P._if1),
		seq(t['?'], P._if2, t[':'], P._else),
		seq(t['-'], P._else),
		P._else
	))), t['}'])
), format_fn)

P.transform_text = P(__text6, to_text)
P.transform = P(
	seq(t['/'], P.regex, t['/'], rep(any(P.format, P.transform_text)), t['/'], P.options),
	transform_fn
)

P.variable_text = P(__text4, text_node)
P.variable = P(any(
	seq(t['$'],  P.var),
	seq(t['${'], P.var, maybe(any(
		-- grammar says a single mandatory 'any' for default, vscode seems to accept any*
		seq(t[':'], maybe(rep(any(P.dollars, P.variable_text)))),
		P.transform
	)), t['}'])
), variable_node)

P.choice_text = P(__text5, to_text)
P.choice = P(
	seq(t['${'], P.int, t['|'], P.choice_text, maybe(rep(seq(t[','], P.choice_text))), t['|}']),
	choice_node
)

P.placeholder_text = P(__text4, text_node)
P.placeholder = P(
	seq(t['${'], P.int, t[':'], maybe(rep(any(P.dollars, P.placeholder_text))), t['}']),
	placeholder_node
)

P.tabstop = P(any(
	seq(t['$'],  P.int),
	-- transform isnt specified in the grammar but seems to be supported by vscode
	seq(t['${'], P.int, maybe(P.transform), t['}'])
), tabstop_node)


P.dollars = any(P.tabstop, P.placeholder, P.choice, P.variable)

P.text = P(__text0, text_node)
P.any = any(P.dollars, P.text)

P.snippet = P(rep(P.any), build_snippet)


-- JSON files

-- defined at the end of the file
local extensions

local fstate = { NOT_DONE = 'not done', QUEUED = 'queued', DONE = 'done' }
local queue = { }
local files = { }
local files2exts = { }
local exts2files = { }

local function parse_file(file)
	if files[file] == fstate.DONE then return end
	files[file] = fstate.DONE

	local _f = io.open(file)
	if not _f then
		core.error('[LSP snippets] Could not open \'%s\'', file)
		return
	end
	local ok, r = pcall(json.decode, _f:read('a'))
	_f:close()
	if not ok then
		core.error('[LSP snippets] %s: %s', file, r:match('%d+:%s+(.*)'))
		return false
	end

	local exts = file:match('%.json$') and files2exts[file]
	for i, s in pairs(r) do
		-- apparently body can be a single string
		local template = type(s.body) == 'table'
			and table.concat(s.body, '\n')
			or s.body
		if not template or template == '' then
			core.warn('[LSP snippets] missing \'body\' for %s (%s)', i, file)
			goto continue
		end

		-- https://code.visualstudio.com/docs/editor/userdefinedsnippets#_language-snippet-scope
		local scope
		if not exts and s.scope then
			local tmp = { }
			for _, l in ipairs(s.scope) do
				for _, e in ipairs(extensions[l:lower()]) do
					tmp[e] = true
				end
			end
			scope = { }
			for l in pairs(tmp) do
				table.insert(scope, l)
			end
		end

		-- prefix may be an array
		local triggers = type(s.prefix) ~= 'table' and { s.prefix } or s.prefix
		if #triggers == 0 then
			core.warn('[LSP snippets] missing \'prefix\' for %s (%s)', i, file)
			goto continue
		end

		for _, t in ipairs(triggers) do
			snippets.add {
				trigger = t,
				format = 'lsp',
				files = exts or scope,
				info = i,
				desc = s.description,
				template = template
			}
		end

		::continue::
	end

	return true
end

local function pop()
	while #queue > 0 do
		repeat until parse_file(table.remove(queue)) ~= nil
		if #queue > 0 then coroutine.yield() end
	end
end

local function enqueue(filename)
	if not core.threads[THREAD_KEY] then
		core.add_thread(pop, THREAD_KEY)
	end
	files[filename] = fstate.QUEUED
	table.insert(queue, filename)
end

local function add_file(filename, exts)
	if files[filename] then return end

	if filename:match('%.code%-snippets$') then
		enqueue(filename)
		return
	end

	if not filename:match('%.json$') then return end

	if not exts then
		local lang_name = filename:match('([^/%\\]*)%.%w*$'):lower()
		exts = extensions[lang_name]
		if not exts then return end
	end

	files[filename] = fstate.NOT_DONE
	exts = type(exts) == 'string' and { exts } or exts
	for _, e in ipairs(exts) do
		files2exts[filename] = files2exts[filename] or { }
		table.insert(files2exts[filename], '%.' .. e .. '$')
		exts2files[e] = exts2files[e] or { }
		table.insert(exts2files[e], filename)
	end
end

local function for_filename(name)
	if not name then return end
	local ext = name:match('%.(.*)$')
	if not ext then return end
	local _files = exts2files[ext]
	if not _files then return end
	for _, f in ipairs(_files) do
		if files[f] == fstate.NOT_DONE then
			enqueue(f)
		end
	end
end

local doc_new = Doc.new
function Doc:new(filename, ...)
	doc_new(self, filename, ...)
	for_filename(filename)
end

local doc_set_filename = Doc.set_filename
function Doc:set_filename(filename, ...)
	doc_set_filename(self, filename, ...)
	for_filename(filename)
end


-- API

local M = { }

function M.parse(template)
	local _s = B.new()
	local r = P.snippet(template, 1, _s)
	if not r.ok then
		return B.new():s(template):ok()
	elseif r.at == #template + 1 then
		return r.value
	else
		return _s:s(template:sub(r.at + 1)):ok()
	end
end

snippets.parsers.lsp = M.parse

local warned = false
function M.add_paths(paths)
	if not json then
		if not warned then
			core.error(
				'[LSP snippets] Could not add snippet file(s):' ..
				'JSON plugin not found'
			)
			warned = true
		end
		return
	end

	paths = type(paths) ~= 'table' and { paths } or paths

	for _, p in ipairs(paths) do
		-- non absolute paths are treated as relative from USERDIR
		p = not common.is_absolute_path(p) and (USERDIR .. PATHSEP .. p) or p
		local finfo = system.get_file_info(p)

		-- if path of a directory, add every file it contains and directories
		-- whose name is that of a lang
		if finfo and finfo.type == 'dir' then
			for _, f in ipairs(system.list_dir(p)) do
				f = p .. PATHSEP .. f
				finfo = system.get_file_info(f)
				if not finfo or finfo.type == 'file' then
					add_file(f)
				else
					-- only if the directory's name matches a language
					local lang_name = f:match('[^/%\\]*$'):lower()
					local exts = extensions[lang_name]
					for _, f2 in ipairs(system.list_dir(f)) do
						f2 = f .. PATHSEP .. f2
						finfo = system.get_file_info(f2)
						if not finfo or finfo.type == 'file' then
							add_file(f2, exts)
						end
					end
				end
			end
		-- if path of a file, add the file
		else
			add_file(p)
		end
	end
end


-- arbitrarily cleaned up extension dump from https://gist.github.com/ppisarczyk/43962d06686722d26d176fad46879d41
-- nothing after this

-- 90% of these are still useless but cba

extensions = {
	['ats'] = { 'dats', 'hats', 'sats', },
	['ada'] = { 'adb', 'ada', 'ads', },
	['agda'] = { 'agda', },
	['asciidoc'] = { 'asciidoc', 'adoc', 'asc', },
	['assembly'] = { 'asm', 'nasm', },
	['autohotkey'] = { 'ahk', 'ahkl', },
	['awk'] = { 'awk', 'auk', 'gawk', 'mawk', 'nawk', },
	['batchfile'] = { 'bat', 'cmd', },
	['c'] = { 'c', 'h', },
	['c#'] = { 'cs', 'cake', 'cshtml', 'csx', },
	['c++'] = { 'cpp', 'c++', 'cc', 'cp', 'cxx', 'h', 'h++', 'hh', 'hpp', 'hxx', },
	['cmake'] = { 'cmake', 'cmake.in', },
	['cobol'] = { 'cob', 'cbl', 'ccp', 'cobol', 'cpy', },
	['css'] = { 'css', },
	['clean'] = { 'icl', 'dcl', },
	['clojure'] = { 'clj', 'boot', 'cl2', 'cljc', 'cljs', 'cljs.hl', 'cljscm', 'cljx', 'hic', },
	['common lisp'] = { 'lisp', 'asd', 'cl', 'l', 'lsp', 'ny', 'podsl', 'sexp', },
	['component pascal'] = { 'cp', 'cps', },
	['coq'] = { 'coq', 'v', },
	['crystal'] = { 'cr', },
	['cuda'] = { 'cu', 'cuh', },
	['d'] = { 'd', 'di', },
	['dart'] = { 'dart', },
	['dockerfile'] = { 'dockerfile', },
	['eiffel'] = { 'e', },
	['elixir'] = { 'ex', 'exs', },
	['elm'] = { 'elm', },
	['emacs lisp'] = { 'el', 'emacs', 'emacs.desktop', },
	['erlang'] = { 'erl', 'es', 'escript', 'hrl', 'xrl', 'yrl', },
	['f#'] = { 'fs', 'fsi', 'fsx', },
	['fortran'] = { 'f90', 'f', 'f03', 'f08', 'f77', 'f95', 'for', 'fpp', },
	['factor'] = { 'factor', },
	['forth'] = { 'fth', '4th', 'f', 'for', 'forth', 'fr', 'frt', 'fs', },
	['go'] = { 'go', },
	['groff'] = { 'man', '1', '1in', '1m', '1x', '2', '3', '3in', '3m', '3qt', '3x', '4', '5', '6', '7', '8', '9', 'l', 'me', 'ms', 'n', 'rno', 'roff', },
	['groovy'] = { 'groovy', 'grt', 'gtpl', 'gvy', },
	['html'] = { 'html', 'htm', 'html.hl', 'xht', 'xhtml', },
	['haskell'] = { 'hs', 'hsc', },
	['idris'] = { 'idr', 'lidr', },
	['jsx'] = { 'jsx', },
	['java'] = { 'java', },
	['javascript'] = { 'js', },
	['julia'] = { 'jl', },
	['jupyter notebook'] = { 'ipynb', },
	['kotlin'] = { 'kt', 'ktm', 'kts', },
	['lean'] = { 'lean', 'hlean', },
	['less'] = { 'less', },
	['lua'] = { 'lua', 'fcgi', 'nse', 'pd_lua', 'rbxs', 'wlua', },
	['markdown'] = { 'md', 'markdown', 'mkd', 'mkdn', 'mkdown', 'ron', },
	['modula-2'] = { 'mod', },
	['moonscript'] = { 'moon', },
	['ocaml'] = { 'ml', 'eliom', 'eliomi', 'ml4', 'mli', 'mll', 'mly', },
	['objective-c'] = { 'm', 'h', },
	['objective-c++'] = { 'mm', },
	['oz'] = { 'oz', },
	['php'] = { 'php', 'aw', 'ctp', 'fcgi', 'inc', 'php3', 'php4', 'php5', 'phps', 'phpt', },
	['plsql'] = { 'pls', 'pck', 'pkb', 'pks', 'plb', 'plsql', 'sql', },
	['plpgsql'] = { 'sql', },
	['pascal'] = { 'pas', 'dfm', 'dpr', 'inc', 'lpr', 'pp', },
	['perl'] = { 'pl', 'al', 'cgi', 'fcgi', 'perl', 'ph', 'plx', 'pm', 'pod', 'psgi', 't', },
	['perl6'] = { '6pl', '6pm', 'nqp', 'p6', 'p6l', 'p6m', 'pl', 'pl6', 'pm', 'pm6', 't', },
	['picolisp'] = { 'l', },
	['pike'] = { 'pike', 'pmod', },
	['pony'] = { 'pony', },
	['postscript'] = { 'ps', 'eps', },
	['powershell'] = { 'ps1', 'psd1', 'psm1', },
	['prolog'] = { 'pl', 'pro', 'prolog', 'yap', },
	['python'] = { 'py', 'bzl', 'cgi', 'fcgi', 'gyp', 'lmi', 'pyde', 'pyp', 'pyt', 'pyw', 'rpy', 'tac', 'wsgi', 'xpy', },
	['racket'] = { 'rkt', 'rktd', 'rktl', 'scrbl', },
	['rebol'] = { 'reb', 'r', 'r2', 'r3', 'rebol', },
	['ruby'] = { 'rb', 'builder', 'fcgi', 'gemspec', 'god', 'irbrc', 'jbuilder', 'mspec', 'pluginspec', 'podspec', 'rabl', 'rake', 'rbuild', 'rbw', 'rbx', 'ru', 'ruby', 'thor', 'watchr', },
	['rust'] = { 'rs', 'rs.in', },
	['scss'] = { 'scss', },
	['sql'] = { 'sql', 'cql', 'ddl', 'inc', 'prc', 'tab', 'udf', 'viw', },
	['sqlpl'] = { 'sql', 'db2', },
	['scala'] = { 'scala', 'sbt', 'sc', },
	['scheme'] = { 'scm', 'sld', 'sls', 'sps', 'ss', },
	['self'] = { 'self', },
	['shell'] = { 'sh', 'bash', 'bats', 'cgi', 'command', 'fcgi', 'ksh', 'sh.in', 'tmux', 'tool', 'zsh', },
	['smalltalk'] = { 'st', 'cs', },
	['standard ml'] = { 'ML', 'fun', 'sig', 'sml', },
	['swift'] = { 'swift', },
	['tcl'] = { 'tcl', 'adp', 'tm', },
	['tex'] = { 'tex', 'aux', 'bbx', 'bib', 'cbx', 'cls', 'dtx', 'ins', 'lbx', 'ltx', 'mkii', 'mkiv', 'mkvi', 'sty', 'toc', },
	['typescript'] = { 'ts', 'tsx', },
	['vala'] = { 'vala', 'vapi', },
	['verilog'] = { 'v', 'veo', },
	['visual basic'] = { 'vb', 'bas', 'cls', 'frm', 'frx', 'vba', 'vbhtml', 'vbs', },
}

extensions.cpp    = extensions['c++']
extensions.csharp = extensions['c#']
extensions.latex  = extensions.tex
extensions.objc   = extensions['objective-c']

M.extensions = extensions

return M
