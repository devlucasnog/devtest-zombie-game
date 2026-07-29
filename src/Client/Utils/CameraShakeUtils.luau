local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)

local camera = Workspace.CurrentCamera

local cameraShaker = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(shakeCFrame: CFrame)
	camera.CFrame = camera.CFrame * shakeCFrame
end)

cameraShaker:Start()

local Shared = {}

function Shared.Shake(preset: string)
	cameraShaker:Shake(CameraShaker.Presets[preset])
end

function Shared.ShakeOnce(magnitude: number, roughness: number, fadeInTime: number?, fadeOutTime: number?)
	cameraShaker:ShakeOnce(magnitude, roughness, fadeInTime, fadeOutTime)
end

return Shared
