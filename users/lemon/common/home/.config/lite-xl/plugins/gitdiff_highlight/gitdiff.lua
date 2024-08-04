-- mod-version:1
local gitdiff = {}

-- liquidev is a genius
local function extract_hunks(input)
	local hunks = {}
	local current_hunk = {}

	local function end_hunk(new_line)
		if #current_hunk > 0 then
			table.insert(hunks, current_hunk)
			current_hunk = { new_line }
		end
	end

	for line in input:gmatch("(.-)\n") do
		if line:match("^@") then
			end_hunk(line)
		else
			table.insert(current_hunk, line)
		end
	end

	-- add the last hunk to the table
	end_hunk("")

	return hunks
end

-- determines if line is a hunk header and returns
-- the starting line of changed version (second set of numbers part before
-- optional comma) or nil
---@param line string
---@return integer | nil
local function get_hunk_start(line)
	if "string" ~= type(line) or not line:match("^@@[^@]+@@") then
		return nil
	end

	-- doing "@@%s+-%d+(,%d+)?%s++(%d-)(,%d+)?%s+@@" did not work
	-- so we loop through a couple of patterns
	local patterns = {
		"@@%s+-%d+,%d+%s++(%d-),%d+%s+@@",
		"@@%s+-%d+%s++(%d-),%d+%s+@@",
		"@@%s+-%d+,%d+%s++(%d-)%s+@@",
		"@@%s+-%d+%s++(%d-)%s+@@"
	}

	local start
	for _, p in ipairs(patterns) do
		start = line:match(p)
		if start then return tonumber(start) end
	end
	return nil
end

-- this will only work on single-file diffs
function gitdiff.changed_lines(diff)
	if not diff then return {} end
	local changed_lines = {}
	local hunks = extract_hunks(diff)
	-- iterate over hunks
	for _, hunk in ipairs(hunks) do
		local current_line
		local hunk_start = get_hunk_start(hunk[1])
		if not hunk_start then -- mod
			goto continue
		end

		current_line = hunk_start - 1

		-- remove hunk header
		hunk[1] = ""

		for _, line in ipairs(hunk) do
			if line:match("^%s-%[%-.-%-]$") then
				table.insert(changed_lines, {
					line_number = current_line,
					change_type = "deletion"
				})
				-- do not add to the current line
				goto skip_line
			end

			if line:match("^%s-{%+.-+}$") then
				table.insert(changed_lines, {
					line_number = current_line,
					change_type = "addition"
				})

			elseif line:match("{%+.-+}") or line:match("%[%-.-%-]") then
				table.insert(changed_lines, {
					line_number = current_line,
					change_type = "modification"
				})
			end

			current_line = current_line + 1
			::skip_line::
		end
		::continue::
	end

	local indexed_changed_lines = {}
	for _, line in ipairs(changed_lines) do
		indexed_changed_lines[line.line_number] = line.change_type
	end

	return indexed_changed_lines
end

return gitdiff
