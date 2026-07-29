local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local Config: { [string]: Types.ZombieConfigType } = {
	Basic = {
		DisplayName = "Basic",
		Health = 100,
		WalkSpeed = 32,
		Damage = 25,
		AttackCooldown = 1,
		AttackRange = 5,
	},
}

return Config
