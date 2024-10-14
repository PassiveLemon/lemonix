-- mod-version:3


local core      = require 'core'
local command   = require 'core.command'
local common    = require 'core.common'
local config    = require 'core.config'
local Doc       = require 'core.doc'
local translate = require 'core.doc.translate'
local keymap    = require 'core.keymap'

local autocomplete
if config.plugins.autocomplete ~= false then
	local ok, a = pcall(require, 'plugins.autocomplete')
	autocomplete = ok and a
end


local M       = { }
local raws    = { }
local cache   = { }
local active  = { }
local watches = { }
local parsers = { }


local SNIPPET_FIELDS   = { 'transforms', 'defaults', 'matches', 'choices' }
local DEFAULT_FORMAT   = { }
local DEFAULT_PATTERN  = '([%w_]+)[^%S\n]*$'
local DEFAULT_MATCH    = { kind = 'lua', pattern = DEFAULT_PATTERN }
local MATCH_TYPES      = { lua = true }
local AUTOCOMPLETE_KEY = { }


-- config

config.plugins.snippets = common.merge({
	autoexit = true,

	config_spec = {
		name = 'Snippets',
		{
			label       = 'Automatically exit',
			description = 'Automatically exit snippets upon text input' ..
			              'if the leading selection is not on a tabstop.',
			path        = 'autoexit',
			type        = 'toggle',
			default     = true
		}
	}
}, config.plugins.snippets)


-- utils

local function unmask(x, ...)
	return type(x) == 'function' and x(...) or x
end

local function deep_copy(x)
	if type(x) ~= 'table' then return x end
	local r = { }
	for k, v in pairs(x) do
		r[k] = deep_copy(v)
	end
	return r
end

local function copy_snippet(_s)
	local s = common.merge(_s)
	local nodes = { }
	for _, n in ipairs(_s.nodes) do
		table.insert(nodes, common.merge(n))
	end
	s.nodes = nodes
	return s
end

local function autocomplete_cleanup()
	autocomplete.map_manually[AUTOCOMPLETE_KEY] = nil
end


-- trigger

local function normalize_match_patterns(patterns)
	local ret = { normalized = true }
	for _, p in ipairs(patterns) do
		if type(p) == 'string' then
			table.insert(ret, { kind = 'lua', pattern = p })
		elseif type(p) == 'table' then
			if p.kind ~= nil and not MATCH_TYPES[p.kind] then
				core.error('[snippets] invalid match kind: \'%s\'', p.kind)
				return
			end
			table.insert(ret, {
				kind    = p.kind or 'lua',
				pattern = p.pattern or DEFAULT_PATTERN,
				keep    = p.keep,
				strict  = p.strict
			})
		elseif p then
			table.insert(ret, DEFAULT_MATCH)
		else -- false?
			core.error('[snippets] invalid match: \'%s\'', p)
			return
		end
	end
	return ret
end

local function get_raw(raw)
	local _s

	if raw.template then
		local fmt = raw.format or DEFAULT_FORMAT
		_s = cache[fmt] and deep_copy(cache[fmt][raw.template])
		if not _s then
			local parser = parsers[fmt]
			if not parser then
				core.error('[snippets] no parser for format: %s', fmt)
				return
			end
			local _p = parser(raw.template, raw.p_args)
			if not _p or not _p.nodes then return end
			_s = { nodes = common.merge(_p.nodes) }
			for _, v in ipairs(SNIPPET_FIELDS) do
				_s[v] = _p[v]
			end
			cache[fmt] = cache[fmt] or { }
			cache[fmt][raw.template] = deep_copy(_s)
		end
	elseif raw.nodes then
		_s = { nodes = common.merge(raw.nodes) }
	end

	if not _s then return end

	for _, v in ipairs(SNIPPET_FIELDS) do
		_s[v] = common.merge(_s[v], raw[v])
	end
	if not _s.matches.normalized then
		_s.matches = normalize_match_patterns(_s.matches)
		if not _s.matches then return end
	end

	return _s
