local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local WeaponsFolder = ServerStorage.Weapons

local Config: { [string]: Types.WeaponConfigType } = {
    Pistol = {
        DisplayName = "Pistol",
        MaxAmmo = 8,
        Damage = 25,
        FireRate = 0.5,
        HeadMultiplier = 0.25,
        ReloadCooldown = 3,
        Range = 32,
        ToolReference = WeaponsFolder.Pistol
    }
}

return Config