local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Types = require(script.Parent.Parent.Types)

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

function Shared.Raycast(
	character: Model,
	origin: Vector3,
	direction: Vector3,
	weaponConfig: Types.WeaponConfigType
): RaycastResult?
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }

	local castDirection = direction.Unit * weaponConfig.Range

	return Workspace:Raycast(origin, castDirection, raycastParams)
end

function Shared.ResolveHitTarget(result: RaycastResult): (Model?, Humanoid?)
	local hitCharacter = result.Instance:FindFirstAncestorOfClass("Model")
	if not hitCharacter then
		return nil, nil
	end

	if Players:GetPlayerFromCharacter(hitCharacter) then
		return nil, nil
	end

	local humanoid = hitCharacter:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil, nil
	end

	return hitCharacter, humanoid
end

function Shared.CalculateDamage(hitPart: BasePart, weaponConfig: Types.WeaponConfigType): number
	local damage = weaponConfig.Damage

	if hitPart.Name == "Head" then
		damage += damage * weaponConfig.HeadMultiplier
	end

	return math.floor(damage)
end

return Shared