end

local function get_by_id(id)
	local raw = raws[id]
	if not raw then return end
	local _s = get_raw(raw)
	if _s and not raw.matches.normalized then
		raw.matches = _s.matches
	end
	return _s
end

local function get_partial(doc)
	local l2, c2 = doc:get_selection()
	local l1, c1 = doc:position_offset(l2, c2, translate.start_of_word)
	local partial = doc:get_text(l1, c1, l2, c2)
	return partial
end

local function get_matching_partial(doc, partial, l1, c1)
	local sz = #partial
	if sz == 0 then return c1 end

	local n = c1 - 1
	local line = doc.lines[l1]
	for i = 1, sz + 1 do
		local j = sz - i
		local subline = line:sub(n - j, n)
		local subpartial = partial:sub(i, -1)
		if subpartial == subline then
			return n - j
		end
	end
end

local function get_matches(doc, patterns, l1, c1, l2, c2)
	local matches, removed = { }, { }
	if not l2 or not c2 then
		l2, c2 = l1, c1
		l1, c1 = 1, 1
	end

	local text = doc:get_text(l1, c1, l2, c2)

	for i, p in ipairs(patterns) do
		local match = not p.strict and ''
		local function sub_cb(...)
			match = select('#', ...) > 1 and { ... } or ...
			return ''
		end

		local sz = #text
		if p.kind == 'lua' then
			text = text:gsub(p.pattern or DEFAULT_PATTERN.pattern, sub_cb, 1)
		end

		if not match then
			core.error(
				'[snippets] failed strict match #%d: \'%s\'',
				i, p.pattern
			)
			return
		end

		matches[i] = match

		local offset = #text - sz
		local _l, _c = doc:position_offset(l2, c2, offset)
		if not p.keep and offset ~= 0 then
			removed[i] = doc:get_text(_l, _c, l2, c2)
			doc:remove(_l, _c, l2, c2)
		end
		l2, c2 = _l, _c
	end

	return matches, removed
end


-- init

local resolve_nodes, resolve_one, resolve_static, resolve_user

local function concat_buf(into)
	if #into.buf == 0 then return end
	table.insert(
		into.nodes,
		{ kind = 'static', value = table.concat(into.buf) }
	)
	into.buf = { }
end

local function resolve_default(default, ctx, into)
	local v = unmask(default, ctx) or ''
	if type(v) ~= 'table' then return v end
	local inline_into = common.merge(into, { nodes = { }, buf = { } })
	resolve_one(v, ctx, inline_into)
	concat_buf(inline_into)
	return { inline = true, nodes = inline_into.nodes }
end

function resolve_user(n, ctx, into)
	local id = n.id
	if type(id) ~= 'number' or id < 0 then
		error(string.format('node id must be a positive number: %s', id), 0)
	end

	n = common.merge(n)
	concat_buf(into)
	table.insert(into.nodes, n)

	local tid = into.tabstops[id]
	if not tid then
		into.tabstops[id] = { count = 1, [n] = true }
	else
		tid[n] = true
		tid.count = tid.count + 1
	end

	local m = into.mains
	m[id] = not m[id] and n or (n.main and not m[id].main) and n or m[id]

	local v
	if n.default then                        -- node specific default
		v = resolve_default(n.default, ctx, into)
	elseif into.defaults[id] then            -- unresolved general default
		v = resolve_default(into.defaults[id], ctx, into)
	end

	local raw
	if type(v) ~= 'table' then
		v = v and tostring(v) or ''
	else
		raw = v
		if v.value then
			v = v.value
		else
			v = { }
			for _, _n in ipairs(raw.nodes) do
				local value = _n.value
				if type(value) == 'table' then value = value.value end
				table.insert(v, value)
			end
			v = table.concat(v)
			raw.value = v
		end
	end

	n.transform = not n.transform and into.transforms[id] or n.transform
	if raw then
		raw.value = v
		n.value = raw
	else
		n.value = v
	end
end

