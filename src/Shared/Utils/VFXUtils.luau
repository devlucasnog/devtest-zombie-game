local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local DEFAULT_EMIT_COUNT = 10
local TRACER_LIFETIME = 0.05

local VFX = ReplicatedStorage.Assets.VFX

local Shared = {}

function Shared.PlayMuzzleFlash(muzzle: Attachment?)
	if not muzzle then
		return
	end

	for _, template in VFX.MuzzleFlash:GetChildren() do
		if not template:IsA("ParticleEmitter") then
			continue
		end

		local emitter = template:Clone()
		emitter.Parent = muzzle
		emitter:Emit(emitter:GetAttribute("EmitCount") or DEFAULT_EMIT_COUNT)

		Debris:AddItem(emitter, emitter.Lifetime.Max + 0.1)
	end
end

function Shared.PlayTracer(origin: Vector3, endPoint: Vector3)
	local tracer = VFX.BulletTracer:Clone()

	local originPart = tracer:FindFirstChild("1") :: BasePart
	local endPart = tracer:FindFirstChild("2") :: BasePart

	originPart.Position = origin
	endPart.Position = endPoint

	tracer.Parent = Workspace
	Debris:AddItem(tracer, TRACER_LIFETIME)
end

return Shared
