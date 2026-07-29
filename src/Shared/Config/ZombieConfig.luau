local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local Config: { [string]: Types.ZombieConfigType } = {
	Basic = {
		DisplayName = "Basic",
		Health = 100,
		WalkSpeed = 8,
		Damage = 10,
		AttackCooldown = 1,
		AttackRange = 5,
	},
}

return Config
