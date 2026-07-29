local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Utils = require(ReplicatedStorage.Shared.Utils)
local ClientUtils = require(script.Parent.Parent.Parent.Utils)

local VFXUtils = Utils.VFXUtils
local SFXUtils = Utils.SFXUtils
local CameraShakeUtils = ClientUtils.CameraShakeUtils

local player = Players.LocalPlayer

local Private = {}
local Shared = {}

function Shared.PlayFired(muzzle: Attachment?, direction: Vector3, range: number)
	VFXUtils.PlayMuzzleFlash(muzzle)

	if not muzzle then
		return
	end

	local origin = muzzle.WorldPosition
	VFXUtils.PlayTracer(origin, Private.PredictEndPoint(origin, direction, range))
	SFXUtils.PlayAtPosition("Shoot", muzzle.WorldCFrame)
	CameraShakeUtils.ShakeOnce(0.5, 0.5, 0.05, 0.5)
end

function Private.PredictEndPoint(origin: Vector3, direction: Vector3, range: number): Vector3
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { player.Character }

	local result = Workspace:Raycast(origin, direction * range, raycastParams)
	return result and result.Position or origin + direction * range
end

return Shared
