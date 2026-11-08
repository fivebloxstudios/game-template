local function formatDuration(totalSeconds: number): string
	local remaining = math.max(0, math.floor(totalSeconds))
	local parts: {string} = {}

	local days = math.floor(remaining / 86400)
	remaining = remaining % 86400
	local hours = math.floor(remaining / 3600)
	remaining = remaining % 3600
	local minutes = math.floor(remaining / 60)
	remaining = remaining % 60

	if days > 0 then table.insert(parts, tostring(days) .. "d") end
	if hours > 0 then table.insert(parts, tostring(hours) .. "h") end
	if minutes > 0 then table.insert(parts, tostring(minutes) .. "m") end
	if remaining > 0 or #parts == 0 then
		table.insert(parts, tostring(remaining) .. "s")
	end

	return table.concat(parts, " ")
end

return formatDuration