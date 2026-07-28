local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Config = require(ReplicatedStorage.Shared.Config)
local Signals = require(ServerScriptService.Server.Signals)
local ZombieServerComponent = require(script.Parent.Components.ZombieServerComponent)

local DEFAULT_ZOMBIE_TYPE = "Basic"

local MatchConfig = Config.MatchConfig
local ZombiesFolder = ServerStorage.Zombies
local ZombieSpawns = workspace.ZombieSpawn:GetChildren()

local zombiesFolder: Folder
local spawnJanitor = Janitor.new()

local Private = {}
local Shared = {}

function Shared.OnStart()
	Private.CreateFolder()

	Signals.MatchSignals.RoundStarted:Connect(Private.OnRoundStarted)
	Signals.MatchSignals.GameReset:Connect(Private.OnGameReset)
	Signals.CombatSignals.WeaponHit:Connect(Private.OnWeaponHit)
end

function Private.OnWeaponHit(hitCharacter: Model, damage: number, attacker: Player, hitPart: BasePart)
	local zombie = ZombieServerComponent:FromInstance(hitCharacter)
	if not zombie then
		return
	end

	zombie:TakeDamage(damage, attacker, hitPart)
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

function Private.OnRoundStarted(_roundNumber: number, zombieCount: number)
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

	local zombie = ZombiesFolder[DEFAULT_ZOMBIE_TYPE]:Clone()
	zombie:PivotTo(spawnPoint.CFrame + Vector3.new(0, 4, 0))
	zombie.Parent = zombiesFolder
end

return Shared
