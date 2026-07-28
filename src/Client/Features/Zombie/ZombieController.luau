local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils = require(ReplicatedStorage.Shared.Utils)
local Network = require(script.Parent.Parent.Parent.Network)

local VFXUtils = Utils.VFXUtils

local Private = {}
local Shared = {}

function Shared.OnStart()
	Network.ZombieDamaged.On(Private.OnZombieDamaged)
end

function Private.OnZombieDamaged(payload: { Part: BasePart?, Damage: number })
	VFXUtils.PlayBlood(payload.Part)
end

return Shared