function resolve_static(n, ctx, into)
	local t, v = type(n), n
	if t == 'table' and n.kind then
		v = n.value
		t = type(v)
	end

	if t == 'table' then
		for _, _n in ipairs(v) do resolve_one(_n, ctx, into) end
	elseif t == 'function' then
		resolve_one(v(ctx), ctx, into)
	elseif t ~= 'nil' then
		table.insert(into.buf, tostring(v))
	end
end

function resolve_one(n, ctx, into)
	if type(n) == 'table' and n.kind == 'user' then
		resolve_user(n, ctx, into)
	elseif n ~= nil then
		resolve_static(n, ctx, into)
	end
end

function resolve_nodes(nodes, ctx, into)
	for _, n in ipairs(nodes) do resolve_one(n, ctx, into) end
	concat_buf(into)
	return into
end

local function init(_s)
	local ctx = _s.ctx
	if not ctx then return end

	local into = {
		buf      = { },
		nodes    = { },
		mains    = { },
		tabstops = { },
		defaults = _s.defaults,
		transforms = _s.transforms
	}

	local ok, n = pcall(resolve_nodes, _s.nodes, ctx, into)
	if not ok then
		core.error('[snippets] %s', n)
		return
	end

	_s.mains = n.mains
	_s.nodes = n.nodes
	_s.tabstops = n.tabstops

	return true
end


-- expand

-- shitty workaround because the watches / selections aren't set when inserting
-- the first round of snippets, so autoexit exits when inserting them
local function doc_expect(doc, val)
	watches[doc] = watches[doc] or { }
	watches[doc].expect = val
end

local function w_active_at(w, l1, c1, l2, c2)
	if not w.active then return end

	if w[1] > l1 or (w[1] == l1 and w[2] > c1) or
	   w[3] < l2 or (w[3] == l2 and w[4] < c2) then
		return
	  end

	for i = #(w.children or { }), 1, -1 do
		local r = w_active_at(w.children[i], l1, c1, l2, c2)
		if r then return r end
	end

	return not w.snippet and w
end

local function w_cmp(w1, w2)
	local x
	x = w2[3] - w1[3]
	if x > 0 then return true elseif x < 0 then return false end
	x = w2[4] - w1[4]
	if x > 0 then return true elseif x < 0 then return false end
	x = w2[1] - w1[1]
	if x < 0 then return true elseif x > 0 then return false end
	x = w2[2] - w1[2]
	if x < 0 then return true elseif x > 0 then return false end
	return w2.depth < w1.depth
end

local function push(_s)
	local doc = _s.ctx.doc

	if not watches[doc] then
		watches[doc] = { _s.watch }
	elseif #watches[doc] == 0 then
		table.insert(watches[doc], _s.watch)
	else
		local w, doc_watches = _s.watch, watches[doc]
		local idx = #doc_watches
		while idx > 1 and w_cmp(w, doc_watches[idx]) do
			idx = idx - 1
		end
		table.insert(doc_watches, idx, w)
	end

	local a = active[doc]
	local ts = a.tabstops
	for id, _ in pairs(_s.tabstops) do
		local c = ts[id]
		ts[id] = c and c + 1 or 1
		a.max_id = math.max(id, a.max_id)
	end

	a._tabstops_as_array = nil
	table.insert(a, _s)
end

local function pop(_s)
	local doc_watches = watches[_s.ctx.doc]
	local w = _s.watch
	for i, _w in ipairs(doc_watches) do
		if w == _w then
			table.remove(doc_watches, i)
		end
	end

	local a = active[_s.ctx.doc]
	local ts = a.tabstops
	local max = false
	for id, _ in pairs(_s.tabstops) do
		ts[id] = ts[id] - 1
		max = max or (a.max_id and ts[id] == 0)
	end
	if max then
		max = 0
		for id, _ in pairs(a.tabstops) do
			max = math.max(id, max)
		end
		a.max_id = max
	end

	local idx
	for i, s in ipairs(a) do
		if s == _s then idx = i; break end
	end

	a._tabstops_as_array = nil
	table.remove(a, idx)
