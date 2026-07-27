local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local ProfileTemplate: Types.ProfileType = {
	Currencies = {
		Cash = 0,
	},
}

return ProfileTemplate
