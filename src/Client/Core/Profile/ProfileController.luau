local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Replica = require(ReplicatedStorage.Packages.Replica)
local Store = require(ReplicatedStorage.Shared.Store)

local Private = {}
local Shared = {}

function Shared.OnStart()
	Replica.RequestData()

	Replica.OnNew("Profile", function(replica)
		Store.Profile(table.clone(replica.Data))

		replica:OnChange(function(_action, _path, _param1, _param2)
			Store.Profile(table.clone(replica.Data))
		end)
	end)
end

return Shared
