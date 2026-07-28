local SUFFIXES = {
	"",
	"K",
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp",
	"Oc",
	"No",
}

local Shared = {}

function Shared.FormatWithSuffix(value: number, decimals: number?)
	if value < 1000 then
		return tostring(math.floor(value))
	end

	local Tier = math.floor(math.log10(value) / 3)
	if Tier > #SUFFIXES - 1 then
		Tier = #SUFFIXES - 1
	end

	local ScaledNumber = value / (1000 ^ Tier)
	local Precision = decimals or 2
	local Formatted = string.format(`%.{Precision}f`, ScaledNumber):gsub("%.0+$", ""):gsub("(%.%d-)0+$", "%1")

	return `{Formatted}{SUFFIXES[Tier + 1]}`
end

function Shared.FormatTime(totalSeconds: number)
	local hours = math.floor(totalSeconds / 3600)
	local minutes = math.floor((totalSeconds % 3600) / 60)
	local seconds = math.floor(totalSeconds % 60)

	if hours > 0 then
		return string.format("%02d:%02d:%02d", hours, minutes, seconds)
	else
		return string.format("%02d:%02d", minutes, seconds)
	end
end

return Shared
