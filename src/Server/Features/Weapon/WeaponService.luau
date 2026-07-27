local ServerScriptService = game:GetService("ServerScriptService")

local Signals = require(ServerScriptService.Server.Signals)

local Private = {}
local Shared = {}

function Shared.OnStart()
	Signals.ProfileSignals.Loaded:Connect(Private.OnProfileLoaded)
end

function Private.OnProfileLoaded(player: Player) end

return Shared
