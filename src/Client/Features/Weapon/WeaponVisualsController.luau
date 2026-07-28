local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils = require(ReplicatedStorage.Shared.Utils)
local Network = require(script.Parent.Parent.Parent.Network)

local VFXUtils = Utils.VFXUtils

local Private = {}
local Shared = {}

function Shared.OnStart()
	Network.WeaponFired.On(Private.OnWeaponFired)
end

function Private.OnWeaponFired(payload: { Muzzle: Attachment?, EndPoint: Vector3 })
	VFXUtils.PlayMuzzleFlash(payload.Muzzle)

	if payload.Muzzle then
		VFXUtils.PlayTracer(payload.Muzzle.WorldPosition, payload.EndPoint)
	end
end

return Shared
