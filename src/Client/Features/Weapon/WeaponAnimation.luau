local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local WeaponAnimations = ReplicatedStorage.Assets.Animations.Weapon

local janitor = Janitor.new()
local animationTracks: { [string]: AnimationTrack } = {}

local Shared = {}

function Shared.SetCharacter(character: Model)
	janitor:Cleanup()
	animationTracks = {}

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end

	animationTracks = {
		Recoil = janitor:Add(animator:LoadAnimation(WeaponAnimations.Recoil), "Destroy"),
		Reload = janitor:Add(animator:LoadAnimation(WeaponAnimations.Reload), "Destroy"),
	}
end

function Shared.Play(name: string)
	local track = animationTracks[name]
	if track then
		track:Play()
	end
end

function Shared.Stop()
	janitor:Cleanup()
	animationTracks = {}
end

return Shared
