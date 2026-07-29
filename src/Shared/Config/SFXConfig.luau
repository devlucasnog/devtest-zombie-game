local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local Config: { [string]: Types.SFXConfigType } = {
	-- Weapon
	Shoot = {
		SoundId = 9205598207,
		RollOffMinDistance = 40,
		RollOffMaxDistance = 100,
	},
	Hit = {
		SoundId = 140025518477459,
		RollOffMinDistance = 40,
		RollOffMaxDistance = 100,
	},
}

return Config
