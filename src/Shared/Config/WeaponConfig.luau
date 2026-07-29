local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local Config: { [string]: Types.WeaponConfigType } = {
	Pistol = {
		DisplayName = "Pistol",
		MaxAmmo = 4,
		Damage = 25,
		FireRate = 0.5,
		HeadMultiplier = 0.5,
		ReloadCooldown = 3,
		Range = 128,
	},
}

return Config
