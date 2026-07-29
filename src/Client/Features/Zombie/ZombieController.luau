local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils = require(ReplicatedStorage.Shared.Utils)
local Network = require(script.Parent.Parent.Parent.Network)
local ZombieClientComponent = require(script.Parent.Components.ZombieClientComponent)

local VFXUtils = Utils.VFXUtils
local SFXUtils = Utils.SFXUtils

local Private = {}
local Shared = {}

function Shared.OnStart()
	Network.ZombieDamaged.On(Private.OnZombieDamaged)
end

function Private.OnZombieDamaged(payload: { Part: BasePart?, Damage: number })
	VFXUtils.PlayBlood(payload.Part)

	if payload.Part then
		SFXUtils.PlayAtPosition("Hit", payload.Part.CFrame)
	end

	local model = payload.Part and payload.Part:FindFirstAncestorWhichIsA("Model")
	local zombie = model and ZombieClientComponent:FromInstance(model)
	if zombie then
		zombie:TakeDamage(payload.Damage)
	end
end

return Shared
