local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Types = require(ReplicatedStorage.Shared.Types)

export type ProfileState = Types.ProfileType

local DefaultState: ProfileState = {
	Currencies = {
		Cash = 0,
	},
}

return Charm.atom(DefaultState)
