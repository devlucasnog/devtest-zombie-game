local Shared = {}

function Shared.GetWeaponFromCharacter(character: Model): Tool?
	local weapon = character:FindFirstChildOfClass("Tool")
	if not weapon or not weapon:HasTag("Weapon") then
		return
	end

	return weapon
end

function Shared.GetMuzzle(weapon: Tool): Attachment?
	local handle = weapon:FindFirstChild("Handle")
	local muzzle = handle and handle:FindFirstChild("Muzzle")

	if not (muzzle and muzzle:IsA("Attachment")) then
		return
	end

	return muzzle
end

return Shared
