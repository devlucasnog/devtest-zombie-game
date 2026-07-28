local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Enums = require(ReplicatedStorage.Shared.Enums)

export type MatchState = {
	State: string,
	Round: number,
	EndsAt: number,
}

local DefaultState: MatchState = {
	State = Enums.MatchState.Waiting,
	Round = 0,
	EndsAt = 0,
}

return Charm.atom(DefaultState)
