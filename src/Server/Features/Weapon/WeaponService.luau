local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ProfileService = require(ServerScriptService.Server.Core.ProfileService.ProfileService)
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local Signals = require(ServerScriptService.Server.Signals)

local DEFAULT_WEAPON = "Pistol"

local WeaponConfig = Config.WeaponConfig

local playerJanitors: { [Player]: Types.JanitorType } = {}

local Private = {}
local Shared = {}

function Shared.OnStart()
	Signals.ProfileSignals.Loaded:Connect(Private.OnProfileLoaded)
	Players.PlayerRemoving:Connect(Private.OnPlayerRemoving)
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

function Private.GiveWeapon(player: Player, weaponTool: Tool)
	local character = player.Character
	if not character then
		return
	end

	local weapon = weaponTool:Clone()
	weapon.Parent = character
end

return Shared
