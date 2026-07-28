local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DEFAULT_EMIT_COUNT = 10

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

return Shared
