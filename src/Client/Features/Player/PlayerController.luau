local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ClientUtils = require(script.Parent.Parent.Parent.Utils)

local CameraShakeUtils = ClientUtils.CameraShakeUtils

local player = Players.LocalPlayer
local janitor = Janitor.new()
local lastHealth = 0

local Private = {}
local Shared = {}

function Shared.OnStart()
	player.CharacterAdded:Connect(Private.OnCharacterAdded)

	if player.Character then
		Private.OnCharacterAdded(player.Character)
	end
end

function Private.OnCharacterAdded(character: Model)
	janitor:Cleanup()

	local humanoid = character:WaitForChild("Humanoid")
	if not (humanoid and humanoid:IsA("Humanoid")) then
		return
	end

	lastHealth = humanoid.Health

	janitor:Add(
		humanoid.HealthChanged:Connect(function(health: number)
			Private.OnHealthChanged(health)
		end),
		"Disconnect"
	)
end

function Private.OnHealthChanged(health: number)
	if health < lastHealth then
		CameraShakeUtils.Shake("Bump")
	end

	lastHealth = health
end

return Shared
