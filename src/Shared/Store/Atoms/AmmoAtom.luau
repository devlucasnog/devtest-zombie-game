local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Types = require(ReplicatedStorage.Shared.Types)

export type AmmoState = Types.AmmoType

local DefaultState: AmmoState = {
	Current = 0,
	Max = 0,
}

return Charm.atom(DefaultState)
