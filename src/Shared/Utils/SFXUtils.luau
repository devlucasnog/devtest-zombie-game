local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage.Shared.Config)

local soundCache: { [string]: Sound } = {}

if RunService:IsClient() then
	for name, config in Config.SFXConfig do
		local sound = Instance.new("Sound")
		sound.Name = name
		sound.SoundId = `rbxassetid://{config.SoundId}`
		sound.Volume = config.Volume or 1

		if config.RollOffMaxDistance then
			sound.RollOffMaxDistance = config.RollOffMaxDistance
		end

		if config.RollOffMinDistance then
			sound.RollOffMinDistance = config.RollOffMinDistance
		end

		sound.Parent = SoundService
		soundCache[name] = sound
	end
end

local SFXUtils = {}

function SFXUtils.Play(name: string, parent: Instance?)
	local sound = soundCache[name]
	if not sound then
		warn(`[SFXUtils] Sound not found: "{name}"`)
		return
	end

	if parent then
		local clone = sound:Clone()
		clone.Parent = parent
		clone:Play()

		clone.Ended:Once(function()
			clone:Destroy()
		end)
	else
		sound:Play()
	end
end

function SFXUtils.PlayAtPosition(name: string, position: CFrame)
	local sound = soundCache[name]
	if not sound then
		warn(`[SFXUtils] Sound not found: "{name}"`)
		return
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.one
	part.CFrame = position
	part.Parent = workspace

	local clone = sound:Clone()
	clone.Parent = part
	clone:Play()

	clone.Ended:Once(function()
		part:Destroy()
	end)
end

function SFXUtils.CreateSound(name: string, parent: Instance?): Sound?
	local sound = soundCache[name]
	if not sound then
		warn(`[SFXUtils] Sound not found: "{name}"`)
		return
	end

	local clone = sound:Clone()

	if parent then
		clone.Parent = parent
	end

	return clone
end

return SFXUtils
