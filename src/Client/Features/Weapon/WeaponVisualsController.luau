local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils = require(ReplicatedStorage.Shared.Utils)
local Network = require(script.Parent.Parent.Parent.Network)

local VFXUtils = Utils.VFXUtils

local Private = {}
local Shared = {}

function Shared.OnStart()
	Network.WeaponFired.On(Private.OnWeaponFired)
end

function Private.OnWeaponFired(payload: { Muzzle: Attachment? })
	VFXUtils.PlayMuzzleFlash(payload.Muzzle)
end

return Shared
