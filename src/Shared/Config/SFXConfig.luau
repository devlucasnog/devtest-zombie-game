local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local Config: { [string]: Types.SFXConfigType } = {
	-- Weapon
	Shoot = {
		SoundId = 9205598207,
		Volume = 0.5,
		RollOffMinDistance = 40,
		RollOffMaxDistance = 100,
	},
	Hit = {
		SoundId = 140025518477459,
		Volume = 0.5,
		RollOffMinDistance = 40,
		RollOffMaxDistance = 100,
	},
	Reload = {
		SoundId = 139798971373512,
		Volume = 0.5,
	},
	DryFire = {
		SoundId = 117629133235583,
		Volume = 0.5,
	},

	-- Zombie
	Growl = {
		SoundId = 130156156621885,
		Volume = 0.1,
		RollOffMinDistance = 40,
		RollOffMaxDistance = 100,
	},
	Die = {
		SoundId = 135839328422285,
		Volume = 0.3,
		RollOffMinDistance = 40,
		RollOffMaxDistance = 100,
	},
}

return Config
