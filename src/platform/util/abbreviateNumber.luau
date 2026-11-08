-- 950 -> "950", 1500 -> "1.5K", 150000000000 -> "150B"
const SUFFIXES = { "K", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No", "Dc" }

const function abbreviateNumber(value: number): string
	local scaled = math.abs(value)
	local suffix = ""
	for _, nextSuffix in SUFFIXES do
		if scaled < 1000 then
			break
		end
		scaled /= 1000
		suffix = nextSuffix
	end

	-- one decimal at most, dropped when it's zero
	const rounded = math.floor(scaled * 10) / 10
	const text = if rounded % 1 == 0 then string.format("%d", rounded) else string.format("%.1f", rounded)
	return (if value < 0 then "-" else "") .. text .. suffix
end

return abbreviateNumber
