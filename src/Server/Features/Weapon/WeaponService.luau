local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ProfileService = require(ServerScriptService.Server.Core.ProfileService.ProfileService)
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Signals = require(ServerScriptService.Server.Signals)
local Network = require(ServerScriptService.Server.Network)

local DEFAULT_WEAPON = "Pistol"
local DEBUG_RAY_LIFETIME = 1

local WeaponConfig = Config.WeaponConfig

local playerJanitors: { [Player]: Types.JanitorType } = {}

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
			Private.GiveWeapon(player, weaponConfig.ToolReference)
		end),
		"Disconnect"
	)

	if player.Character then
		Private.GiveWeapon(player, weaponConfig.ToolReference)
	end
end

function Private.OnPlayerRemoving(player: Player)
	local janitor = playerJanitors[player]
	if not janitor then
		return
	end

	janitor:Destroy()
	playerJanitors[player] = nil
end

function Private.OnFireWeaponRequest(player: Player)
	local character = player.Character
	if not character then
		return
	end

	local weaponTool = character:FindFirstChildOfClass("Tool")
	if not weaponTool then
		return
	end

	local handle = weaponTool:FindFirstChild("Handle")
	local muzzle = handle and handle:FindFirstChild("Muzzle")
	if not (muzzle and muzzle:IsA("Attachment")) then
		return
	end

	local profile = ProfileService.GetProfile(player)
	if not profile then
		return
	end

	local weaponEquipped = profile.WeaponEquipped or DEFAULT_WEAPON
	local weaponConfig = WeaponConfig[weaponEquipped]
	if not weaponConfig then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }

	local origin = muzzle.WorldPosition
	local direction = muzzle.WorldCFrame.LookVector * weaponConfig.Range

	local result = Workspace:Raycast(origin, direction, raycastParams)
	Private.DrawDebugRay(origin, result and result.Position or (origin + direction))

	if not result then
		return
	end

	local hitCharacter = result.Instance:FindFirstAncestorOfClass("Model")
	if hitCharacter and Players:GetPlayerFromCharacter(hitCharacter) then
		return
	end

	print(`{player.Name} hit {result.Instance:GetFullName()}`)
end

function Private.GiveWeapon(player: Player, weaponTool: Tool)
	local character = player.Character
	if not character then
		return
	end

	local weapon = weaponTool:Clone()
	weapon.Parent = character
end

function Private.DrawDebugRay(origin: Vector3, endPosition: Vector3)
	local distance = (endPosition - origin).Magnitude

	local ray = Instance.new("Part")
	ray.Anchored = true
	ray.CanCollide = false
	ray.CanQuery = false
	ray.Material = Enum.Material.Neon
	ray.Color = Color3.new(1, 0, 0)
	ray.Size = Vector3.new(0.1, 0.1, distance)
	ray.CFrame = CFrame.lookAt(origin, endPosition) * CFrame.new(0, 0, -distance / 2)
	ray.Parent = Workspace

	Debris:AddItem(ray, DEBUG_RAY_LIFETIME)
end

return Shared
