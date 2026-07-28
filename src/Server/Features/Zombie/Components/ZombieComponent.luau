local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Config = require(ReplicatedStorage.Shared.Config)
local Enums = require(ReplicatedStorage.Shared.Enums)
local Types = require(ReplicatedStorage.Shared.Types)

local TAG = "Zombie"
local TARGET_REFRESH_INTERVAL = 0.25

type ZombieComponentType = Types.ZombieComponentType
type Target = { RootPart: BasePart, Humanoid: Humanoid }

local ZombieConfig = Config.ZombieConfig
local ZombieState = Enums.ZombieState

local ZombieComponent = Component.new({ Tag = TAG, Ancestors = { workspace } }) :: ZombieComponentType

function ZombieComponent:Construct()
	self._janitor = Janitor.new()
	self._config = ZombieConfig[self.Instance.Name]
	self._state = ZombieState.Idle
	self._lastAttackTime = 0
	self._targetElapsed = 0
end

function ZombieComponent:Start()
	self._humanoid = self.Instance.Humanoid
	self._rootPart = self.Instance.HumanoidRootPart

	self._humanoid.MaxHealth = self._config.Health
	self._humanoid.Health = self._config.Health
	self._humanoid.WalkSpeed = self._config.WalkSpeed
end

function ZombieComponent:HeartbeatUpdate(dt: number)
	if self._humanoid.Health <= 0 then
		return
	end

	self._targetElapsed += dt
	if self._targetElapsed < TARGET_REFRESH_INTERVAL then
		return
	end
	self._targetElapsed = 0

	local target = self:_FindNearestTarget(self._rootPart.Position)
	if not target then
		self:_SetState(ZombieState.Idle)
		return
	end

	local distance = (target.RootPart.Position - self._rootPart.Position).Magnitude
	if distance <= self._config.AttackRange then
		self:_SetState(ZombieState.Attacking, target)
	else
		self:_SetState(ZombieState.Chasing, target)
	end
end

function ZombieComponent:Stop()
	self._janitor:Destroy()
end

function ZombieComponent:_FindNearestTarget(position: Vector3): Target?
	local nearest: Target? = nil
	local nearestDistance = math.huge

	for _, player in Players:GetPlayers() do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local rootPart = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?

		if humanoid and humanoid.Health > 0 and rootPart then
			local distance = (rootPart.Position - position).Magnitude
			if distance < nearestDistance then
				nearestDistance = distance
				nearest = { RootPart = rootPart, Humanoid = humanoid }
			end
		end
	end

	return nearest
end

function ZombieComponent:_SetState(
	state: string,
	target: {
		RootPart: BasePart,
		Humanoid: Humanoid,
	}
)
	if state ~= self._state then
		print(`[Zombie] {self.Instance.Name} -> {state}`)
	end

	self._state = state

	if state == ZombieState.Idle then
		self._humanoid:MoveTo(self._rootPart.Position)
	elseif state == ZombieState.Chasing then
		self._humanoid:MoveTo((target).RootPart.Position)
	elseif state == ZombieState.Attacking then
		self._humanoid:MoveTo(self._rootPart.Position)
		self:_TryAttack(target)
	end
end

function ZombieComponent:_TryAttack(target: {
	RootPart: BasePart,
	Humanoid: Humanoid,
})
	if os.clock() - self._lastAttackTime < self._config.AttackCooldown then
		return
	end

	self._lastAttackTime = os.clock()
	target.Humanoid:TakeDamage(self._config.Damage)
end

return ZombieComponent
