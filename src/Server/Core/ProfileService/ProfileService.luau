local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileTemplate = require(script.Parent.ProfileTemplate)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ProfileStore = require(ServerScriptService.Packages.ProfileStore)
local Signals = require(ServerScriptService.Server.Signals)
local Replica = require(ReplicatedStorage.Packages.Replica)

local TOKEN = Replica.Token("Profile")
local DATASTORE_SUFFIX = RunService:IsStudio() and "Dev" or "Prod"
local DATASTORE_NAME = `PlayerData_{DATASTORE_SUFFIX}`

local DataStore = ProfileStore.New(DATASTORE_NAME, ProfileTemplate)

local playerData = {}

local Private = {}
local Shared = {}

function Shared.OnStart()
	Players.PlayerAdded:Connect(Private.OnPlayerAdded)
	Players.PlayerRemoving:Connect(Private.OnPlayerRemoving)

	for _, player in Players:GetPlayers() do
		task.defer(Private.OnPlayerAdded, player)
	end
end

function Private.OnPlayerAdded(player: Player)
	local janitor = Janitor.new()

	local success, session = pcall(function()
		return DataStore:StartSessionAsync(tostring(player.UserId), {
			Cancel = function()
				return player.Parent ~= Players
			end,
		})
	end)

	if not success or not session then
		warn(`[ProfileService] Failed to start session for {player.Name} ({player.UserId}): {tostring(session)}`)
		janitor:Destroy()
		player:Kick("Something is wrong, try again!")
		return
	end

	session:AddUserId(player.UserId)
	session:Reconcile()

	local replica = Replica.New({
		Token = TOKEN,
		Data = session.Data,
	})

	janitor:Add(replica, "Destroy")

	if replica.ReadyPlayers[player] then
		replica:Subscribe(player)
	else
		janitor:Add(
			replica.NewReadyPlayer:Connect(function(readyPlayer: Player)
				if readyPlayer == player then
					replica:Subscribe(player)
				end
			end),
			"Disconnect"
		)
	end

	local sessionEndConnection = session.OnSessionEnd:Connect(function()
		playerData[player].Janitor:Destroy()
		playerData[player] = nil
	end)

	janitor:Add(sessionEndConnection, "Disconnect")

	playerData[player] = {
		Janitor = janitor,
		Session = session,
		Replica = replica,
	}

	Signals.ProfileSignals.Loaded:Fire(player)
end

function Private.OnPlayerRemoving(player: Player)
	local data = playerData[player]
	if not data then
		warn(`[ProfileService] No profile data found for player {player.Name} ({player.UserId})`)
		return
	end

	data.Session:EndSession()
end

return Shared
