local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Config = require(ReplicatedStorage.Shared.Config)
local Signals = require(ServerScriptService.Server.Signals)

local DEFAULT_ZOMBIE_TYPE = "Basic"

local MatchConfig = Config.MatchConfig
local ZombieConfig = Config.ZombieConfig
local ZombieSpawns = workspace.ZombieSpawn:GetChildren()

local zombiesFolder: Folder
local spawnJanitor = Janitor.new()

local Private = {}
local Shared = {}

function Shared.OnStart()
	Private.CreateFolder()

	Signals.MatchSignals.RoundStarted:Connect(Private.OnRoundStarted)
	Signals.MatchSignals.GameReset:Connect(Private.OnGameReset)
end

function Private.CreateFolder()
	local folder = Workspace:FindFirstChild("Zombies")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Zombies"
		folder.Parent = Workspace
	end

	zombiesFolder = folder
end

function Private.OnRoundStarted(roundNumber: number, zombieCount: number)
	print(`[Zombie] Spawning {zombieCount} zombies for round {roundNumber}`)

	spawnJanitor:Add(
		task.spawn(function()
			for _ = 1, zombieCount do
				Private.SpawnZombie()
				task.wait(MatchConfig.ZombieSpawnInterval)
			end
		end),
		true,
		"SpawnLoop"
	)
end

function Private.OnGameReset()
	spawnJanitor:Remove("SpawnLoop")

	for _, zombie in zombiesFolder:GetChildren() do
		zombie:Destroy()
	end
end

function Private.SpawnZombie()
	if #ZombieSpawns == 0 then
		warn(`[Zombie] Spawn zombie not found`)
		return
	end

	local spawnPoint = ZombieSpawns[math.random(#ZombieSpawns)]
	local zombieConfig = ZombieConfig[DEFAULT_ZOMBIE_TYPE]

	local zombie = zombieConfig.ModelReference:Clone()
	zombie:PivotTo(spawnPoint.CFrame)
	zombie.Parent = zombiesFolder
end

return Shared
