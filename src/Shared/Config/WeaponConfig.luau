local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local Config: { [string]: Types.WeaponConfigType } = {
	Pistol = {
		DisplayName = "Pistol",
		MaxAmmo = 32,
		Damage = 25,
		FireRate = 0.25,
		HeadMultiplier = 0.5,
		ReloadCooldown = 3,
		Range = 64,
	},
}

return Config