end

local function insert_nodes(nodes, doc, p, l, c, d, indent)
	local _l, _c
	for _, n in ipairs(nodes) do
		local w
		if n.kind == 'user' then
			w = { l, c, depth = d, active = false, parent = p }
			n.watch = w
		else
			n.value = n.value:gsub('\n', indent)
		end
		if type(n.value) == 'table' then
			w.children = { }
			_l, _c, d = insert_nodes(
				n.value.nodes, doc, w, l, c, d + 1, indent
			)
		else
			doc:insert(l, c, n.value)
			_l, _c = doc:position_offset(l, c, #n.value)
		end
		l, c = _l, _c
		if w then
			table.insert(p.children, w)
			w[3], w[4] = l, c
		end
	end
	return l, c, d
end

local function expand(_s, depth)
	local ctx = _s.ctx
	local l, c = ctx.line, ctx.col
	_s.watch = {
		l, c, l, c, depth = depth,
		active = true, snippet = true,
		children = { }
	}

	local _l, _c = insert_nodes(
		_s.nodes, ctx.doc, _s.watch,
		l, c, depth + 1,
		'\n' .. ctx.indent_str
	)
	_s.max_depth = depth
	_s.watch[3], _s.watch[4] = _l, _c
	_s.value = ctx.doc:get_text(l, c, _l, _c)

	push(_s)
	return true
end


-- navigation

local function transforms_for(_s, id)
	local nodes = _s.tabstops[id]
	if not nodes or nodes.count == 0 then return end
	local doc = _s.ctx.doc
	for n in pairs(nodes) do
		if n == 'count' then goto continue end
		local w = n.watch
		if w.hidden or not w.dirty or not n.transform then goto continue end

		local v = doc:get_text(w[1], w[2], w[3], w[4])
		local r = type(n.value) == 'table' and n.value or nil
		local _v = n.transform(v, r) or ''
		if v ~= _v then
			doc:remove(w[1], w[2], w[3], w[4])
			doc:insert(w[1], w[2], _v)
		end
		w.dirty = false

		::continue::
	end
end

local function transforms(snippets, id)
	for _, _s in ipairs(snippets) do
		transforms_for(_s, id)
	end
end

local function set_active(w, val)
	while not w.snippet and w.active ~= val do
		w.active = val
		w = w.parent
	end
end

local function clear_active(snippets)
	local id = snippets.last_id
	for _, _s in ipairs(snippets) do
		for node in pairs(_s.tabstops[id] or { }) do
			if node ~= 'count' then
				set_active(node.watch, false)
			end
		end
	end
end

local function set_hidden(w, into)
	into = into or { }
	w.hidden = true
	into[w] = true
	if w.children then
		for _, c in ipairs(w.children) do
			set_hidden(c, into)
		end
	end
	return into
end

local function dispatch_sanitize(ts, nodes, hidden)
	for _, n in ipairs(nodes) do
		if n.watch and hidden[n.watch] then
			local id = n.id
			ts[id] = ts[id] - 1
		end
		if type(n.value) == 'table' then
			dispatch_sanitize(ts, n.value.nodes, hidden)
		end
	end
end

local function sanitize_ts_counts(snippets, hidden)
	local ts = snippets.tabstops
	for _, _s in ipairs(snippets) do
		dispatch_sanitize(ts, _s.nodes, hidden)
	end

	local new_max = 0
	for id, count in pairs(ts) do
		if count > 0 then new_max = math.max(new_max, id) end
	end
	snippets.max_id = new_max
	snippets._tabstops_as_array = nil
end

-- docview crashes while updating if the doc doesnt have selections
-- so instead gather all new selections & set it at once
-- selections also need to be sorted as multicursor editing relies on that
local function selection_for_watch(sels, w, end_only)
	local i = 1
	while i < #sels do
		if sels[i] > w[3] or sels[i] == w[3] and sels[i + 1] > w[4] then
			break
		end
		i = i + 4
	end
	common.splice(
		sels, i, 0,
		{ w[3], w[4], end_only and w[3] or w[1], end_only and w[4] or w[2] }
	)
end

local function select_after(snippets)
	local doc = snippets.doc
	local new_sels = { }
	for _, _s in ipairs(snippets) do
		selection_for_watch(new_sels, _s.watch, true)
	end
	if #new_sels > 0 then
		doc.selections = new_sels
		doc.last_selection = #new_sels / 4
	end
end

local function next_id(snippets, reverse)
	local id, ts = snippets.last_id, snippets.tabstops

	-- performance issues when iterating above that
	-- 100k should be fine still so 10k just in case
	if snippets.max_id > 10000 then
		ts = snippets._tabstops_as_array
		if not ts then
			ts = { }
			for i in pairs(snippets.tabstops) do table.insert(ts, i) end
			table.sort(ts)
			local last = 0
			for i, _id in ipairs(ts) do
				if _id == id then last = i; break end
			end
			ts = { array = ts, last = last - 1 }
			snippets._tabstops_as_array = ts
		end
		local sz = #ts.array
		ts.last = reverse and ((ts.last - 1 + sz) % sz) or ((ts.last + 1) % sz)
		return ts.array[ts.last + 1]
	end

	local wrap = reverse and 1 or snippets.max_id
	local to = reverse and snippets.max_id + 1 or 0
	local i = reverse and -1 or 1
	local old = id
	repeat
		if id == wrap then id = to end
		id = id + i
	until (ts[id] and ts[id] > 0) or id == old
	return id ~= old and id
end

local function set_tabstop(snippets, id)
	local doc = snippets.doc
	local choices = autocomplete and { }
	local new_sels = { }

	for _, _s in ipairs(snippets) do
		local nodes = _s.tabstops[id]
		if not nodes or nodes.count == 0 then goto continue end
		for n in pairs(nodes) do
			if n ~= 'count' and not n.watch.hidden then
				selection_for_watch(new_sels, n.watch)
				set_active(n.watch, true)
			end
		end
		::continue::
		if choices and _s.choices[id] then
			for k, v in pairs(_s.choices[id]) do choices[k] = v end
		end
	end

	if #new_sels > 0 then
		doc.selections = new_sels
		doc.last_selection = #new_sels / 4
		if choices and next(choices) then
			autocomplete.complete(
				{ name = AUTOCOMPLETE_KEY, items = choices },
				autocomplete_cleanup
			)
		end
	end
	snippets.last_id = id
end


-- watching

local raw_insert, raw_remove = Doc.raw_insert, Doc.raw_remove

local function autoexit(doc)
	if (watches[doc] and not watches[doc].expect) and
	    config.plugins.snippets.autoexit and not M.in_snippet(doc, true) then
		active[doc]  = nil
		watches[doc] = nil
		return true
	end
end

local function dispatch_insert(w, l1, c1, l2, c2, ldiff, cdiff)
	local found_aa = false

	if w[3] > l1 then
		w[3] = w[3] + ldiff
	-- w[4] == c1: found the append/active
	elseif w[3] == l1 and w[4] >= c1 then
		found_aa = w.active and w[4] == c1
		w[3] = w[3] + ldiff
		w[4] = w[4] + cdiff
	else
		return false
	end

	if w[1] > l1 then
		w[1] = w[1] + ldiff
	-- move start only if not active
	elseif w[1] == l1 and
	      (w[2] > c1 or (w[2] == c1 and not found_aa)) then
		w[1] = w[1] + ldiff
		w[2] = w[2] + cdiff
	else
		w.dirty = true
	end

	for i = (w.children and #w.children or 0), 1, -1 do
		if dispatch_insert(w.children[i], l1, c1, l2, c2, ldiff, cdiff) then
			break
		end
	end

	return found_aa
end

local function dispatch_remove(w, l1, c1, l2, c2, ldiff, cdiff)
	local hide, hide_s, hide_c = false, false, false
	local w1, w2, w3, w4 = w[1], w[2], w[3], w[4]

	if w3 > l1 or (w3 == l1 and w4 > c1) then
		if w3 > l2 then
			w[3] = w3 - ldiff
		else
			hide = w3 < l2 or (w3 == l2 and w4 <= c2)
			w[3] = l1
			w[4] = (w3 == l2 and w4 > c2) and w4 - cdiff or c1
		end
	else
		return false
	end

	if w1 > l1 or (w1 == l1 and w2 > c1) then
		if w1 > l2 then
			w[1] = w1 - ldiff
		else
			hide_s = w1 > l1 or (w1 == l1 and w2 > c1)
			w[1] = l1
			w[2] = (w1 == l2 and w2 > c2) and w2 - cdiff or c1
		end
	else
		hide_c = w1 == l1 and w2 == c1
		w.dirty = true
	end

	if not w.snippet and w.active and hide then
		-- if deletion starts before the watch, hide the watch itself
		if hide_s then
			return set_hidden(w)
		-- if the deletion starts at the start of the watch, hide children
		elseif hide_c then
			if not w.children then return true end
			local ret = { }
			for _, c in ipairs(w.children) do set_hidden(c, ret) end
			return ret
		end
	end

	for i = (w.children and #w.children or 0), 1, -1 do
		local r = dispatch_remove(w.children[i], l1, c1, l2, c2, ldiff, cdiff)
		if r then return r end
	end

	return false
end

function Doc:raw_insert(l1, c1, t, undo, ...)
	raw_insert(self, l1, c1, t, undo, ...)
	if autoexit(self) then return end

	local doc_watches = watches[self]
	if not doc_watches then return end

	local u = undo[undo.idx - 1]
	local l2, c2 = u[3], u[4]
	local ldiff, cdiff = l2 - l1, c2 - c1

	for i = #doc_watches, 1, -1 do
		if dispatch_insert(doc_watches[i], l1, c1, l2, c2, ldiff, cdiff) then
			break
		end
	end
end

function Doc:raw_remove(l1, c1, l2, c2, ...)
	raw_remove(self, l1, c1, l2, c2, ...)
	if autoexit(self) then return end

	local doc_watches = watches[self]
	if not doc_watches then return end

	local ldiff, cdiff = l2 - l1, c2 - c1

	local h
	for i = #doc_watches, 1, -1 do
		h = dispatch_remove(doc_watches[i], l1, c1, l2, c2, ldiff, cdiff)
		if h then break end
	end

	if type(h) == 'table' then sanitize_ts_counts(active[self], h) end
end


-- API

M.parsers = parsers

M.parsers[DEFAULT_FORMAT] = function(s)
	return { kind = 'static', value = s }
end

local function ac_callback(_, item)
	M.execute(item.data, nil, true)
	return true
end

function M.add(snippet)
	local _s = { }

	if snippet.template then
		_s.template = snippet.template
		_s.format   = snippet.format or DEFAULT_FORMAT
		_s.p_args   = snippet.p_args
	elseif snippet.nodes then
		_s.nodes = snippet.nodes
	else
		return
	end

	for _, v in ipairs(SNIPPET_FIELDS) do
		_s[v] = snippet[v] or { }
	end

	local id = os.time() + math.random()

	local ac
	if autocomplete and snippet.trigger then
		ac = {
			info = snippet.info,
			desc = snippet.desc or snippet.template,
			onselect = ac_callback,
			data = id
		}
		autocomplete.add {
			name  = id,
			files = snippet.files,
			items = { [snippet.trigger] = ac }
		}
	end

	raws[id] = _s
	return id, ac
end

function M.remove(id)
	raws[id] = nil
	cache[id] = nil
	if autocomplete then
		autocomplete.map[id] = nil
	end
end

function M.execute(snippet, doc, partial)
	doc = doc or core.active_view.doc
	if not doc then return end

	local _t, _s = type(snippet)
	_s = _t == 'number' and get_by_id(snippet)
	  or _t == 'table'  and get_raw(snippet)
	if not _s then return end

	local undo_idx = doc.undo_stack.idx

	-- autocomplete hasn't been cleared yet
	if partial and autocomplete then autocomplete.close() end

	partial = partial and get_partial(doc)
	local snippets = { }

	for idx, l1, c1, l2, c2 in doc:get_selections(true, true) do
		snippet = idx > 1 and copy_snippet(_s) or _s
		local ctx = {
			doc = doc,
			cursor_idx = idx,
			at_line = l1, at_col = c1,
			partial = '', selection = '',
			extra = { }
		}

		local n
		if l1 ~= l2 or c1 ~= c2 then
			n = 'selection'
		elseif partial then
			n = 'partial'
			c1 = get_matching_partial(doc, partial, l1, c1)
		end
		if n then
			ctx[n] = ctx.doc:get_text(l1, c1, l2, c2)
			ctx.doc:remove(l1, c1, l2, c2)
		end

		if idx == 1 then
			l2, c2 = 1, 1
		else
			local _; _, _, l2, c2 = doc:get_selection_idx(idx - 1, true)
		end
		ctx.matches, ctx.removed_from_matches = get_matches(
			doc, _s.matches, l2, c2, l1, c1
		)

		if not ctx.matches then
			while doc.undo_stack.idx > undo_idx do doc:undo() end
			return
		end

		snippet.ctx = ctx
		snippets[idx] = snippet
	end

	local a = {
		doc = doc, parent = active[doc],
		tabstops = { }, last_id = 0, max_id = 0,
		max_depth = 0
	}
	active[doc] = a

	doc_expect(doc, true)
	local depth = a.parent and a.parent.max_depth + 1 or 1
	for idx, l, c in doc:get_selections(true, true) do
		_s = snippets[idx]
		local ctx = _s.ctx
		ctx.indent_sz, ctx.indent_str = doc:get_line_indent(doc.lines[l])
		ctx.line, ctx.col = l, c
		if not init(_s) or not expand(_s, depth) then
			while doc.undo_stack.idx > undo_idx do doc:undo() end
			active[doc] = a.parent
			return
		end
		a.max_depth = math.max(a.max_depth, _s.max_depth)
	end
	doc_expect(doc, false)

	if a.max_id > 0 then M.next(a) else M.exit(a) end

	-- autocomplete is cleared when this function (M.exit) returns
	if autocomplete and autocomplete.map_manually[AUTOCOMPLETE_KEY] then
		autocomplete.on_close = function()
			autocomplete.open(autocomplete_cleanup)
		end
	end

	return true
end

function M.select_current(snippets)
	if #snippets == 0 then return end
	local id = snippets.last_id
	if id then set_tabstop(snippets, id) end
end

local function nextprev(snippets, previous)
	if #snippets == 0 then return end
	local id = next_id(snippets, previous)
	if id then
		if snippets.last_id ~= 0 then
			transforms(snippets, snippets.last_id)
		end
		clear_active(snippets, snippets.last_id)
		set_tabstop(snippets, id)
	end
end

function M.next(snippets)
	nextprev(snippets)
end

function M.previous(snippets)
	nextprev(snippets, true)
end

function M.exit(snippets)
	if #snippets == 0 then return end
	local doc = snippets.doc
	local c = snippets.tabstops[0]; c = c and c > 0
	local p = snippets.parent

	if snippets.last_id ~= 0 then transforms(snippets, snippets.last_id) end

	if p then
		for _, _s in ipairs(snippets) do pop(_s) end
		active[doc] = p
		M.next_or_exit(p)
	else
		if c then
			set_tabstop(snippets, 0)
		else
			select_after(snippets)
		end
		if snippets == active[doc] then
			active[doc]  = nil
			watches[doc] = nil
		else
			for _, _s in ipairs(snippets) do pop(_s) end
		end
	end
end

function M.exit_all(snippets)
	if #snippets == 0 then return end
	local doc = snippets.doc
	local last
	while snippets do
		if snippets.last_id ~= 0 then
			transforms(snippets, snippets.last_id)
		end
		last = snippets
		snippets = snippets.parent
	end
	local c = last.tabstops[0]; c = c and c > 0
	if c then
		set_tabstop(last, 0)
	else
		select_after(last)
	end
	active[doc]  = nil
	watches[doc] = nil
end

function M.next_or_exit(snippets)
	if #snippets == 0 then return end
	local id = snippets.last_id
	if id == snippets.max_id then
		M.exit(snippets)
	else
		M.next(snippets)
	end
end

function M.in_snippet(doc, checkpos)
	doc = doc or core.active_view.doc
	if not doc then return end
	local t = active[doc]

	if not t or #t == 0 then
		return
	elseif not checkpos then
		return t, t
	end

	local min_depth = t.parent and (t.parent.max_depth + 1) or 0
	local l1, c1, l2, c2 = doc:get_selection(true)
	l2 = l2 or l1; c2 = c2 or c1
	for i = #t, 1, -1 do
		local a = w_active_at(t[i].watch, l1, c1, l2, c2)
		if a and a.depth > min_depth then
			return t, t
		end
	end
end


-- commands

local function predicate()
	return M.in_snippet(nil, config.plugins.snippets.autoexit)
end

command.add(M.in_snippet, {
	['snippets:select-current'] = M.select_current,
	['snippets:exit']           = M.exit,
	['snippets:exit-all']       = M.exit_all
})

command.add(predicate, {
	['snippets:next']           = M.next,
	['snippets:previous']       = M.previous,
	['snippets:next-or-exit']   = M.next_or_exit
})

keymap.add {
	['tab']       = 'snippets:next-or-exit',
	['shift+tab'] = 'snippets:previous',
	['escape']    = 'snippets:exit'
}


-- snippets commands are added to the keymap after autocomplete
-- so autocomplete commands are overriden if they're bound to the same keys
do
	local function rebind(key, cmd)
		local keys = keymap.get_bindings(cmd)
		if not keys then return end
		for _, k in ipairs(keys) do
			if k == key then
				keymap.unbind(key, cmd)
				keymap.add { [key] = cmd }
				break
			end
		end
	end

	rebind('tab',    'autocomplete:complete')
	rebind('escape', 'autocomplete:cancel')
end


-- builder

local B = { }

function B.add(snippet, n)
	snippet.nodes = snippet.nodes or { }
	table.insert(snippet.nodes, n)
	return snippet
end

function B.choice(snippet, id, c)
	snippet.choices = snippet.choices or { }
	snippet.choices[id] = c
	return snippet
end

function B.default(snippet, id, v)
	snippet.defaults = snippet.defaults or { }
	snippet.defaults[id] = v
	return snippet
end

function B.match(snippet, m)
	snippet.matches = snippet.matches or { }
	table.insert(snippet.matches, m)
	return snippet
end

function B.transform(snippet, id, f)
	snippet.transforms = snippet.transforms or { }
	snippet.transforms[id] = f
	return snippet
end

function B.static(x)
	return { kind = 'static', value = x }
end

function B.user(id, default, transform)
	return { kind = 'user', id = id, default = default, transform = transform }
end

local function _add_static(snippet, x)
	return snippet:add(B.static(x))
end

local function _add_user(snippet, id, default, transform)
	return snippet:add(B.user(id, default, transform))
end

local function _ok(snippet)
	return {
		nodes      = common.merge(snippet.nodes),
		choices    = common.merge(snippet.choices),
		defaults   = common.merge(snippet.defaults),
		matches    = common.merge(snippet.matches),
		transforms = common.merge(snippet.transforms)
	}
end

function B.new()
	return {
		add       = B.add,
		choice    = B.choice,
		default   = B.default,
		match     = B.match,
		transform = B.transform,
		static    = _add_static,
		user      = _add_user,
		ok        = _ok,
		a = B.add,
		c = B.choice,
		d = B.default,
		m = B.match,
		t = B.transform,
		u = _add_user,
		s = _add_static
	}
end

M.builder = B


return M
