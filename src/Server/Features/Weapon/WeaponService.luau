local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ProfileService = require(ServerScriptService.Server.Core.Profile.ProfileService)
local WeaponConfig = require(ReplicatedStorage.Shared.Config.WeaponConfig)
local Types = require(ReplicatedStorage.Shared.Types)
local Utils = require(ReplicatedStorage.Shared.Utils)
local Signals = require(ServerScriptService.Server.Signals)
local Network = require(ServerScriptService.Server.Network)

local DEFAULT_WEAPON = "Pistol"

local WeaponUtils = Utils.WeaponUtils
local WeaponsFolder = ServerStorage.Weapons

local playerJanitors: { [Player]: Types.JanitorType } = {}
local playerAmmo: { [Player]: number } = {}
local playerLastFireTime: { [Player]: number } = {}

local Private = {}
local Shared = {}

function Shared.OnStart()
	Signals.ProfileSignals.Loaded:Connect(Private.OnProfileLoaded)
	Players.PlayerRemoving:Connect(Private.OnPlayerRemoving)
	Network.FireWeapon.On(Private.OnFireWeaponRequest)
end

function Private.OnProfileLoaded(player: Player)
	local profile = ProfileService.GetProfile(player)
	if not profile then
		player:Kick("Profile not found, try again!")
		return
	end

	local weaponEquipped = profile.WeaponEquipped or DEFAULT_WEAPON
	local weaponConfig = WeaponConfig[weaponEquipped]
	if not weaponConfig then
		player:Kick(`Something went wrong, try again!`)
		warn(`Weapon Config for {weaponEquipped} not found`)
		return
	end

	local janitor = Janitor.new()
	playerJanitors[player] = janitor

	janitor:Add(
		player.CharacterAdded:Connect(function()
			Private.GiveWeapon(player, weaponEquipped, weaponConfig)
		end),
		"Disconnect"
	)

	if player.Character then
		Private.GiveWeapon(player, weaponEquipped, weaponConfig)
	end
end

function Private.OnPlayerRemoving(player: Player)
	playerAmmo[player] = nil
	playerLastFireTime[player] = nil

	local janitor = playerJanitors[player]
	if not janitor then
		return
	end

	janitor:Destroy()
	playerJanitors[player] = nil
end

function Private.OnFireWeaponRequest(player: Player, payload: { Direction: Vector3 })
	local character = player.Character
	if not character then
		return
	end

	local weapon = WeaponUtils.GetWeaponFromCharacter(character)
	if not weapon then
		return
	end

	local muzzle = WeaponUtils.GetMuzzle(weapon)
	if not muzzle then
		return
	end

	if not payload.Direction or not (payload.Direction.Magnitude > 0) then
		return
	end

	local weaponEquipped, weaponConfig = Private.GetEquippedWeaponConfig(player)
	if not weaponConfig or weapon.Name ~= weaponEquipped then
		return
	end

	if not Private.TryConsumeShot(player, weaponConfig) then
		return
	end

	local origin = muzzle.WorldPosition
	local result = Private.RaycastWeapon(character, origin, payload.Direction, weaponConfig)
	local endPoint = result and result.Position or origin + payload.Direction.Unit * weaponConfig.Range

	Network.WeaponFired.FireExcept(player, { Muzzle = muzzle, EndPoint = endPoint })

	if not result then
		return
	end

	local hitCharacter, hitHumanoid = Private.ResolveHitTarget(result)
	if not (hitCharacter and hitHumanoid) then
		return
	end

	Private.DealDamage(result.Instance.Name, hitCharacter, player, weaponConfig)
end

function Private.GetEquippedWeaponConfig(player: Player): (string?, Types.WeaponConfigType?)
	local profile = ProfileService.GetProfile(player)
	if not profile then
		return nil, nil
	end

	local weaponEquipped = profile.WeaponEquipped or DEFAULT_WEAPON
	return weaponEquipped, WeaponConfig[weaponEquipped]
end

function Private.TryConsumeShot(player: Player, weaponConfig: Types.WeaponConfigType): boolean
	local ammo = playerAmmo[player]
	if not ammo or ammo <= 0 then
		return false
	end

	local lastFireTime = playerLastFireTime[player]
	if lastFireTime and os.clock() - lastFireTime < weaponConfig.FireRate then
		return false
	end

	playerLastFireTime[player] = os.clock()
	playerAmmo[player] = ammo - 1
	Network.AmmoUpdated.Fire(player, { Current = ammo - 1, Max = weaponConfig.MaxAmmo })

	if ammo - 1 <= 0 then
		Private.StartReload(player, weaponConfig)
	end

	return true
end

function Private.StartReload(player: Player, weaponConfig: Types.WeaponConfigType)
	local janitor = playerJanitors[player]
	if not janitor then
		return
	end

	janitor:Add(
		task.delay(weaponConfig.ReloadCooldown, function()
			playerAmmo[player] = weaponConfig.MaxAmmo
			Network.AmmoUpdated.Fire(player, { Current = weaponConfig.MaxAmmo, Max = weaponConfig.MaxAmmo })
		end),
		true,
		"Reload"
	)
end

function Private.RaycastWeapon(
	character: Model,
	origin: Vector3,
	direction: Vector3,
	weaponConfig: Types.WeaponConfigType
): RaycastResult?
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }

	local castDirection = direction.Unit * weaponConfig.Range
	local result = Workspace:Raycast(origin, castDirection, raycastParams)

	return result
end

function Private.ResolveHitTarget(result: RaycastResult): (Model?, Humanoid?)
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

function Private.GiveWeapon(player: Player, weaponName: string, weaponConfig: Types.WeaponConfigType)
	local character = player.Character
	if not character then
		return
	end

	local janitor = playerJanitors[player]
	if janitor then
		janitor:Remove("Reload")
	end

	local weapon = WeaponsFolder[weaponName]:Clone()
	weapon.Parent = character

	playerAmmo[player] = weaponConfig.MaxAmmo
	Network.AmmoUpdated.Fire(player, { Current = weaponConfig.MaxAmmo, Max = weaponConfig.MaxAmmo })
end

function Private.DealDamage(bodyPart: string, hitCharacter: Model, player: Player, weaponConfig: Types.WeaponConfigType)
	local damage = weaponConfig.Damage

	if bodyPart == "Head" then
		damage += damage * weaponConfig.HeadMultiplier
	end

	Signals.CombatSignals.WeaponHit:Fire(hitCharacter, damage, player)
end

return Shared
