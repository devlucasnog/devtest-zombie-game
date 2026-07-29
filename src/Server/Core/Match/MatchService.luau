local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Config = require(ReplicatedStorage.Shared.Config)
local Enums = require(ReplicatedStorage.Shared.Enums)
local Types = require(ReplicatedStorage.Shared.Types)
local Signals = require(ServerScriptService.Server.Signals)
local Network = require(ServerScriptService.Server.Network)

local MatchConfig = Config.MatchConfig
local MatchState = Enums.MatchState

local matchState: string = MatchState.Waiting
local currentRound = 0
local zombiesRemaining = 0
local phaseStartedAt = 0
local phaseDuration = 0

local playerScores: { [Player]: number } = {}
local playerAlive: { [Player]: boolean } = {}
local playerJanitors: { [Player]: Types.JanitorType } = {}
local matchJanitor = Janitor.new()

local Private = {}
local Shared = {}

function Shared.OnStart()
	Signals.ProfileSignals.Loaded:Connect(Private.OnProfileLoaded)
	Players.PlayerRemoving:Connect(Private.OnPlayerRemoving)
end

function Private.OnProfileLoaded(player: Player)
	playerAlive[player] = true
	if playerScores[player] == nil then
		playerScores[player] = 0
	end

	local janitor = Janitor.new()
	playerJanitors[player] = janitor

	janitor:Add(
		player.CharacterAdded:Connect(function(character)
			Private.WatchCharacter(player, character, janitor)
		end),
		"Disconnect"
	)

	if player.Character then
		Private.WatchCharacter(player, player.Character, janitor)
	end

	Private.TryStartMatch()
	Private.SyncPlayer(player)
end

function Private.BroadcastMatchState()
	Network.MatchUpdated.FireAll({
		State = matchState,
		Round = currentRound,
		Duration = math.floor(phaseDuration),
	})
end

function Private.SyncPlayer(player: Player)
	local remaining = math.max(phaseDuration - (os.clock() - phaseStartedAt), 0)

	Network.MatchUpdated.Fire(player, {
		State = matchState,
		Round = currentRound,
		Duration = math.floor(remaining),
	})
end

function Private.OnPlayerRemoving(player: Player)
	playerAlive[player] = nil

	local janitor = playerJanitors[player]
	if janitor then
		janitor:Destroy()
		playerJanitors[player] = nil
	end

	if matchState ~= MatchState.Waiting and matchState ~= MatchState.GameEnded then
		if not Private.AnyPlayerAlive() then
			Private.EndGame()
		end
	end
end

function Private.WatchCharacter(player: Player, character: Model, janitor: Types.JanitorType)
	playerAlive[player] = true

	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	janitor:Add(
		humanoid.Died:Connect(function()
			Private.OnPlayerDied(player)
		end),
		"Disconnect",
		"HumanoidDied"
	)
end

function Private.OnPlayerDied(player: Player)
	playerAlive[player] = false

	if currentRound >= 1 and not Private.AnyPlayerAlive() then
		Private.EndGame()
	end
end

function Private.AnyPlayerAlive(): boolean
	for _, alive in playerAlive do
		if alive then
			return true
		end
	end

	return false
end

function Private.TryStartMatch()
	if matchState == MatchState.Waiting then
		Private.StartIntermission(1)
	end
end

function Private.StartIntermission(nextRound: number)
	matchState = MatchState.Intermission
	phaseStartedAt = os.clock()
	phaseDuration = MatchConfig.IntermissionDuration
	Private.BroadcastMatchState()

	matchJanitor:Add(
		task.delay(MatchConfig.IntermissionDuration, function()
			Private.StartRound(nextRound)
		end),
		true,
		"IntermissionTimer"
	)
end

function Private.StartRound(roundNumber: number)
	currentRound = roundNumber
	zombiesRemaining = MatchConfig.InitialZombieCount + (roundNumber - 1) * MatchConfig.ZombieCountIncrement

	local roundDuration = MatchConfig.BaseRoundDuration + zombiesRemaining * MatchConfig.RoundDurationPerZombie

	matchState = MatchState.RoundActive
	phaseStartedAt = os.clock()
	phaseDuration = roundDuration
	Private.BroadcastMatchState()
	Signals.MatchSignals.RoundStarted:Fire(roundNumber, zombiesRemaining, roundDuration)
end

function Private.BuildLeaderboard(): { Types.LeaderboardEntryType }
	local leaderboard = {}

	for player, points in playerScores do
		local thumbnail =
			Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)

		table.insert(leaderboard, { Thumbnail = thumbnail, DisplayName = player.DisplayName, Points = points })
	end

	table.sort(leaderboard, function(a, b)
		return a.Points > b.Points
	end)

	return leaderboard
end

function Private.EndGame()
	matchState = MatchState.GameEnded
	phaseStartedAt = os.clock()
	phaseDuration = MatchConfig.GameEndDisplayDuration
	matchJanitor:Remove("IntermissionTimer")

	local leaderboard = Private.BuildLeaderboard()

	Signals.MatchSignals.GameEnded:Fire(leaderboard)
	Signals.MatchSignals.GameReset:Fire()
	Private.BroadcastMatchState()
	Network.LeaderboardUpdated.FireAll({ Entries = leaderboard })

	playerScores = {}
	for player in playerAlive do
		playerAlive[player] = true
	end

	currentRound = 0
	zombiesRemaining = 0

	matchJanitor:Add(
		task.delay(MatchConfig.GameEndDisplayDuration, function()
			Private.StartIntermission(1)
		end),
		true,
		"IntermissionTimer"
	)
end

function Shared.ReportZombieKilled(player: Player)
	if matchState ~= MatchState.RoundActive then
		return
	end

	playerScores[player] = (playerScores[player] or 0) + MatchConfig.PointsPerKill
	zombiesRemaining -= 1

	if zombiesRemaining <= 0 then
		local clearedRound = currentRound
		Signals.MatchSignals.RoundCleared:Fire(clearedRound)
		Private.StartIntermission(clearedRound + 1)
	end
end

return Shared
